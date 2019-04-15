#include "nymeaconnection.h"
#include "nymeahost.h"

#include <QUrl>
#include <QDebug>
#include <QSslKey>
#include <QUrlQuery>
#include <QSettings>
#include <QMetaEnum>
#include <QStandardPaths>
#include <QFile>
#include <QDir>
#include <QTimer>
#include <QGuiApplication>

#include "nymeatransportinterface.h"

NymeaConnection::NymeaConnection(QObject *parent) : QObject(parent)
{
    m_networkConfigManager = new QNetworkConfigurationManager(this);

    QObject::connect(m_networkConfigManager, &QNetworkConfigurationManager::configurationAdded, this, [this](const QNetworkConfiguration &config){
        Q_UNUSED(config)
//        qDebug() << "Network configuration added:" << config.name() << config.bearerTypeName() << config.purpose();
        updateActiveBearers();
    });
    QObject::connect(m_networkConfigManager, &QNetworkConfigurationManager::configurationRemoved, this, [this](const QNetworkConfiguration &config){
        Q_UNUSED(config)
//        qDebug() << "Network configuration removed:" << config.name() << config.bearerTypeName() << config.purpose();
        updateActiveBearers();
    });

    QGuiApplication *app = static_cast<QGuiApplication*>(QGuiApplication::instance());
    QObject::connect(app, &QGuiApplication::applicationStateChanged, this, [this](Qt::ApplicationState state) {
        qDebug() << "Application state changed to:" << state;
        updateActiveBearers();
    });

    updateActiveBearers();
}

void NymeaConnection::acceptCertificate(const QString &url, const QByteArray &pem)
{
    storePem(url, pem);
    if (m_currentHost) {
        connectInternal(m_currentHost);
    }
}

bool NymeaConnection::isTrusted(const QString &url)
{
    // Do we have a legacy fingerprint
    QSettings settings;
    settings.beginGroup("acceptedCertificates");
    if (settings.contains(QUrl(url).host())) {
        return true;
    }

    // Do we have a PEM file?
    QByteArray pem;
    if (loadPem(url, pem)) {
        return true;
    }

    return false;
}

NymeaConnection::BearerTypes NymeaConnection::availableBearerTypes() const
{
    return m_availableBearerTypes;
}

bool NymeaConnection::connected()
{
    return m_currentHost && m_currentTransport && m_currentTransport->connectionState() == NymeaTransportInterface::ConnectionStateConnected;
}

NymeaConnection::ConnectionStatus NymeaConnection::connectionStatus() const
{
    return m_connectionStatus;
}

NymeaHost *NymeaConnection::currentHost() const
{
    return m_currentHost;
}

void NymeaConnection::setCurrentHost(NymeaHost *host)
{
    if (m_currentHost == host) {
        return;
    }

    if (m_currentTransport) {
        m_currentTransport = nullptr;
        emit currentConnectionChanged();
        emit connectedChanged(false);
    }

    while (!m_transportCandidates.isEmpty()) {
        NymeaTransportInterface *transport = m_transportCandidates.keys().first();
        m_transportCandidates.remove(transport);
        transport->deleteLater();
    }
    if (m_currentHost) {
        m_currentHost = nullptr;
    }


    m_currentHost = host;
    emit currentHostChanged();

    if (!m_currentHost) {
        qDebug() << "No current host.";
        return;
    }

    qDebug() << "Nymea host is" << m_currentHost->name() << m_currentHost->uuid();

    m_connectionStatus = ConnectionStatusConnecting;
    emit connectionStatusChanged();

    connectInternal(m_currentHost);
}

Connection *NymeaConnection::currentConnection() const
{
    qDebug() << "Current connection:" << m_currentHost << m_currentTransport << m_transportCandidates.count();
    qDebug() << m_transportCandidates.keys();
    qDebug() << m_transportCandidates.value(m_currentTransport);
    if (!m_currentHost || !m_currentTransport) {
        return nullptr;
    }
    return m_transportCandidates.value(m_currentTransport);
}

void NymeaConnection::sendData(const QByteArray &data)
{
    if (connected()) {
//        qDebug() << "sending data:" << data;
        m_currentTransport->sendData(data);
    } else {
        qWarning() << "Connection: Not connected. Cannot send.";
    }
}

void NymeaConnection::onSslErrors(const QList<QSslError> &errors)
{
    NymeaTransportInterface *transport = qobject_cast<NymeaTransportInterface*>(sender());

    qDebug() << "SSL errors for url:" << transport->url();
    QList<QSslError> ignoredErrors;
    foreach (const QSslError &error, errors) {
        qDebug() << error.errorString();
        if (error.error() == QSslError::HostNameMismatch) {
            qDebug() << "Ignoring host mismatch on certificate.";
            ignoredErrors.append(error);
        } else if (error.error() == QSslError::SelfSignedCertificate || error.error() == QSslError::CertificateUntrusted) {
            // Check our cert DB
            QByteArray pem;


            // Keep this for compatibility with old versions for a bit...
            // New code will look up the PEM instead and set it before the connection attempt
            // However, we want to emit verifyConnectionCertificate in any case here.
            QSettings settings;
            settings.beginGroup("acceptedCertificates");
            QByteArray storedFingerPrint = settings.value(transport->url().host()).toByteArray();
            settings.endGroup();

            QByteArray certificateFingerprint;
            QByteArray digest = error.certificate().digest(QCryptographicHash::Sha256);
            for (int i = 0; i < digest.length(); i++) {
                if (certificateFingerprint.length() > 0) {
                    certificateFingerprint.append(":");
                }
                certificateFingerprint.append(digest.mid(i,1).toHex().toUpper());
            }

            // Check old style fingerprint storage
            if (storedFingerPrint == certificateFingerprint) {
                qDebug() << "This fingerprint is known to us.";
                ignoredErrors.append(error);

                // Update the config to use the new system:
                storePem(transport->url(), error.certificate().toPem());

            // Check new style PEM storage
            } else if (loadPem(transport->url(), pem) && pem == error.certificate().toPem()) {
                qDebug() << "Found a SSL certificate for this host. Ignoring error.";
                ignoredErrors.append(error);

            // Ok... nothing found... Pop up the message
            } else {
                qDebug() << "Host presents an unknown self signed certificate:" << error.certificate();
                qDebug() << "Asking user for confirmation.";

                QStringList info;
                info << tr("Common Name:") << error.certificate().issuerInfo(QSslCertificate::CommonName);
                info << tr("Oragnisation:") <<error.certificate().issuerInfo(QSslCertificate::Organization);
                info << tr("Locality:") << error.certificate().issuerInfo(QSslCertificate::LocalityName);
                info << tr("Oragnisational Unit:")<< error.certificate().issuerInfo(QSslCertificate::OrganizationalUnitName);
                info << tr("Country:")<< error.certificate().issuerInfo(QSslCertificate::CountryName);
//                info << tr("State:")<< error.certificate().issuerInfo(QSslCertificate::StateOrProvinceName);
//                info << tr("Name Qualifier:")<< error.certificate().issuerInfo(QSslCertificate::DistinguishedNameQualifier);
//                info << tr("Email:")<< error.certificate().issuerInfo(QSslCertificate::EmailAddress);

                m_connectionStatus = ConnectionStatusSslUntrusted;
                emit connectionStatusChanged();
                emit verifyConnectionCertificate(transport->url().toString(), info, certificateFingerprint, error.certificate().toPem());
            }
        } else {
            // Reject the connection on all other errors...
            qDebug() << "SSL Error:" << error.errorString() << error.certificate();
        }
    }
    if (ignoredErrors == errors) {
        // Note, due to a workaround in the WebSocketTransport we must not call this
        // unless we've handled all the errors or the websocket will ignore unhandled errors too...
        transport->ignoreSslErrors(ignoredErrors);
    }
}

void NymeaConnection::onError(QAbstractSocket::SocketError error)
{
    QMetaEnum errorEnum = QMetaEnum::fromType<QAbstractSocket::SocketError>();
    QString errorString = errorEnum.valueToKey(error);

    NymeaTransportInterface* transport = qobject_cast<NymeaTransportInterface*>(sender());

    ConnectionStatus errorStatus = ConnectionStatusUnknownError;
    switch (error) {
    case QAbstractSocket::ConnectionRefusedError:
        errorStatus = ConnectionStatusConnectionRefused;
        break;
    case QAbstractSocket::HostNotFoundError:
        errorStatus = ConnectionStatusHostNotFound;
        break;
    case QAbstractSocket::NetworkError:
        errorStatus = ConnectionStatusBearerFailed;
        break;
    case QAbstractSocket::RemoteHostClosedError:
        errorStatus = ConnectionStatusRemoteHostClosed;
        break;
    case QAbstractSocket::SocketTimeoutError:
        errorStatus = ConnectionStatusTimeout;
        break;
    case QAbstractSocket::SslInternalError:
    case QAbstractSocket::SslInvalidUserDataError:
        errorStatus = ConnectionStatusSslError;
        break;
    case QAbstractSocket::SslHandshakeFailedError:
        errorStatus = ConnectionStatusSslUntrusted;
        break;
    default:
        errorStatus = ConnectionStatusUnknownError;
    }

    if (transport == m_currentTransport) {
        qDebug() << "Current transport failed:" << error;
        // The current transport failed, forward the error
        m_connectionStatus = errorStatus;
        emit connectionStatusChanged();
        return;
    }

    if (!m_currentTransport) {
        // We're trying to connect and one of the transports failed...
        if (m_transportCandidates.contains(transport)) {
            m_transportCandidates.remove(transport);
            transport->deleteLater();
        }
        qDebug() << "A transport error happened for" << transport->url() << error << "(Still trying on" << m_transportCandidates.count() << "connections)";
        if (m_transportCandidates.isEmpty()) {
            m_connectionStatus = errorStatus;
            emit connectionStatusChanged();

            if (m_connectionStatus != ConnectionStatusSslUntrusted) {
                QTimer::singleShot(1000, this, [this](){
                    if (m_currentHost) {
                        connectInternal(m_currentHost);
                    }
                });
            }
        }
    }
}

void NymeaConnection::onConnected()
{
    NymeaTransportInterface* newTransport = qobject_cast<NymeaTransportInterface*>(sender());
    if (!m_currentTransport) {
        m_currentTransport = newTransport;
        qDebug() << "NymeaConnection: Connected to" << m_currentHost->name() << "via" << m_currentTransport->url();
        emit connectedChanged(true);
        return;
    }

    if (m_currentTransport != newTransport) {
        qDebug() << "Alternative connection established:" << newTransport->url();

        // In theory, we could roam from one connection to another.
        // However, in practice it turns out there are too many issues for this to be reliable
        // So lets just tear down any alternative connection that comes up again.

        qDebug() << "Dropping alternative connection again...";
        m_transportCandidates.remove(newTransport);
        newTransport->deleteLater();


//        Connection *existingConnection = m_transportCandidates.value(m_currentTransport);
//        Connection *alternativeConnection = m_transportCandidates.value(newTransport);
//        if (alternativeConnection->priority() > existingConnection->priority()) {
//            qDebug() << "New connection has higher priority! Roaming from" << existingConnection->url() << existingConnection->priority() << "to" << alternativeConnection->url() << alternativeConnection->priority();
//            m_transportCandidates.remove(m_currentTransport);
//            m_currentTransport->deleteLater();
//            m_currentTransport = newTransport;
//        } else {
//            qDebug() << "Connection" << alternativeConnection->url() << alternativeConnection->priority() << "has lower priority than existing" << existingConnection->url() << existingConnection->priority();
//            m_transportCandidates.remove(newTransport);
//            newTransport->deleteLater();
//        }
        return;
    }
}

void NymeaConnection::onDisconnected()
{
    NymeaTransportInterface* t = qobject_cast<NymeaTransportInterface*>(sender());
    if (m_currentTransport != t) {
        qWarning() << "NymeaConnection: An inactive transport for url" << t->url() << "disconnected... Cleaning up...";
        if (m_transportCandidates.contains(t)) {
            m_transportCandidates.remove(t);
        }
        t->deleteLater();

        if (!m_currentTransport && m_transportCandidates.isEmpty()) {
            qDebug() << "Last connection dropped.";
            QTimer::singleShot(1000, this, [this](){
                if (m_currentHost && m_connectionStatus != ConnectionStatusSslUntrusted) {
                    qDebug() << "Trying to reconnect..";
                    connectInternal(m_currentHost);
                }
            });
        }

        qDebug() << "Current transport:" << m_currentTransport << "Remaining connections:" << m_transportCandidates.count() << "Current host:" << m_currentHost;
        return;
    }
    m_transportCandidates.remove(m_currentTransport);
    m_currentTransport->deleteLater();
    m_currentTransport = nullptr;

    foreach (NymeaTransportInterface *candidate, m_transportCandidates.keys()) {
        if (candidate->connectionState() == NymeaTransportInterface::ConnectionStateConnected) {
            qDebug() << "Alternative connection is still up. Roaming to:" << candidate->url();
            m_currentTransport = candidate;
            break;
        }
    }

    emit currentConnectionChanged();

    if (!m_currentTransport) {
        qDebug() << "NymeaConnection: disconnected.";
        emit connectedChanged(false);
    }

    if (!m_currentHost) {
        return;
    }

    // Try to reconnect, only if we're not waiting for SSL certs to be trusted.
    if (m_connectionStatus != ConnectionStatusSslUntrusted) {
        QTimer::singleShot(1000, this, [this](){
            if (m_currentHost) {
                connectInternal(m_currentHost);
            }
        });
    }
}

void NymeaConnection::updateActiveBearers()
{
    NymeaConnection::BearerTypes availableBearerTypes;
    QList<QNetworkConfiguration> configs = m_networkConfigManager->allConfigurations(QNetworkConfiguration::Active);
//    qDebug() << "Network configuations:" << configs.count();
    foreach (const QNetworkConfiguration &config, configs) {
//        qDebug() << "Candidate network config:" << config.name() << config.bearerTypeFamily() << config.bearerTypeName();

        // NOTE: iOS doesn't correctly report bearer types. It'll be Unknown all the time. Let's hardcode it to WiFi for that...
#if defined(Q_OS_IOS)
        availableBearerTypes.setFlag(NymeaConnection::BearerTypeWiFi);
#else
        availableBearerTypes.setFlag(qBearerTypeToNymeaBearerType(config.bearerType()));
#endif
    }
//    qDebug() << "Available bearers:" << availableBearerTypes;
    if (m_availableBearerTypes != availableBearerTypes) {
        qDebug() << "Available Bearer Types changed:" << availableBearerTypes;
        m_availableBearerTypes = availableBearerTypes;
        emit availableBearerTypesChanged();
    } else {
        qDebug() << "Available Bearer Types:" << availableBearerTypes;
    }

    if (!m_currentHost) {
        // No host set... Nothing to do...
        qDebug() << "No current host... Nothing to do...";
        return;
    }

    // In theory we could try to connect via any different/new bearers now. However, in practice
    // I have observed the following issues:
    // - When roaming from WiFi to mobile data, we've already lost WiFi at this point
    //   (Unless aggressive WiFi to mobile handover is enabled on the phone)
    // - When roaming from mobile to Wifi, for some reason, any new connection attempts
    //   fail as long as the mobile data isn't shut down by the OS.
    // Those issues prevent roaming from working properly, so let's just not do anything at
    // this point if there already is a connected channel, try reconnecting otherwise.

    if (!m_currentTransport) {
        // There's a host but no connection. Try connecting now...
        qDebug() << "There's a host but no connection. Trying to connect now...";
        connectInternal(m_currentHost);
    }
}


bool NymeaConnection::storePem(const QUrl &host, const QByteArray &pem)
{
    QDir dir(QStandardPaths::writableLocation(QStandardPaths::DataLocation) + "/sslcerts/");
    if (!dir.exists()) {
        dir.mkpath(QStandardPaths::writableLocation(QStandardPaths::DataLocation) + "/sslcerts/");
    }
    QFile certFile(dir.absoluteFilePath(host.host() + ".pem"));
    if (!certFile.open(QFile::WriteOnly)) {
        return false;
    }
    certFile.write(pem);
    certFile.close();
    return true;
}

bool NymeaConnection::loadPem(const QUrl &host, QByteArray &pem)
{
    QDir dir(QStandardPaths::writableLocation(QStandardPaths::DataLocation) + "/sslcerts/");
//    qDebug() << "Loading certificates from:" << dir.absoluteFilePath(host.host() + ".pem");
    QFile certFile(dir.absoluteFilePath(host.host() + ".pem"));
    if (!certFile.open(QFile::ReadOnly)) {
        return false;
    }
    pem.clear();
    pem.append(certFile.readAll());
    return true;
}

void NymeaConnection::registerTransport(NymeaTransportInterfaceFactory *transportFactory)
{
    foreach (const QString &scheme, transportFactory->supportedSchemes()) {
        m_transportFactories[scheme] = transportFactory;
    }
}

void NymeaConnection::connect(NymeaHost *nymeaHost, Connection *connection)
{
    if (!nymeaHost) {
        return;
    }

    m_preferredConnection = nullptr;
    if (connection) {
        if (nymeaHost->connections()->find(connection->url())) {
            qDebug() << "Setting preferred connection to" << connection->url();
            m_preferredConnection = connection;
        } else {
            qWarning() << "Connection" << connection << "is not a candidate for" << nymeaHost->name() << "Not setting preferred connection.";
        }
    }

    setCurrentHost(nymeaHost);
}

void NymeaConnection::connectInternal(NymeaHost *host)
{
    qDebug() << "Connecting. Available bearer types:" << m_availableBearerTypes;
    if (m_availableBearerTypes == NymeaConnection::BearerTypeNone) {
        qDebug() << "No available bearer. Not connecting...";
        m_connectionStatus = ConnectionStatusNoBearerAvailable;
        emit connectionStatusChanged();
        return;
    }

    if (m_preferredConnection) {
        qDebug() << "Preferred connection is set. Using" << m_preferredConnection->url();
        connectInternal(m_preferredConnection);
        return;
    }

    if (m_availableBearerTypes.testFlag(NymeaConnection::BearerTypeWiFi)
            || m_availableBearerTypes.testFlag(NymeaConnection::BearerTypeEthernet)) {
        Connection* lanConnection = host->connections()->bestMatch(Connection::BearerTypeLan | Connection::BearerTypeWan);
        if (lanConnection) {
            qDebug() << "Best candidate LAN/WAN connection:" << lanConnection->url();
            connectInternal(lanConnection);
        } else {
            qDebug() << "No available LAN/WAN connection to" << host->name();
        }
    } else if (m_availableBearerTypes.testFlag(NymeaConnection::BearerTypeMobileData)) {
        Connection* wanConnection = host->connections()->bestMatch(Connection::BearerTypeWan);
        if (wanConnection) {
            qDebug() << "Best candidate WAN connection:" << wanConnection->url();
            connectInternal(wanConnection);
        } else {
            qDebug() << "No available WAN connection to" << host->name();
        }
    }

    Connection* cloudConnection = host->connections()->bestMatch(Connection::BearerTypeCloud);
    if (cloudConnection) {
        qDebug() << "Best candidate Cloud connection:" << cloudConnection->url();
        connectInternal(cloudConnection);
    } else {
        qDebug() << "No available Cloud connection to" << host->name();
    }

    if (m_transportCandidates.isEmpty()) {
        m_connectionStatus = ConnectionStatusNoBearerAvailable;
    } else {
        m_connectionStatus = ConnectionStatusConnecting;
    }
    emit connectionStatusChanged();
}

bool NymeaConnection::connectInternal(Connection *connection)
{
    if (!m_transportFactories.contains(connection->url().scheme())) {
        qWarning() << "Cannot connect to urls of scheme" << connection->url().scheme() << "Supported schemes are" << m_transportFactories.keys();
        return false;
    }

    if (m_transportCandidates.values().contains(connection)) {
        qDebug() << "Already have a connection (or connection attempt) for" << connection->url();
        return false;
    }

    // Create a new transport
    NymeaTransportInterface* newTransport = m_transportFactories.value(connection->url().scheme())->createTransport();
    QObject::connect(newTransport, &NymeaTransportInterface::sslErrors, this, &NymeaConnection::onSslErrors);
    QObject::connect(newTransport, &NymeaTransportInterface::error, this, &NymeaConnection::onError);
    QObject::connect(newTransport, &NymeaTransportInterface::connected, this, &NymeaConnection::onConnected);
    QObject::connect(newTransport, &NymeaTransportInterface::disconnected, this, &NymeaConnection::onDisconnected);
    QObject::connect(newTransport, &NymeaTransportInterface::dataReady, this, &NymeaConnection::dataAvailable);

    // Load any certificate we might have for this url
    QByteArray pem;
    if (loadPem(connection->url(), pem)) {
        qDebug() << "Loaded SSL certificate for" << connection->url().host();
        QList<QSslError> expectedSslErrors;
        expectedSslErrors.append(QSslError::HostNameMismatch);
        expectedSslErrors.append(QSslError(QSslError::SelfSignedCertificate, QSslCertificate(pem)));
        newTransport->ignoreSslErrors(expectedSslErrors);
    }

    m_transportCandidates.insert(newTransport, connection);
    qDebug() << "Connecting to:" << connection->url() << newTransport << m_transportCandidates.value(newTransport);
    return newTransport->connect(connection->url());
}

NymeaConnection::BearerType NymeaConnection::qBearerTypeToNymeaBearerType(QNetworkConfiguration::BearerType type) const
{
    switch (type) {
    case QNetworkConfiguration::BearerUnknown:
        return BearerTypeAll;
    case QNetworkConfiguration::BearerEthernet:
        return BearerTypeEthernet;
    case QNetworkConfiguration::BearerWLAN:
        return BearerTypeWiFi;
    case QNetworkConfiguration::Bearer2G:
    case QNetworkConfiguration::BearerCDMA2000:
    case QNetworkConfiguration::BearerWCDMA:
    case QNetworkConfiguration::BearerHSPA:
    case QNetworkConfiguration::BearerWiMAX:
    case QNetworkConfiguration::BearerEVDO:
    case QNetworkConfiguration::BearerLTE:
    case QNetworkConfiguration::Bearer3G:
    case QNetworkConfiguration::Bearer4G:
        return BearerTypeMobileData;
    case QNetworkConfiguration::BearerBluetooth:
    // Note: Do not confuse this with the Bluetooth transport... For Qt, this means IP over BT, not RFCOMM as we do it.
        return BearerTypeNone;
    }
    return BearerTypeAll;
}

void NymeaConnection::disconnect()
{
    setCurrentHost(nullptr);
}

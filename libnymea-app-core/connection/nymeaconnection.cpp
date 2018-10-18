#include "nymeaconnection.h"

#include <QUrl>
#include <QDebug>
#include <QSslKey>
#include <QUrlQuery>
#include <QSettings>
#include <QMetaEnum>
#include <QStandardPaths>
#include <QFile>
#include <QDir>

#include "nymeatransportinterface.h"

NymeaConnection::NymeaConnection(QObject *parent) : QObject(parent)
{
}

bool NymeaConnection::connect(const QString &url)
{
    if (connected()) {
        qWarning() << "Already connected. Cannot connect multiple times";
        return false;
    }

    m_currentUrl = QUrl(url);
    emit currentUrlChanged();
    if (!m_transports.contains(m_currentUrl.scheme())) {
        qWarning() << "Cannot connect to urls of scheme" << m_currentUrl.scheme() << "Supported schemes are" << m_transports.keys();
        return false;
    }

    // Create a new transport
    m_currentTransport = m_transports.value(m_currentUrl.scheme())->createTransport();
    QObject::connect(m_currentTransport, &NymeaTransportInterface::sslErrors, this, &NymeaConnection::onSslErrors);
    QObject::connect(m_currentTransport, &NymeaTransportInterface::error, this, &NymeaConnection::onError);
    QObject::connect(m_currentTransport, &NymeaTransportInterface::connected, this, &NymeaConnection::onConnected);
    QObject::connect(m_currentTransport, &NymeaTransportInterface::disconnected, this, &NymeaConnection::onDisconnected);
    QObject::connect(m_currentTransport, &NymeaTransportInterface::dataReady, this, &NymeaConnection::dataAvailable);

    // Load any certificate we might have for this url
    QByteArray pem;
    if (loadPem(m_currentUrl, pem)) {
        qDebug() << "Loaded SSL certificate for" << m_currentUrl.host();
        QList<QSslError> expectedSslErrors;
        expectedSslErrors.append(QSslError::HostNameMismatch);
        expectedSslErrors.append(QSslError(QSslError::SelfSignedCertificate, QSslCertificate(pem)));
        m_currentTransport->ignoreSslErrors(expectedSslErrors);
    }

    qDebug() << "Connecting to:" << m_currentUrl;
    return m_currentTransport->connect(m_currentUrl);
}

void NymeaConnection::disconnect()
{
    if (!m_currentTransport || m_currentTransport->connectionState() == NymeaTransportInterface::ConnectionStateDisconnected) {
        qWarning() << "not connected, cannot disconnect";
        return;
    }
    m_currentTransport->disconnect();
}

void NymeaConnection::acceptCertificate(const QString &url, const QByteArray &pem)
{
    storePem(url, pem);
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

bool NymeaConnection::connected()
{
    return m_currentTransport && m_currentTransport->connectionState() == NymeaTransportInterface::ConnectionStateConnected;
}

QString NymeaConnection::url() const
{
    return m_currentUrl.toString();
}

QString NymeaConnection::hostAddress() const
{
    return m_currentUrl.host();
}

int NymeaConnection::port() const
{
    return m_currentUrl.port();
}

QString NymeaConnection::bluetoothAddress() const
{
    QUrlQuery query(m_currentUrl);
    return query.queryItemValue("mac");
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
    qDebug() << "Connection: SSL errors:" << errors;
    QList<QSslError> ignoredErrors;
    foreach (const QSslError &error, errors) {
        if (error.error() == QSslError::HostNameMismatch) {
            qDebug() << "Ignoring host mismatch on certificate.";
            ignoredErrors.append(error);
        } else if (error.error() == QSslError::SelfSignedCertificate || error.error() == QSslError::CertificateUntrusted) {
            qDebug() << "have a self signed certificate." << error.certificate();

            // Check our cert DB
            QByteArray pem;


            // Keep this for compatibility with old versions for a bit...
            // New code will look up the PEM instead and set it before the connection attempt
            // However, we want to emit verifyConnectionCertificate in any case here.
            QSettings settings;
            settings.beginGroup("acceptedCertificates");
            QByteArray storedFingerPrint = settings.value(m_currentUrl.host()).toByteArray();
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
                storePem(m_currentUrl, error.certificate().toPem());

            // Check new style PEM storage
            } else if (loadPem(m_currentUrl, pem) && pem == error.certificate().toPem()) {
                qDebug() << "Found a SSL certificate for this host. Ignoring error.";
                ignoredErrors.append(error);

            // Ok... nothing found... Pop up the message
            } else {
                QStringList info;
                info << tr("Common Name:") << error.certificate().issuerInfo(QSslCertificate::CommonName);
                info << tr("Oragnisation:") <<error.certificate().issuerInfo(QSslCertificate::Organization);
                info << tr("Locality:") << error.certificate().issuerInfo(QSslCertificate::LocalityName);
                info << tr("Oragnisational Unit:")<< error.certificate().issuerInfo(QSslCertificate::OrganizationalUnitName);
                info << tr("Country:")<< error.certificate().issuerInfo(QSslCertificate::CountryName);
//                info << tr("State:")<< error.certificate().issuerInfo(QSslCertificate::StateOrProvinceName);
//                info << tr("Name Qualifier:")<< error.certificate().issuerInfo(QSslCertificate::DistinguishedNameQualifier);
//                info << tr("Email:")<< error.certificate().issuerInfo(QSslCertificate::EmailAddress);

                emit verifyConnectionCertificate(m_currentUrl.toString(), info, certificateFingerprint, error.certificate().toPem());
            }
        } else {
            // Reject the connection on all other errors...
            qDebug() << "SSL Error:" << error.errorString() << error.certificate();
        }
    }
    if (ignoredErrors == errors) {
        // Note, due to a workaround in the WebSocketTransport we must not call this
        // unless we've handled all the errors or the websocket will ignore unhandled errors too...
        m_currentTransport->ignoreSslErrors(ignoredErrors);
    }
}

void NymeaConnection::onError(QAbstractSocket::SocketError error)
{
    QMetaEnum errorEnum = QMetaEnum::fromType<QAbstractSocket::SocketError>();
    emit connectionError(errorEnum.valueToKey(error));
}

void NymeaConnection::onConnected()
{
    if (m_currentTransport != sender()) {
        qWarning() << "NymeaConnection: An inactive transport is emitting signals... ignoring.";
        return;
    }
    qDebug() << "NymeaConnection: connected.";
    emit connectedChanged(true);
}

void NymeaConnection::onDisconnected()
{
    if (m_currentTransport != sender()) {
        qWarning() << "NymeaConnection: An inactive transport is emitting signals... ignoring.";
        return;
    }
    m_currentTransport->deleteLater();
    m_currentTransport = nullptr;
    qDebug() << "NymeaConnection: disconnected.";
    emit connectedChanged(false);
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
        m_transports[scheme] = transportFactory;
    }
}

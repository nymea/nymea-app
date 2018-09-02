#include "nymeaconnection.h"

#include <QUrl>
#include <QDebug>
#include <QSslKey>
#include <QUrlQuery>
#include <QSettings>
#include <QMetaEnum>

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
    if (!m_transports.contains(m_currentUrl.scheme())) {
        qWarning() << "Cannot connect to urls of scheme" << m_currentUrl.scheme() << "Supported schemes are" << m_transports.keys();
        return false;
    }
    m_currentTransport = m_transports.value(m_currentUrl.scheme())->createTransport();

    QObject::connect(m_currentTransport, &NymeaTransportInterface::sslErrors, this, &NymeaConnection::onSslErrors);
    QObject::connect(m_currentTransport, &NymeaTransportInterface::error, this, &NymeaConnection::onError);
    QObject::connect(m_currentTransport, &NymeaTransportInterface::connected, this, &NymeaConnection::onConnected);
    QObject::connect(m_currentTransport, &NymeaTransportInterface::disconnected, this, &NymeaConnection::onDisconnected);

    // signal forwarding
    QObject::connect(m_currentTransport, &NymeaTransportInterface::dataReady, this, &NymeaConnection::dataAvailable);

    qDebug() << "Should connect to url" << m_currentUrl;
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

void NymeaConnection::acceptCertificate(const QString &url, const QByteArray &fingerprint)
{
    QSettings settings;
    settings.beginGroup("acceptedCertificates");
    settings.setValue(QUrl(url).host(), fingerprint);
    settings.endGroup();
}

bool NymeaConnection::isTrusted(const QString &url)
{
    QSettings settings;
    settings.beginGroup("acceptedCertificates");
    return settings.contains(QUrl(url).host());
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
            qDebug() << "have a self signed certificate." << error.certificate() << error.certificate().issuerInfoAttributes();

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

            if (storedFingerPrint == certificateFingerprint) {
                ignoredErrors.append(error);
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

                emit verifyConnectionCertificate(m_currentUrl.toString(), info, certificateFingerprint);
            }
        } else {
            // Reject the connection on all other errors...
            qDebug() << "SSL Error:" << error.errorString() << error.certificate();
        }
    }
    m_currentTransport->ignoreSslErrors(ignoredErrors);
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

void NymeaConnection::registerTransport(NymeaTransportInterfaceFactory *transportFactory)
{
    foreach (const QString &scheme, transportFactory->supportedSchemes()) {
        m_transports[scheme] = transportFactory;
    }
}

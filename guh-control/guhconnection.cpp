#include "guhconnection.h"

#include <QUrl>
#include <QDebug>
#include <QSslKey>
#include <QSettings>

#include "guhinterface.h"
#include "tcpsocketinterface.h"
#include "websocketinterface.h"

GuhConnection::GuhConnection(QObject *parent) : QObject(parent)
{
    GuhInterface *iface = new TcpSocketInterface(this);
    registerInterface(iface);

    iface = new WebsocketInterface(this);
    registerInterface(iface);
}

void GuhConnection::connect(const QString &url)
{
    if (connected()) {
        qWarning() << "Already connected. Cannot connect multiple times";
        return;
    }
    m_currentUrl = QUrl(url);
    m_currentInterface = m_interfaces.value(m_currentUrl.scheme());
    if (!m_currentInterface) {
        qWarning() << "Cannot connect to urls of scheme" << m_currentUrl.scheme() << "Supported schemes are" << m_interfaces.keys();
        return;
    }
    qDebug() << "Should connect to url" << m_currentUrl;
    m_currentInterface->connect(m_currentUrl);
}

void GuhConnection::disconnect()
{
    m_currentInterface->disconnect();
}

void GuhConnection::acceptCertificate(const QByteArray &fingerprint)
{
    QSettings settings;
    settings.beginGroup("acceptedCertificates");
    settings.setValue(m_currentUrl.toString(), fingerprint);
    settings.endGroup();
    connect(m_currentUrl.toString());
}

bool GuhConnection::connected()
{
    return m_currentInterface && m_currentInterface->isConnected();
}

QString GuhConnection::url() const
{
    return m_currentUrl.toString();
}

void GuhConnection::sendData(const QByteArray &data)
{
    if (connected()) {
        qDebug() << "sending data:" << data;
        m_currentInterface->sendData(data);
    } else {
        qWarning() << "Not connected. Cannot send.";
    }
}

void GuhConnection::onSslErrors(const QList<QSslError> &errors)
{
    qDebug() << "ssl errors";
    QList<QSslError> ignoredErrors;
    foreach (const QSslError &error, errors) {
        if (error.error() == QSslError::HostNameMismatch) {
            qDebug() << "Ignoring host mismatch on certificate.";
            ignoredErrors.append(error);
        } else if (error.error() == QSslError::SelfSignedCertificate) {
            qDebug() << "have a self signed certificate." << error.certificate() << error.certificate().issuerInfoAttributes();

            QSettings settings;
            settings.beginGroup("acceptedCertificates");
            QByteArray storedFingerPrint = settings.value(m_currentUrl.toString()).toByteArray();
            settings.endGroup();

            if (storedFingerPrint == error.certificate().digest(QCryptographicHash::Sha256).toBase64()) {
                ignoredErrors.append(error);
            } else {
//                QString cn = error.certificate().issuerInfo(QSslCertificate::CommonName);
                emit verifyConnectionCertificate(error.certificate().issuerInfo(QSslCertificate::CommonName).first(), error.certificate().digest(QCryptographicHash::Sha256).toBase64());
            }
        } else {
            // Reject the connection on all other errors...
            qDebug() << "error:" << error.errorString() << error.certificate();
        }
    }
    m_currentInterface->ignoreSslErrors(ignoredErrors);
}

void GuhConnection::onError(QAbstractSocket::SocketError error)
{
    qWarning() << "socket error" << error;
    emit connectionError();
}

void GuhConnection::onConnected()
{
    if (m_currentInterface != sender()) {
        qWarning() << "An inactive interface is emitting signals... ignoring.";
        return;
    }
    qDebug() << "connected";
    emit connectedChanged(true);
}

void GuhConnection::onDisconnected()
{
    if (m_currentInterface != sender()) {
        qWarning() << "An inactive interface is emitting signals... ignoring.";
        return;
    }
    m_currentInterface = nullptr;
    qDebug() << "disconnected";
    emit connectedChanged(false);
}

void GuhConnection::registerInterface(GuhInterface *iface)
{
    QObject::connect(iface, &GuhInterface::sslErrors, this, &GuhConnection::onSslErrors);
    QObject::connect(iface, &GuhInterface::error, this, &GuhConnection::onError);
    QObject::connect(iface, &GuhInterface::connected, this, &GuhConnection::onConnected);
    QObject::connect(iface, &GuhInterface::disconnected, this, &GuhConnection::onDisconnected);

    // signal forwarding
    QObject::connect(iface, &GuhInterface::dataReady, this, &GuhConnection::dataAvailable);

    foreach (const QString &scheme, iface->supportedSchemes()) {
        m_interfaces[scheme] = iface;
    }
}

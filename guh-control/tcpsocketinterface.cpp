#include "tcpsocketinterface.h"

#include <QUrl>

TcpSocketInterface::TcpSocketInterface(QObject *parent) : GuhInterface(parent)
{
    QObject::connect(&m_socket, &QSslSocket::connected, this, &TcpSocketInterface::onConnected);
    QObject::connect(&m_socket, &QSslSocket::disconnected, this, &TcpSocketInterface::disconnected);
    QObject::connect(&m_socket, &QSslSocket::encrypted, this, &TcpSocketInterface::onEncrypted);
    typedef void (QSslSocket:: *sslErrorsSignal)(const QList<QSslError> &);
    QObject::connect(&m_socket, static_cast<sslErrorsSignal>(&QSslSocket::sslErrors), this, &TcpSocketInterface::sslErrors);
    QObject::connect(&m_socket, &QSslSocket::readyRead, this, &TcpSocketInterface::socketReadyRead);
    typedef void (QSslSocket:: *errorSignal)(QAbstractSocket::SocketError);
    QObject::connect(&m_socket, static_cast<errorSignal>(&QSslSocket::error), this, &TcpSocketInterface::error);
}

QStringList TcpSocketInterface::supportedSchemes() const
{
    return {"guh", "guhs"};
}

void TcpSocketInterface::sendData(const QByteArray &data)
{
    m_socket.write(data);
}

void TcpSocketInterface::ignoreSslErrors(const QList<QSslError> &errors)
{
    m_socket.ignoreSslErrors(errors);
}

void TcpSocketInterface::onConnected()
{
    if (m_url.scheme() == "guh") {
        qDebug() << "TCP socket connected";
        emit connected();
    }
}

void TcpSocketInterface::onEncrypted()
{
    qDebug() << "TCP socket encrypted";
    emit connected();
}

void TcpSocketInterface::connect(const QUrl &url)
{
    m_url = url;
    if (url.scheme() == "guhs") {
        qDebug() << "connecting to" << url.host();
        m_socket.connectToHostEncrypted(url.host(), url.port());
    } else if (url.scheme() == "guh") {
        m_socket.connectToHost(url.host(), url.port());
    } else {
        qWarning() << "Unsupported scheme";
    }
}

bool TcpSocketInterface::isConnected() const
{
    return m_socket.state() == QAbstractSocket::ConnectedState;
}

void TcpSocketInterface::disconnect()
{
    m_socket.disconnectFromHost();
}

void TcpSocketInterface::socketReadyRead()
{
    QByteArray data = m_socket.readAll();
    emit dataReady(data);
}

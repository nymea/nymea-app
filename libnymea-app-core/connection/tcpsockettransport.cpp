#include "tcpsockettransport.h"

#include <QUrl>

TcpSocketTransport::TcpSocketTransport(QObject *parent) : NymeaTransportInterface(parent)
{
    QObject::connect(&m_socket, &QSslSocket::connected, this, &TcpSocketTransport::onConnected);
    QObject::connect(&m_socket, &QSslSocket::encrypted, this, &TcpSocketTransport::onEncrypted);
    typedef void (QSslSocket:: *sslErrorsSignal)(const QList<QSslError> &);
    QObject::connect(&m_socket, static_cast<sslErrorsSignal>(&QSslSocket::sslErrors), this, &TcpSocketTransport::sslErrors);
    QObject::connect(&m_socket, &QSslSocket::readyRead, this, &TcpSocketTransport::socketReadyRead);
    typedef void (QSslSocket:: *errorSignal)(QAbstractSocket::SocketError);
    QObject::connect(&m_socket, static_cast<errorSignal>(&QSslSocket::error), this, &TcpSocketTransport::error);
    QObject::connect(&m_socket, &QSslSocket::stateChanged, this, &TcpSocketTransport::onSocketStateChanged);

}

void TcpSocketTransport::sendData(const QByteArray &data)
{
    qint64 ret = m_socket.write(data);
    if (ret != data.length()) {
        qWarning() << "Error writing data to socket.";
    }
}

void TcpSocketTransport::ignoreSslErrors(const QList<QSslError> &errors)
{
    m_socket.ignoreSslErrors(errors);
}

void TcpSocketTransport::onConnected()
{
    if (m_url.scheme() == "nymea") {
        qDebug() << "TCP socket connected";
        emit connected();
    }
}

void TcpSocketTransport::onEncrypted()
{
    qDebug() << "TCP socket encrypted";
    emit connected();
}

bool TcpSocketTransport::connect(const QUrl &url)
{
    m_url = url;
    if (url.scheme() == "nymeas") {
        qDebug() << "TCP socket connecting to" << url.host() << url.port();
        m_socket.connectToHostEncrypted(url.host(), static_cast<quint16>(url.port()));
        return true;
    } else if (url.scheme() == "nymea") {
        m_socket.connectToHost(url.host(), static_cast<quint16>(url.port()));
        return true;
    }
    qWarning() << "TCP socket: Unsupported scheme";
    return false;
}

QUrl TcpSocketTransport::url() const
{
    return m_url;
}

NymeaTransportInterface::ConnectionState TcpSocketTransport::connectionState() const
{
    switch (m_socket.state()) {
    case QAbstractSocket::ConnectedState:
        return NymeaTransportInterface::ConnectionStateConnected;
    case QAbstractSocket::ConnectingState:
    case QAbstractSocket::HostLookupState:
        return NymeaTransportInterface::ConnectionStateConnecting;
    default:
        return NymeaTransportInterface::ConnectionStateDisconnected;
    }
}

void TcpSocketTransport::disconnect()
{
    qDebug() << "closing socket";
    m_socket.disconnectFromHost();
    m_socket.close();
    // QTcpSocket might endlessly wait for a timeout if we call connectToHost() for an IP which isn't
    // reable at all (e.g. has disappeared from the network). Closing the socket is not enough, we need
    // abort the exiting connection attempts too.
    m_socket.abort();
}

void TcpSocketTransport::socketReadyRead()
{
    QByteArray data = m_socket.readAll();
    emit dataReady(data);
}

void TcpSocketTransport::onSocketStateChanged(const QAbstractSocket::SocketState &state)
{
    qDebug() << "Socket state changed -->" << state;
    if (state == QAbstractSocket::UnconnectedState) {
        emit disconnected();
    }
}

NymeaTransportInterface *TcpSocketTransportFactory::createTransport(QObject *parent) const
{
    return new TcpSocketTransport(parent);
}

QStringList TcpSocketTransportFactory::supportedSchemes() const
{
    return {"nymea", "nymeas"};
}

#include "cloudtransport.h"

#include "awsclient.h"
#include "remoteproxyconnection.h"

#include <QUrlQuery>

using namespace remoteproxyclient;

CloudTransport::CloudTransport(AWSClient *awsClient, QObject *parent):
    NymeaTransportInterface(parent),
    m_awsClient(awsClient)
{
    m_remoteproxyConnection = new RemoteProxyConnection(QUuid::createUuid(), "nymea:app", RemoteProxyConnection::ConnectionTypeWebSocket, this);
    m_remoteproxyConnection->setInsecureConnection(true);

    QObject::connect(m_remoteproxyConnection, &RemoteProxyConnection::connected, this,[this]() {
        qDebug() << "Connected to remote proxy";
    });
    QObject::connect(m_remoteproxyConnection, &RemoteProxyConnection::stateChanged, this,[this](RemoteProxyConnection::State state) {
        qDebug() << "Proxy state changed:" << state;
        if (state == RemoteProxyConnection::StateRemoteConnected) {
            emit connected();
        }
    });
    QObject::connect(m_remoteproxyConnection, &RemoteProxyConnection::ready, this,[this]() {
        qDebug() << "Proxy ready:";
        m_remoteproxyConnection->authenticate(m_token);
    });
    QObject::connect(m_remoteproxyConnection, &RemoteProxyConnection::dataReady, this, [this](const QByteArray &data) {
        qDebug() << "Remote connection data received";
        emit dataReady(data);
    });
}

QStringList CloudTransport::supportedSchemes() const
{
    return {"cloud"};
}

bool CloudTransport::connect(const QUrl &url)
{
    if (!m_awsClient->isLoggedIn()) {
        qWarning() << "Not logged in to AWS, cannot connect";
        return false;
    }
    qDebug() << "Connecting to" << url;

    QUrlQuery query(url.query());
    QString m_token = query.queryItemValue("token");
    m_awsClient->postToMQTT(m_token);

    m_remoteproxyConnection->connectServer(QHostAddress("127.0.0.1"), 1212);

    return true;
}

void CloudTransport::disconnect()
{
    qDebug() << "should disconnect";
}

NymeaTransportInterface::ConnectionState CloudTransport::connectionState() const
{
    switch (m_remoteproxyConnection->state()) {
    case RemoteProxyConnection::StateRemoteConnected:
        return NymeaTransportInterface::ConnectionStateConnected;
    case RemoteProxyConnection::StateInitializing:
    case RemoteProxyConnection::StateConnecting:
    case RemoteProxyConnection::StateConnected:
    case RemoteProxyConnection::StateAuthenticating:
    case RemoteProxyConnection::StateReady:
    case RemoteProxyConnection::StateWaitTunnel:
        return NymeaTransportInterface::ConnectionStateConnecting;
    case RemoteProxyConnection::StateDisconnected:
        return NymeaTransportInterface::ConnectionStateDisconnected;
    }
    return ConnectionStateDisconnected;
}

void CloudTransport::sendData(const QByteArray &data)
{
    qDebug() << "should send" << data;
    m_remoteproxyConnection->sendData(data);
}

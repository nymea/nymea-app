#include "cloudtransport.h"

#include "awsclient.h"
#include "remoteproxyconnection.h"

#include <QUrlQuery>
#include <QHostInfo>

using namespace remoteproxyclient;

CloudTransport::CloudTransport(AWSClient *awsClient, QObject *parent):
    NymeaTransportInterface(parent),
    m_awsClient(awsClient)
{
    m_remoteproxyConnection = new RemoteProxyConnection(QUuid::createUuid(), "nymea:app", this);

    QObject::connect(m_remoteproxyConnection, &RemoteProxyConnection::remoteConnectionEstablished, this,[this]() {
        qDebug() << "CloudTransport: Remote connection established.";
        emit connected();
    });
    QObject::connect(m_remoteproxyConnection, &RemoteProxyConnection::disconnected, this,[this]() {
        qDebug() << "CloudTransport: Disconnected.";
        emit disconnected();
    });

    QObject::connect(m_remoteproxyConnection, &RemoteProxyConnection::stateChanged, this,[](RemoteProxyConnection::State state) {
        qDebug() << "Proxy state changed:" << state;
    });

    QObject::connect(m_remoteproxyConnection, &RemoteProxyConnection::ready, this,[this]() {
        qDebug() << "Proxy ready. Authenticating channel.";
        m_remoteproxyConnection->authenticate(m_awsClient->idToken(), QString::number(m_timestamp.toMSecsSinceEpoch()));
    });
    QObject::connect(m_remoteproxyConnection, &RemoteProxyConnection::dataReady, this, [this](const QByteArray &data) {
        emit dataReady(data);
    });
    QObject::connect(m_remoteproxyConnection, &RemoteProxyConnection::errorOccured, this, [] (QAbstractSocket::SocketError error) {
        qDebug() << "Remote proxy Error:" << error;
//        emit NymeaTransportInterface::error(QAbstractSocket::ConnectionRefusedError);
    });
    QObject::connect(m_remoteproxyConnection, &RemoteProxyConnection::sslErrors, this, &CloudTransport::sslErrors);
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

    m_timestamp = QDateTime::currentDateTime();
    bool postResult = m_awsClient->postToMQTT(url.host(), QString::number(m_timestamp.toMSecsSinceEpoch()), [this](bool success) {
        if (success) {

            m_remoteproxyConnection->connectServer(QUrl("wss://remoteproxy.nymea.io"));
//            m_remoteproxyConnection->connectServer(QUrl("wss://127.0.0.1:1212"));
        }
    });

    if (!postResult) {
        qWarning() << "Failed to post to MQTT. Cannot continue";
        return false;
    }

    return true;
}

void CloudTransport::disconnect()
{
    qDebug() << "CloudTransport: Disconnecting from server.";
    m_remoteproxyConnection->disconnectServer();
}

NymeaTransportInterface::ConnectionState CloudTransport::connectionState() const
{
    switch (m_remoteproxyConnection->state()) {
    case RemoteProxyConnection::StateRemoteConnected:
        return NymeaTransportInterface::ConnectionStateConnected;
    case RemoteProxyConnection::StateInitializing:
    case RemoteProxyConnection::StateHostLookup:
    case RemoteProxyConnection::StateConnecting:
    case RemoteProxyConnection::StateConnected:
    case RemoteProxyConnection::StateAuthenticating:
    case RemoteProxyConnection::StateReady:
    case RemoteProxyConnection::StateAuthenticated:
        return NymeaTransportInterface::ConnectionStateConnecting;
    case RemoteProxyConnection::StateDisconnected:
    case RemoteProxyConnection::StateDiconnecting:
        return NymeaTransportInterface::ConnectionStateDisconnected;
    }
    return ConnectionStateDisconnected;
}

void CloudTransport::sendData(const QByteArray &data)
{
    qDebug() << "should send" << data;
    m_remoteproxyConnection->sendData(data);
}

void CloudTransport::ignoreSslErrors(const QList<QSslError> &errors)
{
    qDebug() << "Ignoring SSL errors" << errors;
    m_remoteproxyConnection->ignoreSslErrors(errors);
}

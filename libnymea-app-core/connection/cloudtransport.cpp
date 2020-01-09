#include "cloudtransport.h"

#include "awsclient.h"
#include "remoteproxyconnection.h"

#include <QUrlQuery>
#include <QHostInfo>
#include <QPointer>

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
        m_remoteproxyConnection->authenticate(m_awsClient->idToken(), m_nonce);
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

bool CloudTransport::connect(const QUrl &url)
{
    if (!m_awsClient->isLoggedIn()) {
        qWarning() << "Not logged in to AWS, cannot connect";
        return false;
    }

    qDebug() << "Connecting to" << url;
    m_url = url;

    m_nonce = QUuid::createUuid().toString();
    bool postResult = m_awsClient->postToMQTT(url.host(), m_nonce, QPointer<QObject>(this), [this](bool success) {
        if (success) {
            qDebug() << "MQTT Post done. Connecting to remote proxy";
            m_remoteproxyConnection->connectServer(QUrl("wss://remoteproxy.nymea.io"));
        } else {
            qDebug() << "Posting to MQTT failed";
            emit error(QAbstractSocket::HostNotFoundError);
        }
    });

    if (!postResult) {
        qWarning() << "Failed to post to MQTT. Cannot continue";
        return false;
    }

    return true;
}

QUrl CloudTransport::url() const
{
    return m_url;
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
//    qDebug() << "Cloud transport: Sending data:" << data;
    m_remoteproxyConnection->sendData(data);
}

void CloudTransport::ignoreSslErrors(const QList<QSslError> &errors)
{
    qDebug() << "CloudTransport: Ignoring SSL errors" << errors;
    m_remoteproxyConnection->ignoreSslErrors(errors);
}

CloudTransportFactory::CloudTransportFactory()
{

}

NymeaTransportInterface *CloudTransportFactory::createTransport(QObject *parent) const
{    
    return new CloudTransport(AWSClient::instance(), parent);
}

QStringList CloudTransportFactory::supportedSchemes() const
{
    return {"cloud"};
}


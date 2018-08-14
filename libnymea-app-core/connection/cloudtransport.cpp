#include "cloudtransport.h"

#include "awsclient.h"
#include "remoteproxyconnection.h"

using namespace remoteproxyclient;

CloudTransport::CloudTransport(AWSClient *awsClient, QObject *parent):
    NymeaTransportInterface(parent),
    m_awsClient(awsClient)
{
    m_remoteproxyConnection = new RemoteProxyConnection(QUuid::createUuid(), "nymea:app", RemoteProxyConnection::ConnectionTypeWebSocket, this);
}

QStringList CloudTransport::supportedSchemes() const
{
    return {"cloud"};
}

void CloudTransport::connect(const QUrl &url)
{
    qDebug() << "should connect to" << url;
    m_awsClient->postToMQTT();

    m_remoteproxyConnection->connectServer(QHostAddress("127.0.0.1"), 1212);

}

void CloudTransport::disconnect()
{
    qDebug() << "should disconnect";
}

NymeaTransportInterface::ConnectionState CloudTransport::connectionState() const
{
    return ConnectionStateDisconnected;
}

void CloudTransport::sendData(const QByteArray &data)
{
    qDebug() << "should send" << data;
}

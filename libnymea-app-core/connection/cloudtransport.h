#ifndef CLOUDTRANSPORT_H
#define CLOUDTRANSPORT_H

#include "nymeatransportinterface.h"

#include <QObject>

class AWSClient;
namespace remoteproxyclient {
class RemoteProxyConnection;
}

class CloudTransport : public NymeaTransportInterface
{
    Q_OBJECT
public:
    explicit CloudTransport(AWSClient *awsClient, QObject *parent = nullptr);

    QStringList supportedSchemes() const override;

    bool connect(const QUrl &url) override;
    void disconnect() override;
    ConnectionState connectionState() const override;
    void sendData(const QByteArray &data) override;

private:
    AWSClient *m_awsClient = nullptr;
    remoteproxyclient::RemoteProxyConnection *m_remoteproxyConnection = nullptr;

    QString m_token;
};

#endif // CLOUDTRANSPORT_H

#ifndef CLOUDTRANSPORT_H
#define CLOUDTRANSPORT_H

#include "nymeatransportinterface.h"

#include <QObject>

class AWSClient;
namespace remoteproxyclient {
class RemoteProxyConnection;
}

class CloudTransportFactory: public NymeaTransportInterfaceFactory
{
public:
    CloudTransportFactory(AWSClient *awsClient);
    NymeaTransportInterface* createTransport(QObject *parent = nullptr) const override;
    QStringList supportedSchemes() const override;
private:
    AWSClient *m_awsClient = nullptr;
};

class CloudTransport : public NymeaTransportInterface
{
    Q_OBJECT
public:
    explicit CloudTransport(AWSClient *awsClient, QObject *parent = nullptr);

    bool connect(const QUrl &url) override;
    void disconnect() override;
    ConnectionState connectionState() const override;
    void sendData(const QByteArray &data) override;

    void ignoreSslErrors(const QList<QSslError> &errors) override;
private:
    AWSClient *m_awsClient = nullptr;
    remoteproxyclient::RemoteProxyConnection *m_remoteproxyConnection = nullptr;
    QDateTime m_timestamp;
};

#endif // CLOUDTRANSPORT_H

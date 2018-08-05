#ifndef CLOUDTRANSPORT_H
#define CLOUDTRANSPORT_H

#include "nymeatransportinterface.h"

#include <QObject>

namespace QMQTT {
class Client;
}
class AWSClient;

class CloudTransport : public NymeaTransportInterface
{
    Q_OBJECT
public:
    explicit CloudTransport(AWSClient *awsClient, QObject *parent = nullptr);

    QStringList supportedSchemes() const override;

    void connect(const QUrl &url) override;
    void disconnect() override;
    ConnectionState connectionState() const override;
    void sendData(const QByteArray &data) override;

private:
    QMQTT::Client *m_mqttClient = nullptr;
    AWSClient *m_awsClient = nullptr;
};

#endif // CLOUDTRANSPORT_H

#include "cloudtransport.h"

#include "qmqtt.h"

CloudTransport::CloudTransport(AWSClient *awsClient, QObject *parent):
    NymeaTransportInterface(parent),
    m_awsClient(awsClient)
{

}

QStringList CloudTransport::supportedSchemes() const
{
    return {"cloud"};
}

void CloudTransport::connect(const QUrl &url)
{
    qDebug() << "should connect to" << url;
    QString date = QDateTime::currentDateTime().toString("yyyyMMddThhmmssZ");
    QString region = "eu-west-1";
    QString service = "iotdevicegateway";
    QString credentialScope = date + '/' + region + '/' + service + '/' + "aws4_request";
    QString algorithm = "AWS4-HMAC-SHA256";
    QString canonicalQuerystring = "X-Amz-Algorithm=" + algorithm;

//    canonicalQuerystring += "&X-Amz-Credential=" + QByteArray(credentials.accessKeyId + '/' + credentialScope).toPercentageEncoded();
//    '&X-Amz-Security-Token=' + encodeURIComponent(credentials.sessionToken);

    QString requestUrl = "wss://a2addxakg5juii.iot.eu-west-1.amazonaws.com/mqtt?" + canonicalQuerystring;
    m_mqttClient = new QMQTT::Client(requestUrl, 443, QWebSocketProtocol::VersionLatest, true, this);

    QObject::connect(m_mqttClient, &QMQTT::Client::connected, this, [](){
        qDebug() << "MQTT connected";
    });
    QObject::connect(m_mqttClient, &QMQTT::Client::disconnected, this, []() {
        qDebug() << "MQTT disconnected";
    });
    QObject::connect(m_mqttClient, &QMQTT::Client::error, this, [](QMQTT::ClientError error) {
        qDebug() << "MQTT error" << error << QMQTT::ClientError::SocketHostNotFoundError;
    });


    m_mqttClient->setUsername("michael.zanetti@guh.io");
    m_mqttClient->setPassword("H22*gemmmmm");
    m_mqttClient->setClientId("8rjhfdlf9jf1suok2jcrltd6v");
    m_mqttClient->connectToHost();
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

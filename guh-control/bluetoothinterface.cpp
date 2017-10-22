#include "bluetoothinterface.h"

#include <QJsonDocument>
#include <QJsonParseError>

BluetoothInterface::BluetoothInterface(QObject *parent) :
    GuhInterface(parent),
    m_socket(0),
    m_discovery(new BluetoothDiscovery(this))
{
    connect(m_discovery, &BluetoothDiscovery::serviceFound, this, &BluetoothInterface::onServiceFound);
}

void BluetoothInterface::sendData(const QByteArray &data)
{
    if (m_socket)
        m_socket->write(data + '\n');
}

void BluetoothInterface::sendRequest(const QVariantMap &request)
{
    sendData(QJsonDocument::fromVariant(request).toJson(QJsonDocument::Compact));
}

BluetoothDiscovery *BluetoothInterface::discovery()
{
    return m_discovery;
}

void BluetoothInterface::enable()
{
    if (m_socket)
        return;

    m_socket = new QBluetoothSocket(QBluetoothServiceInfo::RfcommProtocol);

    connect(m_socket, &QBluetoothSocket::readyRead, this, &BluetoothInterface::onDataReady);
    connect(m_socket, &QBluetoothSocket::connected, this, &BluetoothInterface::onConnected);
    connect(m_socket, &QBluetoothSocket::disconnected, this, &BluetoothInterface::onDisconnected);
}

void BluetoothInterface::disable()
{
    delete m_socket;
    m_socket = 0;
}

void BluetoothInterface::onServiceFound(const QBluetoothServiceInfo &service)
{
    m_service = service;
    enable();

    if (m_socket->isOpen())
        return;

    qDebug() << "Connecting to service"  << m_service.serviceName();
    m_socket->connectToService(m_service);
}

void BluetoothInterface::onConnected()
{
    qDebug() << "Bluetooth Interface: connected" << m_socket->peerName() << m_socket->peerAddress();
    setConnected(true);
}

void BluetoothInterface::onDisconnected()
{
    qDebug() << "Bluetooth Interface: disconnected";
    setConnected(false);
}

void BluetoothInterface::onDataReady()
{
    if (!m_socket)
        return;

    QByteArray message;
    while (m_socket->canReadLine()) {
        QByteArray dataLine = m_socket->readLine();
        message.append(dataLine);
        if (dataLine.endsWith('\n')) {
            QJsonParseError error;
            QJsonDocument jsonDoc = QJsonDocument::fromJson(message, &error);
            if (error.error != QJsonParseError::NoError) {
                qWarning() << "Could not parse json data from guh" << message << error.errorString();
                return;
            }

            emit dataReady(jsonDoc.toVariant().toMap());
            message.clear();
        }
    }
}

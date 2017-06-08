#include "connectionmanager.h"

#include <QState>
#include <QSettings>

ConnectionManager::ConnectionManager(QObject *parent) :
    QObject(parent),
    m_discovery(new UpnpDiscovery(this)),
    m_interface(0),
    m_websocketInterface(new WebsocketInterface(this)),
    m_bluetoothInterface(new BluetoothInterface(this))
{

}

GuhInterface *ConnectionManager::interface()
{
    return m_interface;
}

UpnpDiscovery *ConnectionManager::upnpDiscovery()
{
    return m_discovery;
}

WebsocketInterface *ConnectionManager::websocketInterface()
{
    return m_websocketInterface;
}

BluetoothInterface *ConnectionManager::bluetoothInterface()
{
    return m_bluetoothInterface;
}

QString ConnectionManager::currentInterfaceName() const
{
    return m_currentInterfaceName;
}

QString ConnectionManager::currentStatusMessage() const
{
    return m_currentStatusMessage;
}

void ConnectionManager::setInterface(GuhInterface *interface)
{
    if (m_interface) {
        disconnect(m_interface, &GuhInterface::connectedChanged, this, &ConnectionManager::onConnectedChanged);
        disconnect(m_interface, &GuhInterface::dataReady, this, &ConnectionManager::dataReady);
    }

    m_interface = interface;

    connect(m_interface, &GuhInterface::connectedChanged, this, &ConnectionManager::onConnectedChanged);
    connect(m_interface, &GuhInterface::dataReady, this, &ConnectionManager::dataReady);
    emit interfaceChanged();
}

void ConnectionManager::setCurrentInterfaceName(const QString &name)
{
    m_currentInterfaceName = name;
    emit currentInterfaceNameChanged();
}

void ConnectionManager::setCurrentStatusMessage(const QString &message)
{
    m_currentStatusMessage = message;
    emit currentStatusMessageChanged();
}

void ConnectionManager::onConnectedChanged()
{
    if (m_interface->connected())
        emit connected();
    else
        emit disconnect();

    emit connectedChanged();
}

void ConnectionManager::onConnectingState()
{
    QSettings settings;
    qDebug() << "Loading last connection" << settings.fileName();
    settings.beginGroup("Connections");
    QString url = settings.value("webSocketUrl").toString();
    settings.endGroup();

    if (url.isEmpty()) {
        qDebug() << "No stored websocket url";
        m_websocketInterface->connectionFailed();
    }

    m_websocketInterface->setUrl(url);
    m_websocketInterface->enable();
}

void ConnectionManager::onUpnpDiscoveringState()
{
    upnpDiscovery()->discover();
}

void ConnectionManager::start(const ConnectionType &connectionType)
{
    switch (connectionType) {
    case ConnectionTypeAuto:
        setInterface(m_websocketInterface);
        break;
    case ConnectionTypeWebSocket:
        setInterface(m_websocketInterface);
        m_discovery->discover();
        break;
    case ConnectionTypeCloud:

        break;
    case ConnectionTypeBluetooth:
        setInterface(m_bluetoothInterface);
        break;
    default:
        setInterface(m_bluetoothInterface);
        break;
    }
}

void ConnectionManager::stop()
{
    m_interface->disable();
}

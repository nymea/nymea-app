#include "networkmanager.h"
#include "types/networkdevices.h"
#include "types/networkdevice.h"
#include "types/wirelessaccesspoint.h"
#include "types/wirelessaccesspoints.h"

#include "jsonrpc/jsonrpcclient.h"

#include <QMetaEnum>
#include <QJsonDocument>

NetworkManager::NetworkManager(JsonRpcClient *jsonClient, QObject *parent):
    JsonHandler(parent),
    m_jsonClient(jsonClient),
    m_wiredNetworkDevices(new WiredNetworkDevices(this)),
    m_wirelessNetworkDevices(new WirelessNetworkDevices(this))
{
    m_jsonClient->registerNotificationHandler(this, "notificationReceived");
}

QString NetworkManager::nameSpace() const
{
    return "NetworkManager";
}

void NetworkManager::init()
{
    m_jsonClient->sendCommand("NetworkManager.GetNetworkStatus", QVariantMap(), this, "getStatusReply");
    m_jsonClient->sendCommand("NetworkManager.GetNetworkDevices", QVariantMap(), this, "getDevicesReply");
//    m_jsonClient->sendCommand("NetworkManager.GetWirelessAccessPoints", QVariantMap(), this, "getAccessPointsReply");
}

NetworkManager::NetworkManagerState NetworkManager::state() const
{
    return m_state;
}

bool NetworkManager::networkingEnabled() const
{
    return m_networkingEnabled;
}

bool NetworkManager::wirelessNetworkingEnabled() const
{
    return m_wirelessNetworkingEnabled;
}

WiredNetworkDevices *NetworkManager::wiredNetworkDevices() const
{
    return m_wiredNetworkDevices;
}

WirelessNetworkDevices *NetworkManager::wirelessNetworkDevices() const
{
    return m_wirelessNetworkDevices;
}

void NetworkManager::enableNetworking(bool enable)
{
    QVariantMap params;
    params.insert("enable", enable);
    m_jsonClient->sendCommand("NetworkManager.EnableNetworking", params, this, "enableNetworkingReply");
}

void NetworkManager::enableWirelessNetworking(bool enable)
{
    QVariantMap params;
    params.insert("enable", enable);
    m_jsonClient->sendCommand("NetworkManager.EnableWirelessNetworking", params, this, "enableNetworkingReply");
}

void NetworkManager::refreshWifis(const QString &interface)
{
    QVariantMap params;
    params.insert("interface", interface);
    int requestId = m_jsonClient->sendCommand("NetworkManager.GetWirelessAccessPoints", params, this, "getAccessPointsReply");
    m_apRequests.insert(requestId, interface);
}

void NetworkManager::connectToWiFi(const QString &interface, const QString &ssid, const QString &passphrase)
{
    QVariantMap params;
    params.insert("interface", interface);
    params.insert("ssid", ssid);
    params.insert("password", passphrase);
    m_jsonClient->sendCommand("NetworkManager.ConnectWifiNetwork", params, this, "connectToWiFiReply");
}

void NetworkManager::disconnectInterface(const QString &interface)
{
    QVariantMap params;
    params.insert("interface", interface);
    m_jsonClient->sendCommand("NetworkManager.DisconnectInterface", params, this, "disconnectReply");
}

void NetworkManager::getStatusReply(const QVariantMap &params)
{
//    qDebug() << "NetworkManager reply" << qUtf8Printable(QJsonDocument::fromVariant(params).toJson(QJsonDocument::Indented));

    QVariantMap statusMap = params.value("params").toMap().value("status").toMap();

    QMetaEnum stateEnum = QMetaEnum::fromType<NetworkManager::NetworkManagerState>();
    NetworkManagerState state = static_cast<NetworkManager::NetworkManagerState>(stateEnum.keyToValue(params.value("params").toMap().value("status").toMap().value("state").toString().toUtf8()));
    if (m_state != state) {
        m_state = state;
        emit stateChanged();
    }

    bool networkingEnabled = statusMap.value("networkingEnabled").toBool();
    if (m_networkingEnabled != networkingEnabled) {
        m_networkingEnabled = networkingEnabled;
        emit networkingEnabledChanged();
    }
    bool wirelessNetworkingEnabled = statusMap.value("wirelessNetworkingEnabled").toBool();
    if (m_wirelessNetworkingEnabled != wirelessNetworkingEnabled) {
        m_wirelessNetworkingEnabled = wirelessNetworkingEnabled;
        emit wirelessNetworkingEnabledChanged();
    }
}

void NetworkManager::getDevicesReply(const QVariantMap &params)
{
//    qDebug() << "Devices reply" << qUtf8Printable(QJsonDocument::fromVariant(params).toJson(QJsonDocument::Indented));

    foreach (const QVariant &deviceVariant, params.value("params").toMap().value("wiredNetworkDevices").toList()) {
        QVariantMap deviceMap = deviceVariant.toMap();
        WiredNetworkDevice *device = new WiredNetworkDevice(deviceMap.value("macAddress").toString(), deviceMap.value("interface").toString(), this);
        device->setBitRate(deviceMap.value("bitRate").toString());
        QMetaEnum stateEnum = QMetaEnum::fromType<NetworkDevice::NetworkDeviceState>();
        device->setState(static_cast<NetworkDevice::NetworkDeviceState>(stateEnum.keyToValue(deviceMap.value("state").toString().toUtf8())));
        device->setPluggedIn(deviceMap.value("pluggedIn").toBool());
        m_wiredNetworkDevices->addNetworkDevice(device);
    }
    foreach (const QVariant &deviceVariant, params.value("params").toMap().value("wirelessNetworkDevices").toList()) {
        QVariantMap deviceMap = deviceVariant.toMap();
        WirelessNetworkDevice *device = new WirelessNetworkDevice(deviceMap.value("macAddress").toString(), deviceMap.value("interface").toString(), this);
        device->setBitRate(deviceMap.value("bitRate").toString());
        QMetaEnum stateEnum = QMetaEnum::fromType<NetworkDevice::NetworkDeviceState>();
        device->setState(static_cast<NetworkDevice::NetworkDeviceState>(stateEnum.keyToValue(deviceMap.value("state").toString().toUtf8())));

        QVariantMap currentApMap = deviceMap.value("currentAccessPoint").toMap();
        device->currentAccessPoint()->setSsid(currentApMap.value("ssid").toString());
        device->currentAccessPoint()->setMacAddress(currentApMap.value("macAddress").toString());
        device->currentAccessPoint()->setProtected(currentApMap.value("protected").toBool());
        device->currentAccessPoint()->setSignalStrength(currentApMap.value("signalStrength").toInt());
        m_wirelessNetworkDevices->addNetworkDevice(device);
    }
}

void NetworkManager::getAccessPointsReply(const QVariantMap &params)
{
    qDebug() << "Access points reply" << qUtf8Printable(QJsonDocument::fromVariant(params).toJson(QJsonDocument::Indented));

    int requestId = params.value("id").toInt();
    if (!m_apRequests.contains(requestId)) {
        qWarning() << "NetworkManager received a reply for a request we don't know!";
        return;
    }
    QString interface = m_apRequests.take(requestId);

    WirelessNetworkDevice *dev = m_wirelessNetworkDevices->getWirelessNetworkDevice(interface);
    if (!dev) {
        qWarning() << "NetworkManager received wifi list for" << interface << "but device disappeared";
        return;
    }

    dev->accessPoints()->clearModel();

    foreach (const QVariant &apVariant, params.value("params").toMap().value("wirelessAccessPoints").toList()) {
        QVariantMap apMap = apVariant.toMap();
        WirelessAccessPoint* ap = new WirelessAccessPoint(this);
        ap->setMacAddress(apMap.value("macAddress").toString());
        ap->setSsid(apMap.value("ssid").toString());
        ap->setProtected(apMap.value("protected").toBool());
        ap->setSignalStrength(apMap.value("signalStrength").toInt());
        dev->accessPoints()->addWirelessAccessPoint(ap);
    }

}

void NetworkManager::connectToWiFiReply(const QVariantMap &params)
{
    qDebug() << "connect to wifi reply" << qUtf8Printable(QJsonDocument::fromVariant(params).toJson(QJsonDocument::Indented));
}

void NetworkManager::disconnectReply(const QVariantMap &params)
{
    qDebug() << "disconnect reply" << qUtf8Printable(QJsonDocument::fromVariant(params).toJson(QJsonDocument::Indented));
}

void NetworkManager::enableNetworkingReply(const QVariantMap &params)
{
    qDebug() << "enable networking reply" << qUtf8Printable(QJsonDocument::fromVariant(params).toJson(QJsonDocument::Indented));
}

void NetworkManager::notificationReceived(const QVariantMap &params)
{
    QString notification = params.value("notification").toString();
    if (notification == "NetworkManager.WirelessNetworkDeviceChanged") {
        QVariantMap deviceMap = params.value("params").toMap().value("wirelessNetworkDevice").toMap();
        WirelessNetworkDevice* device = m_wirelessNetworkDevices->getWirelessNetworkDevice(deviceMap.value("interface").toString());
        if (!device) {
            qWarning() << "Received a notification for a WiFi device we don't know" << deviceMap;
            return;
        }
        device->setBitRate(deviceMap.value("bitRate").toString());
        QMetaEnum stateEnum = QMetaEnum::fromType<NetworkDevice::NetworkDeviceState>();
        device->setState(static_cast<NetworkDevice::NetworkDeviceState>(stateEnum.keyToValue(deviceMap.value("state").toString().toUtf8())));

        QVariantMap currentApMap = deviceMap.value("currentAccessPoint").toMap();
        device->currentAccessPoint()->setSsid(currentApMap.value("ssid").toString());
        device->currentAccessPoint()->setMacAddress(currentApMap.value("macAddress").toString());
        device->currentAccessPoint()->setProtected(currentApMap.value("protected").toBool());
        device->currentAccessPoint()->setSignalStrength(currentApMap.value("signalStrength").toInt());
    } else if (notification == "NetworkManager.NetworkStatusChanged") {
        QMetaEnum stateEnum = QMetaEnum::fromType<NetworkManager::NetworkManagerState>();
        NetworkManagerState state = static_cast<NetworkManager::NetworkManagerState>(stateEnum.keyToValue(params.value("params").toMap().value("status").toMap().value("state").toString().toUtf8()));
        bool networkingEnabled = params.value("params").toMap().value("status").toMap().value("networkingEnabled").toBool();
        bool wirelessNetworkingEnabled = params.value("params").toMap().value("status").toMap().value("wirelessNetworkingEnabled").toBool();
        if (m_state != state) {
            m_state = state;
            emit stateChanged();
        }
        if (m_networkingEnabled != networkingEnabled) {
            m_networkingEnabled = networkingEnabled;
            emit networkingEnabledChanged();
        }
        if (m_wirelessNetworkingEnabled != wirelessNetworkingEnabled) {
            m_wirelessNetworkingEnabled = wirelessNetworkingEnabled;
            emit wirelessNetworkingEnabledChanged();
        }

    } else {
        qDebug() << "notification received" << qUtf8Printable(QJsonDocument::fromVariant(params).toJson(QJsonDocument::Indented));
    }
}

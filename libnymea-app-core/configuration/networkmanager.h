#ifndef NETWORKMANAGER_H
#define NETWORKMANAGER_H

#include <QObject>
#include <QHash>

#include "jsonrpc/jsonhandler.h"

class JsonRpcClient;
class NetworkDevices;
class WiredNetworkDevices;
class WirelessNetworkDevices;

class NetworkManager : public JsonHandler
{
    Q_OBJECT
    Q_PROPERTY(NetworkManagerState state READ state NOTIFY stateChanged)
    Q_PROPERTY(bool networkingEnabled READ networkingEnabled NOTIFY networkingEnabledChanged)
    Q_PROPERTY(bool wirelessNetworkingEnabled READ wirelessNetworkingEnabled NOTIFY wirelessNetworkingEnabledChanged)

    Q_PROPERTY(WiredNetworkDevices* wiredNetworkDevices READ wiredNetworkDevices CONSTANT)
    Q_PROPERTY(WirelessNetworkDevices* wirelessNetworkDevices READ wirelessNetworkDevices CONSTANT)

public:
    enum NetworkManagerState {
        NetworkManagerStateUnknown = 0,
        NetworkManagerStateAsleep = 10,
        NetworkManagerStateDisconnected = 20,
        NetworkManagerStateDisconnecting = 30,
        NetworkManagerStateConnecting = 40,
        NetworkManagerStateConnectedLocal = 50,
        NetworkManagerStateConnectedSite = 60,
        NetworkManagerStateConnectedGlobal = 70
    };
    Q_ENUM(NetworkManagerState)

    explicit NetworkManager(JsonRpcClient *jsonClient, QObject *parent = nullptr);

    QString nameSpace() const override;

    void init();

    NetworkManagerState state() const;
    bool networkingEnabled() const;
    bool wirelessNetworkingEnabled() const;

    WiredNetworkDevices* wiredNetworkDevices() const;
    WirelessNetworkDevices* wirelessNetworkDevices() const;

    Q_INVOKABLE void enableNetworking(bool enable);
    Q_INVOKABLE void enableWirelessNetworking(bool enable);

    Q_INVOKABLE void refreshWifis(const QString &interface);

    Q_INVOKABLE void connectToWiFi(const QString &interface, const QString &ssid, const QString &passphrase);
    Q_INVOKABLE void disconnectInterface(const QString &interface);

private slots:
    void getStatusReply(const QVariantMap &params);
    void getDevicesReply(const QVariantMap &params);
    void getAccessPointsReply(const QVariantMap &params);
    void connectToWiFiReply(const QVariantMap &params);
    void disconnectReply(const QVariantMap &params);
    void enableNetworkingReply(const QVariantMap &params);

    void notificationReceived(const QVariantMap &params);

signals:
    void stateChanged();
    void networkingEnabledChanged();
    void wirelessNetworkingEnabledChanged();

private:
    JsonRpcClient *m_jsonClient = nullptr;

    NetworkManagerState m_state = NetworkManagerStateUnknown;
    bool m_networkingEnabled = false;
    bool m_wirelessNetworkingEnabled = false;

    WiredNetworkDevices* m_wiredNetworkDevices = nullptr;
    WirelessNetworkDevices* m_wirelessNetworkDevices = nullptr;

    QHash<int, QString> m_apRequests; // requestId, interface
};

#endif // NETWORKMANAGER_H

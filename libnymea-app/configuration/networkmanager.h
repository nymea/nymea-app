// SPDX-License-Identifier: LGPL-3.0-or-later

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
* Copyright (C) 2013 - 2024, nymea GmbH
* Copyright (C) 2024 - 2025, chargebyte austria GmbH
*
* This file is part of libnymea-app.
*
* libnymea-app is free software: you can redistribute it and/or
* modify it under the terms of the GNU Lesser General Public License
* as published by the Free Software Foundation, either version 3
* of the License, or (at your option) any later version.
*
* libnymea-app is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
* GNU Lesser General Public License for more details.
*
* You should have received a copy of the GNU Lesser General Public License
* along with libnymea-app. If not, see <https://www.gnu.org/licenses/>.
*
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#ifndef NETWORKMANAGER_H
#define NETWORKMANAGER_H

#include <QObject>
#include <QHash>

class Engine;
class NetworkDevices;
class WiredNetworkDevices;
class WirelessNetworkDevices;

class NetworkManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(Engine *engine READ engine WRITE setEngine NOTIFY engineChanged)

    Q_PROPERTY(bool loading READ loading NOTIFY loadingChanged)
    Q_PROPERTY(bool available READ available NOTIFY availableChanged)

    Q_PROPERTY(NetworkManagerState state READ state NOTIFY stateChanged)
    Q_PROPERTY(bool networkingEnabled READ networkingEnabled NOTIFY networkingEnabledChanged)
    Q_PROPERTY(bool wirelessNetworkingEnabled READ wirelessNetworkingEnabled NOTIFY wirelessNetworkingEnabledChanged)

    Q_PROPERTY(WiredNetworkDevices *wiredNetworkDevices READ wiredNetworkDevices CONSTANT)
    Q_PROPERTY(WirelessNetworkDevices *wirelessNetworkDevices READ wirelessNetworkDevices CONSTANT)

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

    explicit NetworkManager(QObject *parent = nullptr);
    ~NetworkManager();

    void setEngine(Engine *engine);
    Engine *engine() const;

    bool loading();

    bool available() const;
    NetworkManagerState state() const;
    bool networkingEnabled() const;
    bool wirelessNetworkingEnabled() const;

    WiredNetworkDevices *wiredNetworkDevices() const;
    WirelessNetworkDevices *wirelessNetworkDevices() const;

    Q_INVOKABLE int enableNetworking(bool enable);
    Q_INVOKABLE int enableWirelessNetworking(bool enable);

    Q_INVOKABLE void refreshWifis(const QString &interface);

    Q_INVOKABLE int connectToWiFi(const QString &interface, const QString &ssid, const QString &passphrase);
    Q_INVOKABLE int startAccessPoint(const QString &interface, const QString &ssid, const QString &passphrase);
    Q_INVOKABLE int createWiredAutoConnection(const QString &interface);
    Q_INVOKABLE int createWiredManualConnection(const QString &interface, const QString &ip, quint8 prefix, const QString &gateway, const QString &dns);
    Q_INVOKABLE int createWiredSharedConnection(const QString &interface, const QString &ip = QString(), quint8 prefix = 24);
    Q_INVOKABLE int disconnectInterface(const QString &interface);

signals:
    void engineChanged();
    void loadingChanged();
    void availableChanged();
    void stateChanged();
    void networkingEnabledChanged();
    void wirelessNetworkingEnabledChanged();

    void enableNetworkingReply(int id, const QString &status);
    void enableWirelessNetworkingReply(int id, const QString &status);
    void connectToWiFiReply(int id, const QString &status);
    void disconnectReply(int id, const QString &status);
    void startAccessPointReply(int id, const QString &status);
    void createWiredAutoConnectionReply(int id, const QString &status);
    void createWiredManualConnectionReply(int id, const QString &status);
    void createWiredSharedConnectionReply(int id, const QString &status);

private slots:
    void init();

    void getStatusResponse(int commandId, const QVariantMap &params);
    void getDevicesResponse(int commandId, const QVariantMap &params);
    void getAccessPointsResponse(int commandId, const QVariantMap &params);
    void connectToWiFiResponse(int commandId, const QVariantMap &params);
    void disconnectResponse(int commandId, const QVariantMap &params);
    void enableNetworkingResponse(int commandId, const QVariantMap &params);
    void enableWirelessNetworkingResponse(int commandId, const QVariantMap &params);
    void startAccessPointResponse(int commandId, const QVariantMap &params);
    void createWiredAutoConnectionResponse(int commandId, const QVariantMap &params);
    void createWiredManualConnectionResponse(int commandId, const QVariantMap &params);
    void createWiredSharedConnectionResponse(int commandId, const QVariantMap &params);

    void notificationReceived(const QVariantMap &params);

private:
    Engine *m_engine = nullptr;
    bool m_loading = false;
    bool m_available = false;
    NetworkManagerState m_state = NetworkManagerStateUnknown;
    bool m_networkingEnabled = false;
    bool m_wirelessNetworkingEnabled = false;

    WiredNetworkDevices *m_wiredNetworkDevices = nullptr;
    WirelessNetworkDevices *m_wirelessNetworkDevices = nullptr;

    QHash<int, QString> m_apRequests; // requestId, interface
};

#endif // NETWORKMANAGER_H

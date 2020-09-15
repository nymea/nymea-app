/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
* Copyright 2013 - 2020, nymea GmbH
* Contact: contact@nymea.io
*
* This file is part of nymea.
* This project including source code and documentation is protected by
* copyright law, and remains the property of nymea GmbH. All rights, including
* reproduction, publication, editing and translation, are reserved. The use of
* this project is subject to the terms of a license agreement to be concluded
* with nymea GmbH in accordance with the terms of use of nymea GmbH, available
* under https://nymea.io/license
*
* GNU General Public License Usage
* Alternatively, this project may be redistributed and/or modified under the
* terms of the GNU General Public License as published by the Free Software
* Foundation, GNU version 3. This project is distributed in the hope that it
* will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty
* of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
* Public License for more details.
*
* You should have received a copy of the GNU General Public License along with
* this project. If not, see <https://www.gnu.org/licenses/>.
*
* For any further details and any questions please contact us under
* contact@nymea.io or see our FAQ/Licensing Information on
* https://nymea.io/license/faq
*
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#ifndef NETWORKMANAGER_H
#define NETWORKMANAGER_H

#include <QObject>
#include <QHash>

#include "jsonrpc/jsonhandler.h"

class Engine;
class NetworkDevices;
class WiredNetworkDevices;
class WirelessNetworkDevices;

class NetworkManager : public JsonHandler
{
    Q_OBJECT
    Q_PROPERTY(Engine *engine READ engine WRITE setEngine NOTIFY engineChanged)

    Q_PROPERTY(bool loading READ loading NOTIFY loadingChanged)
    Q_PROPERTY(bool available READ available NOTIFY availableChanged)

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

    explicit NetworkManager(QObject *parent = nullptr);
    ~NetworkManager();

    void setEngine(Engine *engine);
    Engine *engine() const;

    bool loading();

    QString nameSpace() const override;

    bool available() const;
    NetworkManagerState state() const;
    bool networkingEnabled() const;
    bool wirelessNetworkingEnabled() const;

    WiredNetworkDevices* wiredNetworkDevices() const;
    WirelessNetworkDevices* wirelessNetworkDevices() const;

    Q_INVOKABLE int enableNetworking(bool enable);
    Q_INVOKABLE int enableWirelessNetworking(bool enable);

    Q_INVOKABLE void refreshWifis(const QString &interface);

    Q_INVOKABLE int connectToWiFi(const QString &interface, const QString &ssid, const QString &passphrase);
    Q_INVOKABLE int startAccessPoint(const QString &interface, const QString &ssid, const QString &passphrase);
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

    void notificationReceived(const QVariantMap &params);

private:
    Engine *m_engine = nullptr;
    bool m_loading = false;
    bool m_available = false;
    NetworkManagerState m_state = NetworkManagerStateUnknown;
    bool m_networkingEnabled = false;
    bool m_wirelessNetworkingEnabled = false;

    WiredNetworkDevices* m_wiredNetworkDevices = nullptr;
    WirelessNetworkDevices* m_wirelessNetworkDevices = nullptr;

    QHash<int, QString> m_apRequests; // requestId, interface
};

#endif // NETWORKMANAGER_H

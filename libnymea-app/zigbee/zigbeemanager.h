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

#ifndef ZIGBEEMANAGER_H
#define ZIGBEEMANAGER_H

#include <QObject>
#include "zigbeeadapter.h"

class Engine;
class JsonRpcClient;
class ZigbeeAdapters;
class ZigbeeNetwork;
class ZigbeeNetworks;
class ZigbeeNode;
class ZigbeeNodes;

class ZigbeeManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(Engine* engine READ engine WRITE setEngine NOTIFY engineChanged)

    Q_PROPERTY(QStringList availableBackends READ availableBackends NOTIFY availableBackendsChanged)
    Q_PROPERTY(ZigbeeAdapters *adapters READ adapters CONSTANT)
    Q_PROPERTY(ZigbeeNetworks *networks READ networks CONSTANT)

public:
    enum ZigbeeChannel {
        ZigbeeChannel11 = 0x00000800,
        ZigbeeChannel12 = 0x00001000,
        ZigbeeChannel13 = 0x00002000,
        ZigbeeChannel14 = 0x00004000,
        ZigbeeChannel15 = 0x00008000,
        ZigbeeChannel16 = 0x00010000,
        ZigbeeChannel17 = 0x00020000,
        ZigbeeChannel18 = 0x00040000,
        ZigbeeChannel19 = 0x00080000,
        ZigbeeChannel20 = 0x00100000,
        ZigbeeChannel21 = 0x00200000,
        ZigbeeChannel22 = 0x00400000,
        ZigbeeChannel23 = 0x00800000,
        ZigbeeChannel24 = 0x01000000,
        ZigbeeChannel25 = 0x02000000,
        ZigbeeChannel26 = 0x04000000,
        ZigbeeChannelPrimaryLightLink = 0x02108800,
        ZigbeeChannelAll = 0x07fff800
    };
    Q_DECLARE_FLAGS(ZigbeeChannels, ZigbeeChannel)
    Q_FLAG(ZigbeeChannels)

    explicit ZigbeeManager(QObject *parent = nullptr);
    ~ZigbeeManager();

    void setEngine(Engine *engine);
    Engine *engine() const;

    QStringList availableBackends() const;
    ZigbeeAdapters *adapters() const;
    ZigbeeNetworks *networks() const;

    // Network
    Q_INVOKABLE int addNetwork(const QString &serialPort, uint baudRate, const QString &backend, ZigbeeChannels channels);
    Q_INVOKABLE void removeNetwork(const QUuid &networkUuid);
    Q_INVOKABLE void setPermitJoin(const QUuid &networkUuid, uint duration = 120);
    Q_INVOKABLE void factoryResetNetwork(const QUuid &networkUuid);
    Q_INVOKABLE void getNodes(const QUuid &networkUuid);
    Q_INVOKABLE int removeNode(const QUuid &networkUuid, const QString &ieeeAddress);

signals:
    void engineChanged();
    void availableBackendsChanged();
    void addNetworkReply(int commandId, const QString &error, const QUuid &networkUuid);
    void removeNodeReply(int commandId, const QString &error);

private:
    void init();

    Q_INVOKABLE void getAvailableBackendsResponse(int commandId, const QVariantMap &params);
    Q_INVOKABLE void getAdaptersResponse(int commandId, const QVariantMap &params);
    Q_INVOKABLE void getNetworksResponse(int commandId, const QVariantMap &params);

    Q_INVOKABLE void addNetworkResponse(int commandId, const QVariantMap &params);
    Q_INVOKABLE void removeNetworkResponse(int commandId, const QVariantMap &params);
    Q_INVOKABLE void setPermitJoinResponse(int commandId, const QVariantMap &params);
    Q_INVOKABLE void factoryResetNetworkResponse(int commandId, const QVariantMap &params);

    Q_INVOKABLE void getNodesResponse(int commandId, const QVariantMap &params);
    Q_INVOKABLE void removeNodeResponse(int commandId, const QVariantMap &params);

    Q_INVOKABLE void notificationReceived(const QVariantMap &notification);

private:
    Engine* m_engine = nullptr;
    QStringList m_availableBackends;
    ZigbeeAdapters *m_adapters = nullptr;
    ZigbeeNetworks *m_networks = nullptr;

    ZigbeeAdapter *unpackAdapter(const QVariantMap &adapterMap);
    ZigbeeNetwork *unpackNetwork(const QVariantMap &networkMap);
    ZigbeeNode *unpackNode(const QVariantMap &nodeMap);

    void fillNetworkData(ZigbeeNetwork *network, const QVariantMap &networkMap);
    void addOrUpdateNode(ZigbeeNetwork *network, const QVariantMap &nodeMap);
};

#endif // ZIGBEEMANAGER_H

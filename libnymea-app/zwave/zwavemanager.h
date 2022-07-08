/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
* Copyright 2013 - 2022, nymea GmbH
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

#ifndef ZWAVEMANAGER_H
#define ZWAVEMANAGER_H

#include <QObject>
#include <QHash>

class Engine;
class JsonRpcClient;
class SerialPorts;
class ZWaveNetwork;
class ZWaveNetworks;
class ZWaveNode;

class ZWaveManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(Engine* engine READ engine WRITE setEngine NOTIFY engineChanged)
    Q_PROPERTY(bool fetchingData READ fetchingData NOTIFY fetchingDataChanged)

    Q_PROPERTY(SerialPorts *serialPorts READ serialPorts CONSTANT)
    Q_PROPERTY(ZWaveNetworks *networks READ networks CONSTANT)

public:
    enum ZWaveError {
        ZWaveErrorNoError,
        ZWaveErrorInUse,
        ZWaveErrorNetworkUuidNotFound,
        ZWaveErrorNodeIdNotFound,
        ZWaveErrorTimeout,
        ZWaveErrorBackendError
    };
    Q_ENUM(ZWaveError)

    explicit ZWaveManager(QObject *parent = nullptr);
    ~ZWaveManager();

    void setEngine(Engine *engine);
    Engine *engine() const;

    bool fetchingData() const;

    SerialPorts *serialPorts() const;
    ZWaveNetworks *networks() const;

    Q_INVOKABLE int addNetwork(const QString &serialPort);
    Q_INVOKABLE int removeNetwork(const QUuid &networkUuid);
    Q_INVOKABLE void addNode(const QUuid &networkUuid);
    Q_INVOKABLE void cancelPendingOperation(const QUuid &networkUuid);
    Q_INVOKABLE int softResetController(const QUuid &networkUuid);
    Q_INVOKABLE int factoryResetNetwork(const QUuid &networkUuid);
//    Q_INVOKABLE void getNodes(const QUuid &networkUuid);
    Q_INVOKABLE int removeNode(const QUuid &networkUuid);
    Q_INVOKABLE int removeFailedNode(const QUuid &networkUuid, int nodeId);

signals:
    void engineChanged();
    void fetchingDataChanged();
    void addNetworkReply(int commandId, ZWaveManager::ZWaveError error, const QUuid &networkUuid);
    void removeNetworkReply(int commandId, ZWaveManager::ZWaveError error);
    void cancelPendingOperationReply(int commandId, ZWaveManager::ZWaveError error);
    void softResetControllerReply(int commandId, ZWaveManager::ZWaveError error);
    void factoryResetNetworkReply(int commandId, ZWaveManager::ZWaveError error);
    void addNodeReply(int commandId, ZWaveManager::ZWaveError error);
    void removeNodeReply(int commandId, ZWaveManager::ZWaveError error);
    void removeFailedNodeReply(int commandId, ZWaveManager::ZWaveError error);

private:
    void init();

    Q_INVOKABLE void getSerialPortsResponse(int commandId, const QVariantMap &params);
    Q_INVOKABLE void getNetworksResponse(int commandId, const QVariantMap &params);
    Q_INVOKABLE void getNodesResponse(int commandId, const QVariantMap &params);

    Q_INVOKABLE void addNetworkResponse(int commandId, const QVariantMap &params);
    Q_INVOKABLE void removeNetworkResponse(int commandId, const QVariantMap &params);
    Q_INVOKABLE void cancelPendingOperationResponse(int commandId, const QVariantMap &params);
    Q_INVOKABLE void softResetControllerResponse(int commandId, const QVariantMap &params);
    Q_INVOKABLE void factoryResetNetworkResponse(int commandId, const QVariantMap &params);

    Q_INVOKABLE void addNodeResponse(int commandId, const QVariantMap &params);
    Q_INVOKABLE void removeNodeResponse(int commandId, const QVariantMap &params);
    Q_INVOKABLE void removeFailedNodeResponse(int commandId, const QVariantMap &params);

    Q_INVOKABLE void notificationReceived(const QVariantMap &data);

private:
    Engine* m_engine = nullptr;
    bool m_fetchingData = false;
    SerialPorts *m_serialPorts = nullptr;
    ZWaveNetworks *m_networks = nullptr;

    QHash<int, QUuid> m_pendingGetNodeCalls;

    ZWaveNetwork *unpackNetwork(const QVariantMap &networkMap, ZWaveNetwork *network = nullptr);
    ZWaveNode *unpackNode(const QVariantMap &nodeMap, ZWaveNode *node = nullptr);

};

#endif // ZWAVEMANAGER_H

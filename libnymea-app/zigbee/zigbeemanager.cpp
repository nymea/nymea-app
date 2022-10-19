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

#include "zigbeemanager.h"

#include <QMetaEnum>
#include <QJsonDocument>

#include "engine.h"
#include "logging.h"
#include "jsonrpc/jsonrpcclient.h"
#include "zigbee/zigbeeadapter.h"
#include "zigbee/zigbeeadapters.h"
#include "zigbee/zigbeenetwork.h"
#include "zigbee/zigbeenetworks.h"
#include "zigbee/zigbeenode.h"
#include "zigbee/zigbeenodes.h"

NYMEA_LOGGING_CATEGORY(dcZigbee, "Zigbee")

ZigbeeManager::ZigbeeManager(QObject *parent) :
    QObject(parent),
    m_adapters(new ZigbeeAdapters(this)),
    m_networks(new ZigbeeNetworks(this))
{

}

ZigbeeManager::~ZigbeeManager()
{
    if (m_engine) {
        m_engine->jsonRpcClient()->unregisterNotificationHandler(this);
    }
}

void ZigbeeManager::setEngine(Engine *engine)
{
    if (m_engine != engine) {

        if (m_engine) {
            m_engine->jsonRpcClient()->unregisterNotificationHandler(this);
        }

        m_engine = engine;
        emit engineChanged();
        init();
    }
}

Engine *ZigbeeManager::engine() const
{
    return m_engine;
}

bool ZigbeeManager::fetchingData() const
{
    return m_fetchingData;
}

QStringList ZigbeeManager::availableBackends() const
{
    return m_availableBackends;
}

ZigbeeAdapters *ZigbeeManager::adapters() const
{
    return m_adapters;
}

ZigbeeNetworks *ZigbeeManager::networks() const
{
    return m_networks;
}

int ZigbeeManager::addNetwork(const QString &serialPort, uint baudRate, const QString &backend, ZigbeeChannels channels)
{
    QVariantMap params;
    params.insert("serialPort", serialPort);
    params.insert("baudRate", baudRate);
    params.insert("backend", backend);
    if (m_engine->jsonRpcClient()->ensureServerVersion("5.8")) {
        params.insert("channelMask", static_cast<uint>(channels));
    }

    qCDebug(dcZigbee()) << "Add zigbee network" << params;
    return m_engine->jsonRpcClient()->sendCommand("Zigbee.AddNetwork", params, this, "addNetworkResponse");
}

void ZigbeeManager::removeNetwork(const QUuid &networkUuid)
{
    QVariantMap params;
    params.insert("networkUuid", networkUuid);
    qCDebug(dcZigbee()) << "Remove zigbee network" << params;
    m_engine->jsonRpcClient()->sendCommand("Zigbee.RemoveNetwork", params, this, "removeNetworkResponse");
}

void ZigbeeManager::setPermitJoin(const QUuid &networkUuid, uint duration)
{
    QVariantMap params;
    params.insert("networkUuid", networkUuid);
    params.insert("duration", duration);
    m_engine->jsonRpcClient()->sendCommand("Zigbee.SetPermitJoin", params, this, "setPermitJoinResponse");
}

void ZigbeeManager::factoryResetNetwork(const QUuid &networkUuid)
{
    QVariantMap params;
    params.insert("networkUuid", networkUuid);
    m_engine->jsonRpcClient()->sendCommand("Zigbee.FactoryResetNetwork", params, this, "factoryResetNetworkResponse");
}

void ZigbeeManager::getNodes(const QUuid &networkUuid)
{
    QVariantMap params;
    params.insert("networkUuid", networkUuid);
    m_engine->jsonRpcClient()->sendCommand("Zigbee.GetNodes", params, this, "getNodesResponse");
}

int ZigbeeManager::removeNode(const QUuid &networkUuid, const QString &ieeeAddress)
{
    QVariantMap params;
    params.insert("networkUuid", networkUuid);
    params.insert("ieeeAddress", ieeeAddress);
    return m_engine->jsonRpcClient()->sendCommand("Zigbee.RemoveNode", params, this, "removeNodeResponse");
}

void ZigbeeManager::refreshNeighborTables(const QUuid &networkUuid)
{
    m_engine->jsonRpcClient()->sendCommand("Zigbee.RefreshNeighborTables", {{"networkUuid", networkUuid}});
}

int ZigbeeManager::createBinding(const QUuid &networkUuid, const QString &sourceAddress, quint8 sourceEndpointId, quint16 clusterId, const QString &destinationAddress, quint8 destinationEndpointId)
{
    QVariantMap params = {
        {"networkUuid", networkUuid},
        {"sourceAddress", sourceAddress},
        {"sourceEndpointId", sourceEndpointId},
        {"clusterId", clusterId},
        {"destinationAddress", destinationAddress},
        {"destinationEndpointId", destinationEndpointId}
    };
    qCDebug(dcZigbee()) << "Creating binding for:" << qUtf8Printable(QJsonDocument::fromVariant(params).toJson());
    return m_engine->jsonRpcClient()->sendCommand("Zigbee.CreateBinding", params, this, "createBindingResponse");
}

int ZigbeeManager::createGroupBinding(const QUuid &networkUuid, const QString &sourceAddress, quint8 sourceEndpointId, quint16 clusterId, quint16 destinationGroupAddress)
{
    QVariantMap params = {
        {"networkUuid", networkUuid},
        {"sourceAddress", sourceAddress},
        {"sourceEndpointId", sourceEndpointId},
        {"clusterId", clusterId},
        {"destinationGroupAddress", destinationGroupAddress}
    };
    qCDebug(dcZigbee()) << "Creating binding for:" << qUtf8Printable(QJsonDocument::fromVariant(params).toJson());
    return m_engine->jsonRpcClient()->sendCommand("Zigbee.CreateBinding", params, this, "createBindingResponse");
}

int ZigbeeManager::removeBinding(const QUuid &networkUuid, ZigbeeNodeBinding *binding)
{
    QVariantMap params = {
        {"networkUuid", networkUuid},
        {"sourceAddress", binding->sourceAddress()},
        {"sourceEndpointId", binding->sourceEndpointId()},
        {"clusterId", binding->clusterId()}
    };
    if (!binding->destinationAddress().isEmpty()) {
        params.insert("destinationAddress", binding->destinationAddress());
        params.insert("destinationEndpointId", binding->destinationEndpointId());
    } else {
        params.insert("destinationGroupAddress", binding->groupAddress());
    }
    qCDebug(dcZigbee()) << "Removing binding for:" << qUtf8Printable(QJsonDocument::fromVariant(params).toJson());
    return m_engine->jsonRpcClient()->sendCommand("Zigbee.RemoveBinding", params, this, "removeBindingResponse");
}

void ZigbeeManager::init()
{
    m_fetchingData = true;
    emit fetchingDataChanged();

    m_adapters->clear();
    m_networks->clear();
    m_availableBackends.clear();

    m_engine->jsonRpcClient()->registerNotificationHandler(this, "Zigbee", "notificationReceived");

    m_engine->jsonRpcClient()->sendCommand("Zigbee.GetAvailableBackends", this, "getAvailableBackendsResponse");
    m_engine->jsonRpcClient()->sendCommand("Zigbee.GetAdapters", this, "getAdaptersResponse");
    m_engine->jsonRpcClient()->sendCommand("Zigbee.GetNetworks", this, "getNetworksResponse");
}

void ZigbeeManager::getAvailableBackendsResponse(int commandId, const QVariantMap &params)
{
    qCDebug(dcZigbee()) << "Zigbee get available backends response" << commandId << params;
    m_availableBackends.clear();
    foreach (const QVariant &backendVariant, params.value("backends").toList()) {
        m_availableBackends << backendVariant.toString();
    }
    emit availableBackendsChanged();
}

void ZigbeeManager::getAdaptersResponse(int commandId, const QVariantMap &params)
{
    qCDebug(dcZigbee()) << "Zigbee get adapters response" << commandId << params;
    m_adapters->clear();
    foreach (const QVariant &adapterVariant, params.value("adapters").toList()) {
        QVariantMap adapterMap = adapterVariant.toMap();
        ZigbeeAdapter *adapter = unpackAdapter(adapterMap);
        qCDebug(dcZigbee()) << "Zigbee adapter added" << adapter->description() << adapter->serialPort() << adapter->hardwareRecognized();
        m_adapters->addAdapter(adapter);
    }
}

void ZigbeeManager::getNetworksResponse(int commandId, const QVariantMap &params)
{
    qCDebug(dcZigbee()) << "Zigbee get networks response" << commandId << params;
    m_networks->clear();
    foreach (const QVariant &networkVariant, params.value("zigbeeNetworks").toList()) {
        QVariantMap networkMap = networkVariant.toMap();
        ZigbeeNetwork *network = unpackNetwork(networkMap);
        qCDebug(dcZigbee()) << "Zigbee network added" << network->networkUuid().toString() << network->serialPort() << network->macAddress();
        m_networks->addNetwork(network);

        // Get nodes from this network
        getNodes(network->networkUuid());

    }
    // In theory this should only change after nodes have been fetched... but this will do for now...
    m_fetchingData = false;
    emit fetchingDataChanged();
}

void ZigbeeManager::addNetworkResponse(int commandId, const QVariantMap &params)
{
    qCDebug(dcZigbee()) << "Zigbee add network response" << commandId << params;
    QMetaEnum errorEnum = QMetaEnum::fromType<ZigbeeError>();
    ZigbeeError error = static_cast<ZigbeeError>(errorEnum.keyToValue(params.value("zigbeeError").toByteArray()));
    emit addNetworkReply(commandId, error, params.value("networkUuid").toUuid());
}

void ZigbeeManager::removeNetworkResponse(int commandId, const QVariantMap &params)
{
    qCDebug(dcZigbee()) << "Zigbee remove network response" << commandId << params;
    QMetaEnum errorEnum = QMetaEnum::fromType<ZigbeeError>();
    ZigbeeError error = static_cast<ZigbeeError>(errorEnum.keyToValue(params.value("zigbeeError").toByteArray()));
    emit removeNetworkReply(commandId, error);
}

void ZigbeeManager::setPermitJoinResponse(int commandId, const QVariantMap &params)
{
    qCDebug(dcZigbee()) << "Zigbee set permit join network response" << commandId << params;
}

void ZigbeeManager::factoryResetNetworkResponse(int commandId, const QVariantMap &params)
{
    qCDebug(dcZigbee()) << "Zigbee factory reset network response" << commandId << params;
    QMetaEnum errorEnum = QMetaEnum::fromType<ZigbeeError>();
    ZigbeeError error = static_cast<ZigbeeError>(errorEnum.keyToValue(params.value("zigbeeError").toByteArray()));
    emit factoryResetNetworkReply(commandId, error);
}

void ZigbeeManager::getNodesResponse(int commandId, const QVariantMap &params)
{
    qCDebug(dcZigbee()) << "Zigbee get nodes response" << commandId << qUtf8Printable(QJsonDocument::fromVariant(params).toJson());

    foreach (const QVariant &nodeVariant, params.value("zigbeeNodes").toList()) {
        QVariantMap nodeMap = nodeVariant.toMap();
        QUuid networkUuid = nodeMap.value("networkUuid").toUuid();
        ZigbeeNetwork *network = m_networks->getNetwork(networkUuid);
        if (!network) {
            qCWarning(dcZigbee()) << "Could not find network for node" << nodeMap;
            return;
        }

        addOrUpdateNode(network, nodeMap);
    }
}

void ZigbeeManager::removeNodeResponse(int commandId, const QVariantMap &params)
{
    qCDebug(dcZigbee()) << "Zigbee remove node response" << commandId << params;
    QMetaEnum errorEnum = QMetaEnum::fromType<ZigbeeError>();
    ZigbeeError error = static_cast<ZigbeeError>(errorEnum.keyToValue(params.value("zigbeeError").toByteArray()));
    emit removeNodeReply(commandId, error);
}

void ZigbeeManager::createBindingResponse(int commandId, const QVariantMap &params)
{
    qCDebug(dcZigbee()) << "Create binding response" << qUtf8Printable(QJsonDocument::fromVariant(params).toJson());
    QMetaEnum errorEnum = QMetaEnum::fromType<ZigbeeError>();
    ZigbeeError error = static_cast<ZigbeeError>(errorEnum.keyToValue(params.value("zigbeeError").toByteArray()));
    emit createBindingReply(commandId, error);
}

void ZigbeeManager::removeBindingResponse(int commandId, const QVariantMap &params)
{
    qCDebug(dcZigbee()) << "Remove binding response" << qUtf8Printable(QJsonDocument::fromVariant(params).toJson());
    QMetaEnum errorEnum = QMetaEnum::fromType<ZigbeeError>();
    ZigbeeError error = static_cast<ZigbeeError>(errorEnum.keyToValue(params.value("zigbeeError").toByteArray()));
    emit removeBindingReply(commandId, error);
}

void ZigbeeManager::notificationReceived(const QVariantMap &notification)
{
//    qCDebug(dcZigbee()) << "Zigbee notification" << qUtf8Printable(QJsonDocument::fromVariant(notification).toJson());
    QString notificationString = notification.value("notification").toString();
    if (notificationString == "Zigbee.AdapterAdded") {
        QVariantMap adapterMap = notification.value("params").toMap().value("adapter").toMap();
        m_adapters->addAdapter(unpackAdapter(adapterMap));
        return;
    }

    if (notificationString == "Zigbee.AdapterRemoved") {
        QVariantMap adapterMap = notification.value("params").toMap().value("adapter").toMap();
        m_adapters->removeAdapter(adapterMap.value("serialPort").toString());
        return;
    }

    if (notificationString == "Zigbee.NetworkAdded") {
        QVariantMap networkMap = notification.value("params").toMap().value("zigbeeNetwork").toMap();
        m_networks->addNetwork(unpackNetwork(networkMap));
        return;
    }

    if (notificationString == "Zigbee.NetworkRemoved") {
        QUuid networkUuid = notification.value("params").toMap().value("networkUuid").toUuid();
        m_networks->removeNetwork(networkUuid);
        return;
    }

    if (notificationString == "Zigbee.NetworkChanged") {
        QVariantMap networkMap = notification.value("params").toMap().value("zigbeeNetwork").toMap();
        QUuid networkUuid = networkMap.value("networkUuid").toUuid();
        ZigbeeNetwork *network = m_networks->getNetwork(networkUuid);
        if (!network) {
            qCWarning(dcZigbee()) << "Could not find network for changed notification";
            return;
        }
        fillNetworkData(network, networkMap);
        return;
    }

    if (notificationString == "Zigbee.NodeAdded") {
        QVariantMap nodeMap = notification.value("params").toMap().value("zigbeeNode").toMap();
        QUuid networkUuid = nodeMap.value("networkUuid").toUuid();
        ZigbeeNetwork *network = m_networks->getNetwork(networkUuid);
        if (!network) {
            qCWarning(dcZigbee()) << "Could not find network for node added notification" << nodeMap;
            return;
        }

        addOrUpdateNode(network, nodeMap);
        return;
    }

    if (notificationString == "Zigbee.NodeRemoved") {
        QVariantMap nodeMap = notification.value("params").toMap().value("zigbeeNode").toMap();
        QUuid networkUuid = nodeMap.value("networkUuid").toUuid();
        ZigbeeNetwork *network = m_networks->getNetwork(networkUuid);
        if (!network) {
            qCWarning(dcZigbee()) << "Could not find network for node removed notification" << nodeMap;
            return;
        }

        QString ieeeAddress = nodeMap.value("ieeeAddress").toString();
        network->nodes()->removeNode(ieeeAddress);
        return;
    }

    if (notificationString == "Zigbee.NodeChanged") {
        QVariantMap nodeMap = notification.value("params").toMap().value("zigbeeNode").toMap();
        QUuid networkUuid = nodeMap.value("networkUuid").toUuid();
        ZigbeeNetwork *network = m_networks->getNetwork(networkUuid);
        if (!network) {
            qCWarning(dcZigbee()) << "Could not find network for node changed notification" << nodeMap;
            return;
        }

        addOrUpdateNode(network, nodeMap);
        return;
    }

    qCDebug(dcZigbee()) << "Unhandled Zigbee notification" << notificationString << notification;
}

ZigbeeAdapter *ZigbeeManager::unpackAdapter(const QVariantMap &adapterMap)
{
    ZigbeeAdapter *adapter = new ZigbeeAdapter(m_adapters);
    adapter->setName(adapterMap.value("name").toString());
    adapter->setDescription(adapterMap.value("description").toString());
    adapter->setSerialPort(adapterMap.value("serialPort").toString());
    adapter->setSerialNumber(adapterMap.value("serialNumber").toString());
    adapter->setHardwareRecognized(adapterMap.value("hardwareRecognized").toBool());
    adapter->setBackend(adapterMap.value("backend").toString());
    adapter->setBaudRate(adapterMap.value("baudRate").toUInt());
    return adapter;
}

ZigbeeNetwork *ZigbeeManager::unpackNetwork(const QVariantMap &networkMap)
{
    ZigbeeNetwork *network = new ZigbeeNetwork(m_networks);
    fillNetworkData(network, networkMap);
    return network;
}

ZigbeeNode *ZigbeeManager::unpackNode(const QVariantMap &nodeMap)
{
    QUuid networkUuid = nodeMap.value("networkUuid").toUuid();
    QString ieeeAddress = nodeMap.value("ieeeAddress").toString();
    ZigbeeNode *node = new ZigbeeNode(networkUuid, ieeeAddress, this);
    updateNodeProperties(node, nodeMap);
    return node;
}

void ZigbeeManager::fillNetworkData(ZigbeeNetwork *network, const QVariantMap &networkMap)
{
    network->setNetworkUuid(networkMap.value("networkUuid").toUuid());
    network->setSerialPort(networkMap.value("serialPort").toString());
    network->setBaudRate(networkMap.value("baudRate").toUInt());
    network->setMacAddress(networkMap.value("macAddress").toString());
    network->setFirmwareVersion(networkMap.value("firmwareVersion").toString());
    network->setPanId(networkMap.value("panId").toUInt());
    network->setChannel(networkMap.value("channel").toUInt());
    network->setChannelMask(networkMap.value("channelMask").toUInt());
    network->setPermitJoiningEnabled(networkMap.value("permitJoiningEnabled").toBool());
    network->setPermitJoiningDuration(networkMap.value("permitJoiningDuration").toUInt());
    network->setPermitJoiningRemaining(networkMap.value("permitJoiningRemaining").toUInt());
    network->setBackend(networkMap.value("backend").toString());
    QMetaEnum networkStateEnum = QMetaEnum::fromType<ZigbeeNetwork::ZigbeeNetworkState>();
    network->setNetworkState(static_cast<ZigbeeNetwork::ZigbeeNetworkState>(networkStateEnum.keyToValue(networkMap.value("networkState").toByteArray())));
}

void ZigbeeManager::addOrUpdateNode(ZigbeeNetwork *network, const QVariantMap &nodeMap)
{
    QString ieeeAddress = nodeMap.value("ieeeAddress").toString();
    ZigbeeNode *node = network->nodes()->getNode(ieeeAddress);
    if (node) {
        updateNodeProperties(node, nodeMap);
    } else {
        network->nodes()->addNode(unpackNode(nodeMap));
    }
}

void ZigbeeManager::updateNodeProperties(ZigbeeNode *node, const QVariantMap &nodeMap)
{
    node->setNetworkAddress(nodeMap.value("networkAddress").toUInt());
    node->setType(ZigbeeNode::stringToNodeType(nodeMap.value("type").toString()));
    node->setState(ZigbeeNode::stringToNodeState(nodeMap.value("state").toString()));
    node->setManufacturer(nodeMap.value("manufacturer").toString());
    node->setModel(nodeMap.value("model").toString());
    node->setVersion(nodeMap.value("version").toString());
    node->setRxOnWhenIdle(nodeMap.value("receiverOnWhileIdle").toBool());
    node->setReachable(nodeMap.value("reachable").toBool());
    node->setLqi(nodeMap.value("lqi").toUInt());
    node->setLastSeen(QDateTime::fromMSecsSinceEpoch(nodeMap.value("lastSeen").toULongLong() * 1000));
    QList<quint16> neighbors;
    foreach (const QVariant &neighbor, nodeMap.value("neighborTableRecords").toList()) {
        QVariantMap neighborMap = neighbor.toMap();
        quint16 networkAddress = neighborMap.value("networkAddress").toUInt();
//        qWarning() << "*********** adding neighbor" << networkAddress;
        QMetaEnum relationshipEnum = QMetaEnum::fromType<ZigbeeNode::ZigbeeNodeRelationship>();
        ZigbeeNode::ZigbeeNodeRelationship relationship = static_cast<ZigbeeNode::ZigbeeNodeRelationship>(relationshipEnum.keyToValue(neighborMap.value("relationship").toByteArray().data()));
        quint8 lqi = neighborMap.value("lqi").toUInt();
        quint8 depth = neighborMap.value("depth").toUInt();
        bool permitJoining = neighborMap.value("permitJoining").toBool();
        node->addOrUpdateNeighbor(networkAddress, relationship, lqi, depth, permitJoining);
        neighbors.append(networkAddress);
    }
    node->commitNeighbors(neighbors);

    QList<quint16> routes;
    foreach (const QVariant &route, nodeMap.value("routingTableRecords").toList()) {
        QVariantMap routeMap = route.toMap();
        quint16 destinationAddress = routeMap.value("destinationAddress").toUInt();
        quint16 nextHopAddress = routeMap.value("nextHopAddress").toUInt();
        QMetaEnum routeStatusEnum = QMetaEnum::fromType<ZigbeeNode::ZigbeeNodeRouteStatus>();
        ZigbeeNode::ZigbeeNodeRouteStatus routeStatus = static_cast<ZigbeeNode::ZigbeeNodeRouteStatus>(routeStatusEnum.keyToValue(routeMap.value("status").toByteArray().data()));
        bool memoryConstrained = routeMap.value("memoryConstrained").toBool();
        bool manyToOne = routeMap.value("manyToOne").toBool();
        node->addOrUpdateRoute(destinationAddress, nextHopAddress, routeStatus, memoryConstrained, manyToOne);
        routes.append(destinationAddress);
    }
    node->commitRoutes(routes);

    foreach (const QVariant &binding, nodeMap.value("bindingTableRecords").toList()) {
        QVariantMap bindingMap = binding.toMap();
        QString sourceAddress = bindingMap.value("sourceAddress").toString();
        quint8 sourceEndpointId = bindingMap.value("sourceEndpointId").toUInt();
        quint16 clusterId = bindingMap.value("clusterId").toUInt();
        if (bindingMap.contains("groupAddress")) {
            quint16 groupAddress = bindingMap.value("groupAddress").toUInt();
            node->addBinding(sourceAddress, sourceEndpointId, clusterId, groupAddress);
        } else {
            QString destinationAddress = bindingMap.value("destinationAddress").toString();
            quint8 destinationEndpointId = bindingMap.value("destinationEndpointId").toUInt();
            node->addBinding(sourceAddress, sourceEndpointId, clusterId, destinationAddress, destinationEndpointId);
        }
    }
    node->commitBindings();

    foreach (const QVariant &e, nodeMap.value("endpoints").toList()) {
        QVariantMap endpointMap = e.toMap();
        quint8 endpointId = endpointMap.value("endpointId").toUInt();
        ZigbeeNodeEndpoint *endpoint = node->getEndpoint(endpointId);
        if (!endpoint) {
            endpoint = new ZigbeeNodeEndpoint(endpointId);
            node->addEndpoint(endpoint);
        }
        foreach (const QVariant &c, endpointMap.value("inputClusters").toList()) {
            QVariantMap clusterMap = c.toMap();
            quint16 clusterId = clusterMap.value("clusterId").toUInt();
            if (endpoint->getInputCluster(clusterId)) {
                continue;
            }
            QMetaEnum clusterDirectionEnum = QMetaEnum::fromType<ZigbeeCluster::ZigbeeClusterDirection>();
            ZigbeeCluster::ZigbeeClusterDirection direction = static_cast<ZigbeeCluster::ZigbeeClusterDirection>(clusterDirectionEnum.keyToValue(clusterMap.value("direction").toByteArray().data()));
            ZigbeeCluster *cluster = new ZigbeeCluster(clusterId, direction);
            endpoint->addInputCluster(cluster);
        }
        foreach (const QVariant &c, endpointMap.value("outputClusters").toList()) {
            QVariantMap clusterMap = c.toMap();
            quint16 clusterId = clusterMap.value("clusterId").toUInt();
            if (endpoint->getOutputCluster(clusterId)) {
                continue;
            }
            QMetaEnum clusterDirectionEnum = QMetaEnum::fromType<ZigbeeCluster::ZigbeeClusterDirection>();
            ZigbeeCluster::ZigbeeClusterDirection direction = static_cast<ZigbeeCluster::ZigbeeClusterDirection>(clusterDirectionEnum.keyToValue(clusterMap.value("direction").toByteArray().data()));
            ZigbeeCluster *cluster = new ZigbeeCluster(clusterId, direction);
            endpoint->addOutputCluster(cluster);
        }
    }
}

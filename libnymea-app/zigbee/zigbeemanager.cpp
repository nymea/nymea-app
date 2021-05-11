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

#include "engine.h"
#include "jsonrpc/jsonrpcclient.h"
#include "zigbee/zigbeeadapter.h"
#include "zigbee/zigbeeadapters.h"
#include "zigbee/zigbeenetwork.h"
#include "zigbee/zigbeenetworks.h"
#include "zigbee/zigbeenode.h"
#include "zigbee/zigbeenodes.h"

#include <QMetaEnum>

#include "logging.h"
NYMEA_LOGGING_CATEGORY(dcZigbee, "Zigbee")

ZigbeeManager::ZigbeeManager(QObject *parent) :
    JsonHandler(parent),
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

QString ZigbeeManager::nameSpace() const
{
    return "Zigbee";
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

int ZigbeeManager::addNetwork(const QString &serialPort, uint baudRate, const QString &backend)
{
    QVariantMap params;
    params.insert("serialPort", serialPort);
    params.insert("baudRate", baudRate);
    params.insert("backend", backend);

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

void ZigbeeManager::init()
{
    m_adapters->clear();
    m_networks->clear();
    m_availableBackends.clear();

    m_engine->jsonRpcClient()->registerNotificationHandler(this, "notificationReceived");

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
}

void ZigbeeManager::addNetworkResponse(int commandId, const QVariantMap &params)
{
    qCDebug(dcZigbee()) << "Zigbee add network response" << commandId << params;
    emit addNetworkReply(commandId, params.value("zigbeeError").toString(), params.value("networkUuid").toUuid());
}

void ZigbeeManager::removeNetworkResponse(int commandId, const QVariantMap &params)
{
    qCDebug(dcZigbee()) << "Zigbee remove network response" << commandId << params;
}

void ZigbeeManager::setPermitJoinResponse(int commandId, const QVariantMap &params)
{
    qCDebug(dcZigbee()) << "Zigbee set permit join network response" << commandId << params;
}

void ZigbeeManager::factoryResetNetworkResponse(int commandId, const QVariantMap &params)
{
    qCDebug(dcZigbee()) << "Zigbee factory reset network response" << commandId << params;
}

void ZigbeeManager::getNodesResponse(int commandId, const QVariantMap &params)
{
    qCDebug(dcZigbee()) << "Zigbee get nodes response" << commandId << params;

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
    emit removeNodeReply(commandId, params.value("zigbeeError").toString());
}

void ZigbeeManager::notificationReceived(const QVariantMap &notification)
{
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
    node->updateNodeProperties(nodeMap);
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
    network->setNetworkState(ZigbeeNetwork::stringToZigbeeNetworkState(networkMap.value("networkState").toString()));
}

void ZigbeeManager::addOrUpdateNode(ZigbeeNetwork *network, const QVariantMap &nodeMap)
{
    QString ieeeAddress = nodeMap.value("ieeeAddress").toString();
    ZigbeeNode *node = network->nodes()->getNode(ieeeAddress);
    if (node) {
        node->updateNodeProperties(nodeMap);
    } else {
        network->nodes()->addNode(unpackNode(nodeMap));
    }
}


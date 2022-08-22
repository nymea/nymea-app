#include "zwavemanager.h"

#include <QJsonDocument>
#include <QMetaEnum>

#include "types/serialports.h"
#include "types/serialport.h"
#include "zwavenetwork.h"
#include "zwavenode.h"

#include "engine.h"
#include "logging.h"
NYMEA_LOGGING_CATEGORY(dcZWave, "ZWave")

ZWaveManager::ZWaveManager(QObject *parent):
    QObject{parent},
    m_serialPorts(new SerialPorts(this)),
    m_networks(new ZWaveNetworks(this))
{

}

ZWaveManager::~ZWaveManager()
{
    if (m_engine) {
        m_engine->jsonRpcClient()->unregisterNotificationHandler(this);
    }
}

void ZWaveManager::setEngine(Engine *engine)
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

Engine *ZWaveManager::engine() const
{
    return m_engine;
}

bool ZWaveManager::fetchingData() const
{
    return m_fetchingData;
}

bool ZWaveManager::zwaveAvailable() const
{
    return m_zwaveAvailable;
}

SerialPorts *ZWaveManager::serialPorts() const
{
    return m_serialPorts;
}

ZWaveNetworks *ZWaveManager::networks() const
{
    return m_networks;
}

int ZWaveManager::addNetwork(const QString &serialPort)
{
    QVariantMap params;
    params.insert("serialPort", serialPort);
    return m_engine->jsonRpcClient()->sendCommand("ZWave.AddNetwork", params, this, "addNetworkResponse");
}

int ZWaveManager::removeNetwork(const QUuid &networkUuid)
{
    QVariantMap params = {{"networkUuid", networkUuid}};
    return m_engine->jsonRpcClient()->sendCommand("ZWave.RemoveNetwork", params, this, "removeNetworkResponse");
}

int ZWaveManager::addNode(const QUuid &networkUuid)
{
    QVariantMap params = {{"networkUuid", networkUuid}};
    return m_engine->jsonRpcClient()->sendCommand("ZWave.AddNode", params, this, "addNodeResponse");
}

void ZWaveManager::cancelPendingOperation(const QUuid &networkUuid)
{
    m_engine->jsonRpcClient()->sendCommand("ZWave.CancelPendingOperation", {{"networkUuid", networkUuid}}, this, "cancelPendingOperationResponse");
}

int ZWaveManager::factoryResetNetwork(const QUuid &networkUuid)
{
    QVariantMap params = {{"networkUuid", networkUuid}};
    return m_engine->jsonRpcClient()->sendCommand("ZWave.FactoryResetNetwork", params, this, "factoryResetNetworkResponse");
}

int ZWaveManager::removeNode(const QUuid &networkUuid)
{
    return m_engine->jsonRpcClient()->sendCommand("ZWave.RemoveNode", {{"networkUuid", networkUuid}}, this, "removeNodeResponse");
}

int ZWaveManager::removeFailedNode(const QUuid &networkUuid, int nodeId)
{
    return m_engine->jsonRpcClient()->sendCommand("ZWave.RemoveFailedNode", {{"networkUuid", networkUuid}, {"nodeId", nodeId}}, this, "removeFailedNodeResponse");
}


void ZWaveManager::init()
{
    m_zwaveAvailable = false;
    emit zwaveAvailableChanged();

    m_fetchingData = true;
    emit fetchingDataChanged();

    m_networks->clear();
    m_serialPorts->clear();

    m_engine->jsonRpcClient()->registerNotificationHandler(this, "ZWave", "notificationReceived");

    m_engine->jsonRpcClient()->sendCommand("ZWave.IsZWaveAvailable", this, "isZWaveAvailableResponse");
    m_engine->jsonRpcClient()->sendCommand("ZWave.GetSerialPorts", this, "getSerialPortsResponse");
    m_engine->jsonRpcClient()->sendCommand("ZWave.GetNetworks", this, "getNetworksResponse");    
}

void ZWaveManager::isZWaveAvailableResponse(int commandId, const QVariantMap &params)
{
    Q_UNUSED(commandId)
    m_zwaveAvailable = params.value("available").toBool();
    emit zwaveAvailableChanged();
}

void ZWaveManager::getSerialPortsResponse(int commandId, const QVariantMap &params)
{
    qCDebug(dcZWave()) << "Serial ports response:" << commandId << qUtf8Printable(QJsonDocument::fromVariant(params).toJson());
    foreach (const QVariant &entryVariant, params.value("serialPorts").toList()) {
        SerialPort *serialPort = SerialPort::unpackSerialPort(entryVariant.toMap(), this);
        m_serialPorts->addSerialPort(serialPort);
    }
    qCDebug(dcZWave) << "Added" << m_serialPorts->rowCount() << "ports";

}

void ZWaveManager::getNetworksResponse(int commandId, const QVariantMap &params)
{
    qCDebug(dcZWave()) << "get networks response:" << commandId << params;

    foreach (const QVariant &entryVariant, params.value("networks").toList()) {
        QVariantMap entry = entryVariant.toMap();
        ZWaveNetwork *network = unpackNetwork(entry);
        m_networks->addNetwork(network);

        int id = m_engine->jsonRpcClient()->sendCommand("ZWave.GetNodes", {{"networkUuid", network->networkUuid()}}, this, "getNodesResponse");
        m_pendingGetNodeCalls.insert(id, network->networkUuid());
    }

    m_fetchingData = false;
    emit fetchingDataChanged();
}

void ZWaveManager::addNetworkResponse(int commandId, const QVariantMap &params)
{
    qCDebug(dcZWave()) << "Add network response" << commandId << params;
    QMetaEnum errorEnum = QMetaEnum::fromType<ZWaveManager::ZWaveError>();
    ZWaveError error = static_cast<ZWaveError>(errorEnum.keyToValue(params.value("zwaveError").toByteArray()));
    emit addNetworkReply(commandId, error, params.value("networkUuid").toUuid());
}

void ZWaveManager::removeNetworkResponse(int commandId, const QVariantMap &params)
{
    qCDebug(dcZWave()) << "Remove network response" << commandId << params;
    QMetaEnum errorEnum = QMetaEnum::fromType<ZWaveManager::ZWaveError>();
    ZWaveError error = static_cast<ZWaveError>(errorEnum.keyToValue(params.value("zwaveError").toByteArray()));
    emit removeNetworkReply(commandId, error);
}

void ZWaveManager::cancelPendingOperationResponse(int commandId, const QVariantMap &params)
{
    qCDebug(dcZWave()) << "Cancel pending operation response" << commandId << params;
    QMetaEnum errorEnum = QMetaEnum::fromType<ZWaveManager::ZWaveError>();
    ZWaveError error = static_cast<ZWaveError>(errorEnum.keyToValue(params.value("zwaveError").toByteArray()));
    emit cancelPendingOperationReply(commandId, error);
}

void ZWaveManager::addNodeResponse(int commandId, const QVariantMap &params)
{
    QMetaEnum errorEnum = QMetaEnum::fromType<ZWaveManager::ZWaveError>();
    ZWaveError error = static_cast<ZWaveError>(errorEnum.keyToValue(params.value("zwaveError").toByteArray()));
    emit addNodeReply(commandId, error);
}

void ZWaveManager::softResetControllerResponse(int commandId, const QVariantMap &params)
{
    QMetaEnum errorEnum = QMetaEnum::fromType<ZWaveManager::ZWaveError>();
    ZWaveError error = static_cast<ZWaveError>(errorEnum.keyToValue(params.value("zwaveError").toByteArray()));
    emit softResetControllerReply(commandId, error);
}

void ZWaveManager::factoryResetNetworkResponse(int commandId, const QVariantMap &params)
{
    QMetaEnum errorEnum = QMetaEnum::fromType<ZWaveManager::ZWaveError>();
    ZWaveError error = static_cast<ZWaveError>(errorEnum.keyToValue(params.value("zwaveError").toByteArray()));
    emit factoryResetNetworkReply(commandId, error);
}

void ZWaveManager::getNodesResponse(int commandId, const QVariantMap &params)
{
    QUuid networkUuid = m_pendingGetNodeCalls.value(commandId);
    ZWaveNetwork *network = m_networks->getNetwork(networkUuid);
    if (!network) {
        qCWarning(dcZWave()) << "Received a getNodes response for a network we don't know!?";
        return;
    }

    qCDebug(dcZWave()) << "GetNodes response:" << qUtf8Printable(QJsonDocument::fromVariant(params).toJson());

    foreach (const QVariant &entry, params.value("nodes").toList()) {
        QVariantMap nodeMap = entry.toMap();
        network->addNode(unpackNode(nodeMap));
    }
}

void ZWaveManager::removeNodeResponse(int commandId, const QVariantMap &params)
{
    qCDebug(dcZWave()) << "Remove noderesponse" << commandId << params;
    QMetaEnum errorEnum = QMetaEnum::fromType<ZWaveManager::ZWaveError>();
    ZWaveError error = static_cast<ZWaveError>(errorEnum.keyToValue(params.value("zwaveError").toByteArray()));
    emit removeNodeReply(commandId, error);
}

void ZWaveManager::removeFailedNodeResponse(int commandId, const QVariantMap &params)
{
    qCDebug(dcZWave()) << "RemoveFailedNode response:" << commandId << params;
    QMetaEnum errorEnum = QMetaEnum::fromType<ZWaveManager::ZWaveError>();
    ZWaveError error = static_cast<ZWaveError>(errorEnum.keyToValue(params.value("zwaveError").toByteArray()));
    emit removeFailedNodeReply(commandId, error);
}

void ZWaveManager::notificationReceived(const QVariantMap &data)
{
    qCDebug(dcZWave) << "Notification received:" << data;
    QString notification = data.value("notification").toString();

    if (notification == "ZWave.NetworkAdded") {
        ZWaveNetwork *network = unpackNetwork(data.value("params").toMap().value("network").toMap());
        m_networks->addNetwork(network);

    } else if (notification == "ZWave.NetworkRemoved") {
        m_networks->removeNetwork(data.value("params").toMap().value("networkUuid").toUuid());

    } else if (notification == "ZWave.NetworkChanged") {
        QVariantMap networkMap = data.value("params").toMap().value("network").toMap();
        QUuid networkUuid = networkMap.value("networkUuid").toUuid();
        ZWaveNetwork *network = m_networks->getNetwork(networkUuid);
        if (!network) {
            qCWarning(dcZWave()) << "Received a NetworkChanged notification for a network we don't know.";
            return;
        }
        unpackNetwork(networkMap, network);

    } else if (notification == "ZWave.NodeAdded") {
        QVariantMap nodeMap = data.value("params").toMap().value("node").toMap();
        QUuid networkUuid = data.value("params").toMap().value("networkUuid").toUuid();
        ZWaveNetwork *network = m_networks->getNetwork(networkUuid);
        if (!network) {
            qCWarning(dcZWave()) << "Received a NodeAdded notification for a network we don't know.";
            return;
        }
        network->addNode(unpackNode(nodeMap));

    } else if (notification == "ZWave.NodeRemoved") {
        quint8 nodeId = data.value("params").toMap().value("nodeId").toUInt();
        QUuid networkUuid = data.value("params").toMap().value("networkUuid").toUuid();
        ZWaveNetwork *network = m_networks->getNetwork(networkUuid);
        if (!network) {
            qCWarning(dcZWave()) << "Received a NodeRemoved notification for a network we don't know.";
            return;
        }
        network->removeNode(nodeId);

    } else if (notification == "ZWave.NodeChanged") {
        QVariantMap nodeMap = data.value("params").toMap().value("node").toMap();
        QUuid networkUuid = data.value("params").toMap().value("networkUuid").toUuid();
        ZWaveNetwork *network = m_networks->getNetwork(networkUuid);
        if (!network) {
            qCWarning(dcZWave()) << "Received a NodeChanged notification for a network we don't know.";
            return;
        }
        ZWaveNode *node = network->nodes()->getNode(nodeMap.value("nodeId").toUInt());
        if (!node) {
            qCWarning(dcZWave()) << "Received a NodeChanged notification for a node we don't know";
            return;
        }
        unpackNode(nodeMap, node);
    }
}

ZWaveNetwork *ZWaveManager::unpackNetwork(const QVariantMap &networkMap, ZWaveNetwork *network)
{
    if (!network) {
        network = new ZWaveNetwork(networkMap.value("networkUuid").toUuid(), networkMap.value("serialPort").toString());
    }

    network->setHomeId(networkMap.value("homeId").toUInt());
    QMetaEnum stateEnum = QMetaEnum::fromType<ZWaveNetwork::ZWaveNetworkState>();
    network->setIsZWavePlus(networkMap.value("isZWavePlus").toBool());
    network->setIsPrimaryController(networkMap.value("isPrimaryController").toBool());
    network->setIsStaticUpdateController(networkMap.value("isStaticUpdateController").toBool());
    network->setWaitingForNodeAddition(networkMap.value("waitingForNodeAddition").toBool());
    network->setWaitingForNodeRemoval(networkMap.value("waitingForNodeRemoval").toBool());
    network->setNetworkState(static_cast<ZWaveNetwork::ZWaveNetworkState>(stateEnum.keyToValue(networkMap.value("networkState").toByteArray())));

    return network;
}

ZWaveNode *ZWaveManager::unpackNode(const QVariantMap &nodeMap, ZWaveNode *node)
{
    if (!node) {
        node = new ZWaveNode(nodeMap.value("networkUuid").toUuid(), nodeMap.value("nodeId").toUInt());
    }

    node->setInitialized(nodeMap.value("initialized").toBool());
    node->setReachable(nodeMap.value("reachable").toBool());
    node->setFailed(nodeMap.value("failed").toBool());
    node->setSleeping(nodeMap.value("sleeping").toBool());
    node->setLinkQuality(nodeMap.value("linkQuality").toUInt());

    QMetaEnum nodeTypeEnum = QMetaEnum::fromType<ZWaveNode::ZWaveNodeType>();
    node->setNodeType(static_cast<ZWaveNode::ZWaveNodeType>(nodeTypeEnum.keyToValue(nodeMap.value("nodeType").toByteArray())));
    QMetaEnum roleEnum = QMetaEnum::fromType<ZWaveNode::ZWaveNodeRole>();
    node->setRole(static_cast<ZWaveNode::ZWaveNodeRole>(roleEnum.keyToValue(nodeMap.value("role").toByteArray())));
    QMetaEnum deviceTypeEnum = QMetaEnum::fromType<ZWaveNode::ZWaveDeviceType>();
    node->setDeviceType(static_cast<ZWaveNode::ZWaveDeviceType>(deviceTypeEnum.keyToValue(nodeMap.value("deviceType").toByteArray())));

    node->setName(nodeMap.value("name").toString());
    node->setManufacturerId(nodeMap.value("manufacturerId").toUInt());
    node->setManufacturerName(nodeMap.value("manufacturerName").toString());
    node->setProductId(nodeMap.value("productId").toUInt());
    node->setProductName(nodeMap.value("productName").toString());
    node->setProductType(nodeMap.value("productType").toUInt());
    node->setVersion(nodeMap.value("version").toUInt());

    node->setIsZWavePlus(nodeMap.value("isZWavePlus").toBool());
    node->setIsSecure(nodeMap.value("isSecure").toBool());
    node->setIsBeaming(nodeMap.value("isBeaming").toBool());


    return node;
}

#include "zwavenode.h"
#include <QMetaEnum>

ZWaveNode::ZWaveNode(const QUuid &networkUuid, quint8 id, QObject *parent):
    QObject{parent},
    m_nodeId(id),
    m_networkUuid(networkUuid)
{

}

quint8 ZWaveNode::nodeId() const
{
    return m_nodeId;
}

QUuid ZWaveNode::networkUuid() const
{
    return m_networkUuid;
}

ZWaveNode::ZWaveNodeType ZWaveNode::nodeType() const
{
    return m_nodeType;
}

void ZWaveNode::setNodeType(ZWaveNodeType nodeType)
{
    if (m_nodeType != nodeType) {
        m_nodeType = nodeType;
        emit nodeTypeChanged();
    }
}

ZWaveNode::ZWaveDeviceType ZWaveNode::deviceType() const
{
    return m_deviceType;
}

void ZWaveNode::setDeviceType(ZWaveDeviceType deviceType)
{
    m_deviceType = deviceType;
}

QString ZWaveNode::deviceTypeString() const
{
    QMetaEnum metaEnum = QMetaEnum::fromType<ZWaveNode::ZWaveDeviceType>();
    return metaEnum.valueToKey(m_deviceType);
}

quint16 ZWaveNode::manufacturerId() const
{
    return m_manufacturerId;
}

void ZWaveNode::setManufacturerId(quint16 manufacturerId)
{
    if (m_manufacturerId != manufacturerId) {
        m_manufacturerId = manufacturerId;
        emit manufacturerIdChanged();
    }
}

QString ZWaveNode::manufacturerName() const
{
    return m_manufacturerName;
}

void ZWaveNode::setManufacturerName(const QString &manufacturerName)
{
    if (m_manufacturerName != manufacturerName) {
        m_manufacturerName = manufacturerName;
        emit manufacturerNameChanged();
    }
}

QString ZWaveNode::name() const
{
    return m_name;
}

void ZWaveNode::setName(const QString &name)
{
    if (m_name != name) {
        m_name = name;
        emit nameChanged();
    }
}

quint16 ZWaveNode::productId() const
{
    return m_productId;
}

void ZWaveNode::setProductId(quint16 productId)
{
    if (m_productId != productId) {
        m_productId = productId;
        emit productIdChanged();
    }
}

QString ZWaveNode::productName() const
{
    return m_productName;
}

void ZWaveNode::setProductName(const QString &productName)
{
    if (m_productName != productName) {
        m_productName = productName;
        emit productNameChanged();
    }
}

quint16 ZWaveNode::productType() const
{
    return m_productType;
}

void ZWaveNode::setProductType(quint16 productType)
{
    if (m_productType != productType) {
        m_productType = productType;
        emit productTypeChanged();
    }
}

quint8 ZWaveNode::version() const
{
    return m_version;
}

void ZWaveNode::setVersion(quint8 version)
{
    if (m_version != version) {
        m_version = version;
        emit versionChanged();
    }
}

bool ZWaveNode::isZWavePlus() const
{
    return m_isZWavePlus;;
}

void ZWaveNode::setIsZWavePlus(bool isZWavePlus)
{
    if (m_isZWavePlus != isZWavePlus) {
        m_isZWavePlus = isZWavePlus;
        emit isZWavePlusChanged();
    }
}

bool ZWaveNode::reachable() const
{
    return m_reachable;
}

void ZWaveNode::setReachable(bool reachable)
{
    if (m_reachable != reachable) {
        m_reachable = reachable;
        emit reachableChanged();
    }
}

bool ZWaveNode::failed() const
{
    return m_failed;
}

void ZWaveNode::setFailed(bool failed)
{
    if (m_failed != failed) {
        m_failed = failed;
        emit failedChanged();
    }
}

bool ZWaveNode::sleeping() const
{
    return m_sleeping;
}

void ZWaveNode::setSleeping(bool sleeping)
{
    if (m_sleeping != sleeping) {
        m_sleeping = sleeping;
        emit sleepingChanged();
    }
}

bool ZWaveNode::initialized() const
{
    return m_initialized;
}

void ZWaveNode::setInitialized(bool initialized)
{
    if (m_initialized != initialized) {
        m_initialized = initialized;
        emit initializedChanged();
    }
}


ZWaveNodes::ZWaveNodes(QObject *parent):
    QAbstractListModel(parent)
{

}

int ZWaveNodes::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return m_list.count();
}

QVariant ZWaveNodes::data(const QModelIndex &index, int role) const
{
    return QVariant();
}

QHash<int, QByteArray> ZWaveNodes::roleNames() const
{
    return {{RoleId, "nodeId"}};
}

void ZWaveNodes::clear()
{
    beginResetModel();
    qDeleteAll(m_list);
    endResetModel();
    emit countChanged();
}

void ZWaveNodes::addNode(ZWaveNode *node)
{
    node->setParent(this);
    beginInsertRows(QModelIndex(), m_list.count(), m_list.count());
    m_list.append(node);
    endInsertRows();
    emit countChanged();
}

void ZWaveNodes::removeNode(quint8 nodeId)
{
    for (int i = 0; i < m_list.count(); i++) {
        if (m_list.at(i)->nodeId() == nodeId) {
            beginRemoveRows(QModelIndex(), i, i);
            m_list.takeAt(i)->deleteLater();
            endRemoveRows();
            emit countChanged();
        }
    }
}

ZWaveNode *ZWaveNodes::get(int index) const
{
    if (index < 0 || index >= m_list.count()) {
        return nullptr;
    }
    return m_list.at(index);
}

ZWaveNode *ZWaveNodes::getNode(quint8 nodeId)
{
    foreach (ZWaveNode *node, m_list) {
        if (node->nodeId() == nodeId) {
            return node;
        }
    }
    return nullptr;
}

ZWaveNodesProxy::ZWaveNodesProxy(QObject *parent):
    QSortFilterProxyModel(parent)
{

}

ZWaveNodes *ZWaveNodesProxy::zwaveNodes() const
{
    return m_nodes;
}

void ZWaveNodesProxy::setZWaveNodes(ZWaveNodes *nodes)
{
    if (m_nodes != nodes) {
        m_nodes = nodes;
        emit zwaveNodesChanged();
        setSourceModel(nodes);

    }
}

bool ZWaveNodesProxy::showController() const
{
    return m_showController;
}

void ZWaveNodesProxy::setShowController(bool showController)
{
    if (m_showController != showController) {
        m_showController = showController;
        emit showControllerChanged();
        invalidateFilter();
    }
}

bool ZWaveNodesProxy::showOnline() const
{
    return m_showOnline;
}

void ZWaveNodesProxy::setShowOnline(bool showOnline)
{
    if (m_showOnline != showOnline) {
        m_showOnline = showOnline;
        emit showOnlineChanged();
        invalidateFilter();
    }
}

bool ZWaveNodesProxy::showOffline() const
{
    return m_showOffline;
}

void ZWaveNodesProxy::setShowOffline(bool showOffline)
{
    if (m_showOffline != showOffline) {
        m_showOffline = showOffline;
        emit showOfflineChanged();
        invalidateFilter();
    }
}

bool ZWaveNodesProxy::newOnTop() const
{
    return m_newOnTop;
}

void ZWaveNodesProxy::setNewOnTop(bool newOnTop)
{
    if (m_newOnTop != newOnTop) {
        m_newOnTop = newOnTop;
        emit newOnTopChanged();

        // TODO: sorting!
    }
}

ZWaveNode *ZWaveNodesProxy::get(int index) const
{
    return m_nodes->get(mapToSource(this->index(index, 0)).row());
}

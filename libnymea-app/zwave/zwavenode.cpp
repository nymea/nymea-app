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

#include "zwavenode.h"
#include <QMetaEnum>
#include <QRegularExpression>

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

QString ZWaveNode::nodeTypeString() const
{
    QMetaEnum metaEnum = QMetaEnum::fromType<ZWaveNode::ZWaveNodeType>();
    return QString(metaEnum.valueToKey(m_nodeType)).remove(QRegularExpression("^ZWaveNodeType"));
}

ZWaveNode::ZWaveNodeRole ZWaveNode::role() const
{
    return m_role;
}

void ZWaveNode::setRole(ZWaveNodeRole role)
{
    if (m_role != role) {
        m_role = role;
        emit roleChanged();
    }
}

QString ZWaveNode::roleString() const
{
    QMetaEnum metaEnum = QMetaEnum::fromType<ZWaveNode::ZWaveNodeRole>();
    return QString(metaEnum.valueToKey(m_role)).remove(QRegularExpression("^ZWaveNodeRole"));
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
    return QString(metaEnum.valueToKey(m_deviceType)).remove(QRegularExpression("^ZWaveDeviceType"));
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

bool ZWaveNode::isZWavePlusDevice() const
{
    return m_isZWavePlusDevice;
}

void ZWaveNode::setIsZWavePlusDevice(bool isZWavePlusDevice)
{
    if (m_isZWavePlusDevice != isZWavePlusDevice) {
        m_isZWavePlusDevice = isZWavePlusDevice;
        emit isZWavePlusDeviceChanged();
    }
}

bool ZWaveNode::isSecurityDevice() const
{
    return m_isSecurityDevice;
}

void ZWaveNode::setIsSecurityDevice(bool isSecurityDevice)
{
    if (m_isSecurityDevice != isSecurityDevice) {
        m_isSecurityDevice = isSecurityDevice;
        emit isSecurityDeviceChanged();
    }
}

bool ZWaveNode::isBeamingDevice() const
{
    return m_isBeamingDevice;
}

void ZWaveNode::setIsBeamingDevice(bool isBeamingDevice)
{
    if (m_isBeamingDevice != isBeamingDevice) {
        m_isBeamingDevice = isBeamingDevice;
        emit isBeamingDeviceChanged();
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

quint8 ZWaveNode::linkQuality() const
{
    return m_linkQuality;
}

void ZWaveNode::setLinkQuality(quint8 linkQuality)
{
    if (m_linkQuality != linkQuality) {
        m_linkQuality = linkQuality;
        emit linkQualityChanged();
    }
}

quint8 ZWaveNode::securityMode() const
{
    return m_securityMode;
}

void ZWaveNode::setSecurityMode(quint8 securityMode)
{
    if (m_securityMode != securityMode) {
        m_securityMode = securityMode;
        emit securityModeChanged();
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
    return static_cast<int>(m_list.count());
}

QVariant ZWaveNodes::data(const QModelIndex &index, int role) const
{
    Q_UNUSED(index)
    Q_UNUSED(role)
    return QVariant();
}

QHash<int, QByteArray> ZWaveNodes::roleNames() const
{
    return {{RoleId, "nodeId"}};
}

void ZWaveNodes::clear()
{
    beginResetModel();
    foreach (ZWaveNode *node, m_list)
        node->deleteLater();

    m_list.clear();
    endResetModel();
    emit countChanged();
}

void ZWaveNodes::addNode(ZWaveNode *node)
{
    node->setParent(this);
    beginInsertRows(QModelIndex(), static_cast<int>(m_list.count()), static_cast<int>(m_list.count()));
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

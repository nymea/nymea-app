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

#include "zigbeenodes.h"

ZigbeeNodes::ZigbeeNodes(QObject *parent) : QAbstractListModel(parent)
{

}

int ZigbeeNodes::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return static_cast<int>(m_nodes.count());
}

QVariant ZigbeeNodes::data(const QModelIndex &index, int role) const
{
    switch (role) {
    case RoleNetworkUuid:
        return m_nodes.at(index.row())->networkUuid();
    case RoleIeeeAddress:
        return m_nodes.at(index.row())->ieeeAddress();
    case RoleNetworkAddress:
        return m_nodes.at(index.row())->networkAddress();
    case RoleType:
        return m_nodes.at(index.row())->type();
    case RoleState:
        return m_nodes.at(index.row())->state();
    case RoleManufacturer:
        return m_nodes.at(index.row())->manufacturer();
    case RoleModel:
        return m_nodes.at(index.row())->model();
    case RoleVersion:
        return m_nodes.at(index.row())->version();
    case RoleRxOnWhenIdle:
        return m_nodes.at(index.row())->rxOnWhenIdle();
    case RoleReachable:
        return m_nodes.at(index.row())->reachable();
    case RoleLqi:
        return m_nodes.at(index.row())->lqi();
    case RoleLastSeen:
        return m_nodes.at(index.row())->lastSeen();
    }

    return QVariant();
}

QHash<int, QByteArray> ZigbeeNodes::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles.insert(RoleNetworkUuid, "networkUuid");
    roles.insert(RoleIeeeAddress, "ieeeAddress");
    roles.insert(RoleNetworkAddress, "networkAddress");
    roles.insert(RoleType, "type");
    roles.insert(RoleState, "state");
    roles.insert(RoleManufacturer, "manufacturer");
    roles.insert(RoleModel, "model");
    roles.insert(RoleVersion, "version");
    roles.insert(RoleRxOnWhenIdle, "rxOnWhenIdle");
    roles.insert(RoleReachable, "reachable");
    roles.insert(RoleLqi, "lqi");
    roles.insert(RoleLastSeen, "lastSeen");
    return roles;
}

void ZigbeeNodes::addNode(ZigbeeNode *node)
{
    node->setParent(this);
    beginInsertRows(QModelIndex(), static_cast<int>(m_nodes.count()), static_cast<int>(m_nodes.count()));
    m_nodes.append(node);

    connect(node, &ZigbeeNode::networkAddressChanged, this, [this, node]() {
        QModelIndex idx = index(static_cast<int>(m_nodes.indexOf(node)), 0);
        emit dataChanged(idx, idx, {RoleNetworkAddress});
    });

    connect(node, &ZigbeeNode::typeChanged, this, [this, node]() {
        QModelIndex idx = index(static_cast<int>(m_nodes.indexOf(node)), 0);
        emit dataChanged(idx, idx, {RoleType});
    });

    connect(node, &ZigbeeNode::stateChanged, this, [this, node]() {
        QModelIndex idx = index(static_cast<int>(m_nodes.indexOf(node)), 0);
        emit dataChanged(idx, idx, {RoleState});
    });

    connect(node, &ZigbeeNode::manufacturerChanged, this, [this, node]() {
        QModelIndex idx = index(static_cast<int>(m_nodes.indexOf(node)), 0);
        emit dataChanged(idx, idx, {RoleManufacturer});
    });

    connect(node, &ZigbeeNode::modelChanged, this, [this, node]() {
        QModelIndex idx = index(static_cast<int>(m_nodes.indexOf(node)), 0);
        emit dataChanged(idx, idx, {RoleModel});
    });

    connect(node, &ZigbeeNode::versionChanged, this, [this, node]() {
        QModelIndex idx = index(static_cast<int>(m_nodes.indexOf(node)), 0);
        emit dataChanged(idx, idx, {RoleVersion});
    });

    connect(node, &ZigbeeNode::rxOnWhenIdleChanged, this, [this, node]() {
        QModelIndex idx = index(static_cast<int>(m_nodes.indexOf(node)), 0);
        emit dataChanged(idx, idx, {RoleRxOnWhenIdle});
    });

    connect(node, &ZigbeeNode::reachableChanged, this, [this, node]() {
        QModelIndex idx = index(static_cast<int>(m_nodes.indexOf(node)), 0);
        emit dataChanged(idx, idx, {RoleReachable});
    });

    connect(node, &ZigbeeNode::lqiChanged, this, [this, node]() {
        QModelIndex idx = index(static_cast<int>(m_nodes.indexOf(node)), 0);
        emit dataChanged(idx, idx, {RoleLqi});
    });

    connect(node, &ZigbeeNode::lastSeenChanged, this, [this, node]() {
        QModelIndex idx = index(static_cast<int>(m_nodes.indexOf(node)), 0);
        emit dataChanged(idx, idx, {RoleLastSeen});
    });

    endInsertRows();
    emit countChanged();

    emit nodeAdded(node);
}

void ZigbeeNodes::removeNode(const QString &ieeeAddress)
{
    for (int i = 0; i < m_nodes.count(); i++) {
        if (m_nodes.at(i)->ieeeAddress() == ieeeAddress) {
            beginRemoveRows(QModelIndex(), i, i);
            m_nodes.takeAt(i)->deleteLater();
            endRemoveRows();
            emit countChanged();
            emit nodeRemoved(ieeeAddress);
            return;
        }
    }
}

void ZigbeeNodes::clear()
{
    beginResetModel();
    foreach (ZigbeeNode *node, m_nodes)
        node->deleteLater();

    m_nodes.clear();
    endResetModel();
    emit countChanged();
}

ZigbeeNode *ZigbeeNodes::get(int index) const
{
    if (index < 0 || index >= m_nodes.count()) {
        return nullptr;
    }
    return m_nodes.at(index);
}

ZigbeeNode *ZigbeeNodes::getNode(const QString &ieeeAddress) const
{
    foreach (ZigbeeNode *node, m_nodes) {
        if (node->ieeeAddress() == ieeeAddress) {
            return node;
        }
    }

    return nullptr;
}

ZigbeeNode *ZigbeeNodes::getNodeByNetworkAddress(quint16 networkAddress) const
{
    foreach (ZigbeeNode *node, m_nodes) {
        if (node->networkAddress() == networkAddress) {
            return node;
        }
    }
    return nullptr;
}

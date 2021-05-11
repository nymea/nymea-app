/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
* Copyright 2013 - 2021, nymea GmbH
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

#include "zigbeenodes.h"

ZigbeeNodes::ZigbeeNodes(QObject *parent) : QAbstractListModel(parent)
{

}

int ZigbeeNodes::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return m_nodes.count();
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
    beginInsertRows(QModelIndex(), m_nodes.count(), m_nodes.count());
    m_nodes.append(node);

    connect(node, &ZigbeeNode::networkAddressChanged, this, [this, node]() {
        QModelIndex idx = index(m_nodes.indexOf(node), 0);
        emit dataChanged(idx, idx, {RoleNetworkAddress});
    });

    connect(node, &ZigbeeNode::typeChanged, this, [this, node]() {
        QModelIndex idx = index(m_nodes.indexOf(node), 0);
        emit dataChanged(idx, idx, {RoleType});
    });

    connect(node, &ZigbeeNode::stateChanged, this, [this, node]() {
        QModelIndex idx = index(m_nodes.indexOf(node), 0);
        emit dataChanged(idx, idx, {RoleState});
    });

    connect(node, &ZigbeeNode::manufacturerChanged, this, [this, node]() {
        QModelIndex idx = index(m_nodes.indexOf(node), 0);
        emit dataChanged(idx, idx, {RoleManufacturer});
    });

    connect(node, &ZigbeeNode::modelChanged, this, [this, node]() {
        QModelIndex idx = index(m_nodes.indexOf(node), 0);
        emit dataChanged(idx, idx, {RoleModel});
    });

    connect(node, &ZigbeeNode::versionChanged, this, [this, node]() {
        QModelIndex idx = index(m_nodes.indexOf(node), 0);
        emit dataChanged(idx, idx, {RoleVersion});
    });

    connect(node, &ZigbeeNode::rxOnWhenIdleChanged, this, [this, node]() {
        QModelIndex idx = index(m_nodes.indexOf(node), 0);
        emit dataChanged(idx, idx, {RoleRxOnWhenIdle});
    });

    connect(node, &ZigbeeNode::reachableChanged, this, [this, node]() {
        QModelIndex idx = index(m_nodes.indexOf(node), 0);
        emit dataChanged(idx, idx, {RoleReachable});
    });

    connect(node, &ZigbeeNode::lqiChanged, this, [this, node]() {
        QModelIndex idx = index(m_nodes.indexOf(node), 0);
        emit dataChanged(idx, idx, {RoleLqi});
    });

    connect(node, &ZigbeeNode::lastSeenChanged, this, [this, node]() {
        QModelIndex idx = index(m_nodes.indexOf(node), 0);
        emit dataChanged(idx, idx, {RoleLastSeen});
    });

    endInsertRows();
    emit countChanged();
}

void ZigbeeNodes::removeNode(const QString &ieeeAddress)
{
    for (int i = 0; i < m_nodes.count(); i++) {
        if (m_nodes.at(i)->ieeeAddress() == ieeeAddress) {
            beginRemoveRows(QModelIndex(), i, i);
            m_nodes.takeAt(i)->deleteLater();
            endRemoveRows();
            emit countChanged();
            return;
        }
    }
}

void ZigbeeNodes::clear()
{
    beginResetModel();
    qDeleteAll(m_nodes);
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

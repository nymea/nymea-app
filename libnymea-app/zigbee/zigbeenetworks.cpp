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

#include "zigbeenetworks.h"

ZigbeeNetworks::ZigbeeNetworks(QObject *parent) : QAbstractListModel(parent)
{

}

int ZigbeeNetworks::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return m_networks.count();
}

QVariant ZigbeeNetworks::data(const QModelIndex &index, int role) const
{
    switch (role) {
    case RoleUuid:
        return m_networks.at(index.row())->networkUuid();
    case RoleSerialPort:
        return m_networks.at(index.row())->serialPort();
    case RoleBaudRate:
        return m_networks.at(index.row())->baudRate();
    case RoleMacAddress:
        return m_networks.at(index.row())->macAddress();
    case RoleFirmwareVersion:
        return m_networks.at(index.row())->firmwareVersion();
    case RolePanId:
        return m_networks.at(index.row())->panId();
    case RoleChannel:
        return m_networks.at(index.row())->channel();
    case RoleChannelMask:
        return m_networks.at(index.row())->channelMask();
    case RolePermitJoiningEnabled:
        return m_networks.at(index.row())->permitJoiningEnabled();
    case RolePermitJoiningDuration:
        return m_networks.at(index.row())->permitJoiningDuration();
    case RolePermitJoiningRemaining:
        return m_networks.at(index.row())->permitJoiningRemaining();
    case RoleBackendType:
        return m_networks.at(index.row())->backendType();
    case RoleNetworkState:
        return m_networks.at(index.row())->networkState();
    }

    return QVariant();
}

QHash<int, QByteArray> ZigbeeNetworks::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles.insert(RoleUuid, "networkUuid");
    roles.insert(RoleSerialPort, "serialPort");
    roles.insert(RoleBaudRate, "baudRate");
    roles.insert(RoleMacAddress, "macAddress");
    roles.insert(RoleFirmwareVersion, "firmwareVersion");
    roles.insert(RolePanId, "panId");
    roles.insert(RoleChannel, "channel");
    roles.insert(RoleChannelMask, "channelMask");
    roles.insert(RolePermitJoiningEnabled, "permitJoiningEnabled");
    roles.insert(RolePermitJoiningDuration, "permitJoiningDuration");
    roles.insert(RolePermitJoiningRemaining, "permitJoiningRemaining");
    roles.insert(RoleBackendType, "backendType");
    roles.insert(RoleNetworkState, "networkState");
    return roles;

}

void ZigbeeNetworks::addNetwork(ZigbeeNetwork *network)
{
    network->setParent(this);
    beginInsertRows(QModelIndex(), m_networks.count(), m_networks.count());
    m_networks.append(network);
    connect(network, &ZigbeeNetwork::networkUuidChanged, this, [this, network]() {
        QModelIndex idx = index(m_networks.indexOf(network), 0);
        emit dataChanged(idx, idx, {RoleUuid});
    });

    connect(network, &ZigbeeNetwork::serialPortChanged, this, [this, network]() {
        QModelIndex idx = index(m_networks.indexOf(network), 0);
        emit dataChanged(idx, idx, {RoleSerialPort});
    });

    connect(network, &ZigbeeNetwork::baudRateChanged, this, [this, network]() {
        QModelIndex idx = index(m_networks.indexOf(network), 0);
        emit dataChanged(idx, idx, {RoleBaudRate});
    });

    connect(network, &ZigbeeNetwork::macAddressChanged, this, [this, network]() {
        QModelIndex idx = index(m_networks.indexOf(network), 0);
        emit dataChanged(idx, idx, {RoleMacAddress});
    });

    connect(network, &ZigbeeNetwork::firmwareVersionChanged, this, [this, network]() {
        QModelIndex idx = index(m_networks.indexOf(network), 0);
        emit dataChanged(idx, idx, {RoleFirmwareVersion});
    });

    connect(network, &ZigbeeNetwork::panIdChanged, this, [this, network]() {
        QModelIndex idx = index(m_networks.indexOf(network), 0);
        emit dataChanged(idx, idx, {RolePanId});
    });

    connect(network, &ZigbeeNetwork::channelChanged, this, [this, network]() {
        QModelIndex idx = index(m_networks.indexOf(network), 0);
        emit dataChanged(idx, idx, {RoleChannel});
    });

    connect(network, &ZigbeeNetwork::channelMaskChanged, this, [this, network]() {
        QModelIndex idx = index(m_networks.indexOf(network), 0);
        emit dataChanged(idx, idx, {RoleChannelMask});
    });

    connect(network, &ZigbeeNetwork::permitJoiningEnabledChanged, this, [this, network]() {
        QModelIndex idx = index(m_networks.indexOf(network), 0);
        emit dataChanged(idx, idx, {RolePermitJoiningEnabled});
    });

    connect(network, &ZigbeeNetwork::permitJoiningDurationChanged, this, [this, network]() {
        QModelIndex idx = index(m_networks.indexOf(network), 0);
        emit dataChanged(idx, idx, {RolePermitJoiningDuration});
    });

    connect(network, &ZigbeeNetwork::permitJoiningRemainingChanged, this, [this, network]() {
        QModelIndex idx = index(m_networks.indexOf(network), 0);
        emit dataChanged(idx, idx, {RolePermitJoiningRemaining});
    });

    connect(network, &ZigbeeNetwork::backendTypeChanged, this, [this, network]() {
        QModelIndex idx = index(m_networks.indexOf(network), 0);
        emit dataChanged(idx, idx, {RoleBackendType});
    });

    connect(network, &ZigbeeNetwork::networkStateChanged, this, [this, network]() {
        QModelIndex idx = index(m_networks.indexOf(network), 0);
        emit dataChanged(idx, idx, {RoleNetworkState});
    });

    endInsertRows();
    emit countChanged();

}

void ZigbeeNetworks::removeNetwork(const QUuid &networkUuid)
{
    for (int i = 0; i < m_networks.count(); i++) {
        if (m_networks.at(i)->networkUuid() == networkUuid) {
            beginRemoveRows(QModelIndex(), i, i);
            m_networks.takeAt(i)->deleteLater();
            endRemoveRows();
            return;
        }
    }
}

void ZigbeeNetworks::clear()
{
    beginResetModel();
    qDeleteAll(m_networks);
    m_networks.clear();
    endResetModel();
    emit countChanged();
}

ZigbeeNetwork *ZigbeeNetworks::get(int index) const
{
    if (index < 0 || index > m_networks.count() - 1) {
        return nullptr;
    }
    return m_networks.at(index);
}

ZigbeeNetwork *ZigbeeNetworks::getNetwork(const QUuid &networkUuid) const
{
    foreach (ZigbeeNetwork *network, m_networks) {
        if (network->networkUuid() == networkUuid) {
            return network;
        }
    }

    return nullptr;
}

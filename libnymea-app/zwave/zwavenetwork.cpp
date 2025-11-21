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

#include "zwavenetwork.h"
#include "zwavenode.h"

ZWaveNetwork::ZWaveNetwork(const QUuid &networkUuid, const QString &serialPort, QObject *parent):
    QObject(parent),
    m_networkUuid(networkUuid),
    m_serialPort(serialPort),
    m_nodes(new ZWaveNodes(this))
{

}

QUuid ZWaveNetwork::networkUuid() const
{
    return m_networkUuid;
}

QString ZWaveNetwork::serialPort() const
{
    return m_serialPort;
}

quint32 ZWaveNetwork::homeId() const
{
    return m_homeId;
}

void ZWaveNetwork::setHomeId(quint32 homeId)
{
    if (m_homeId != homeId) {
        m_homeId = homeId;
        emit homeIdChanged();
    }
}

bool ZWaveNetwork::isZWavePlus() const
{
    return m_isZWavePlus;
}

void ZWaveNetwork::setIsZWavePlus(bool isZWavePlus)
{
    if (m_isZWavePlus != isZWavePlus) {
        m_isZWavePlus = isZWavePlus;
        emit isZWavePlusChanged();
    }
}

bool ZWaveNetwork::isPrimaryController() const
{
    return m_isPrimaryController;
}

void ZWaveNetwork::setIsPrimaryController(bool isPrimaryController)
{
    if (m_isPrimaryController != isPrimaryController) {
        m_isPrimaryController = isPrimaryController;
        emit isPrimaryControllerChanged();
    }
}

bool ZWaveNetwork::isStaticUpdateController() const
{
    return m_isStaticUpdateController;
}

void ZWaveNetwork::setIsStaticUpdateController(bool isStaticUpdateController)
{
    if (m_isStaticUpdateController != isStaticUpdateController) {
        m_isStaticUpdateController = isStaticUpdateController;
        emit isStaticUpdateControllerChanged();
    }
}

bool ZWaveNetwork::isBridgeController() const
{
    return m_isBridgeController;
}

void ZWaveNetwork::setIsBridgeController(bool isBridgeController)
{
    if (m_isBridgeController != isBridgeController) {
        m_isBridgeController = isBridgeController;
        emit isBridgeControllerChanged();
    }
}

bool ZWaveNetwork::waitingForNodeAddition() const
{
    return m_waitingForNodeAddition;
}

void ZWaveNetwork::setWaitingForNodeAddition(bool waitingForNodeAddition)
{
    if (m_waitingForNodeAddition != waitingForNodeAddition) {
        m_waitingForNodeAddition = waitingForNodeAddition;
        emit waitingForNodeAdditionChanged();
    }
}

bool ZWaveNetwork::waitingForNodeRemoval() const
{
    return m_waitingForNodeRemoval;
}

void ZWaveNetwork::setWaitingForNodeRemoval(bool waitingForNodeRemoval)
{
    if (m_waitingForNodeRemoval != waitingForNodeRemoval) {
        m_waitingForNodeRemoval = waitingForNodeRemoval;
        emit waitingForNodeRemovalChanged();
    }
}

ZWaveNetwork::ZWaveNetworkState ZWaveNetwork::networkState() const
{
    return m_networkState;
}

void ZWaveNetwork::setNetworkState(ZWaveNetworkState networkState)
{
    if (m_networkState != networkState) {
        m_networkState = networkState;
        emit networkStateChanged();
    }
}

ZWaveNodes *ZWaveNetwork::nodes() const
{
    return m_nodes;
}

void ZWaveNetwork::addNode(ZWaveNode *node)
{
    m_nodes->addNode(node);
}

void ZWaveNetwork::removeNode(quint8 nodeId)
{
    m_nodes->removeNode(nodeId);
}

ZWaveNetworks::ZWaveNetworks(QObject *parent):
    QAbstractListModel(parent)
{

}

int ZWaveNetworks::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return static_cast<int>(m_list.count());
}

QVariant ZWaveNetworks::data(const QModelIndex &index, int role) const
{
    switch (role) {
    case RoleUuid:
        return m_list.at(index.row())->networkUuid();
    case RoleSerialPort:
        return m_list.at(index.row())->serialPort();
    case RoleHomeId:
        return m_list.at(index.row())->homeId();
    case RoleIsZWavePlus:
        return m_list.at(index.row())->isZWavePlus();
    case RoleIsPrimaryController:
        return m_list.at(index.row())->isPrimaryController();
    case RoleIsStaticUpdateController:
        return m_list.at(index.row())->isStaticUpdateController();
    case RoleNetworkState:
        return m_list.at(index.row())->networkState();
    }
    return QVariant();
}

QHash<int, QByteArray> ZWaveNetworks::roleNames() const
{
    return {
        {RoleUuid, "networkUuid"},
        {RoleSerialPort, "serialPort"},
        {RoleHomeId, "homeId"},
        {RoleIsZWavePlus, "isZWavePlus"},
        {RoleIsPrimaryController, "isPrimaryController"},
        {RoleIsStaticUpdateController, "isStaticUpdateController"},
        {RoleNetworkState, "networkState"}
    };
}

void ZWaveNetworks::clear()
{
    beginResetModel();
    qDeleteAll(m_list);
    endResetModel();
}

void ZWaveNetworks::addNetwork(ZWaveNetwork *network)
{
    network->setParent(this);
    beginInsertRows(QModelIndex(), static_cast<int>(m_list.count()), static_cast<int>(m_list.count()));
    m_list.append(network);
    endInsertRows();
    emit countChanged();

    connect(network, &ZWaveNetwork::networkStateChanged, this, [this, network](){
        QModelIndex idx = index(static_cast<int>(m_list.indexOf(network)));
        emit dataChanged(idx, idx, {RoleNetworkState});
    });
}

void ZWaveNetworks::removeNetwork(const QUuid &networkUuid)
{
    for (int i = 0; i < m_list.count(); i++) {
        if (m_list.at(i)->networkUuid() == networkUuid) {
            beginRemoveRows(QModelIndex(), i, i);
            m_list.takeAt(i)->deleteLater();
            endRemoveRows();
            emit countChanged();
            return;
        }
    }
}

ZWaveNetwork *ZWaveNetworks::get(int index) const
{
    if (index < 0 || index >= m_list.count()) {
        return nullptr;
    }
    return m_list.at(index);
}

ZWaveNetwork *ZWaveNetworks::getNetwork(const QUuid &networkUuid)
{
    foreach (ZWaveNetwork *network, m_list) {
        if (network->networkUuid() == networkUuid) {
            return network;
        }
    }
    return nullptr;
}

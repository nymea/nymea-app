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

#include "zigbeenode.h"

ZigbeeNode::ZigbeeNode(const QUuid &networkUuid, const QString &ieeeAddress, QObject *parent) :
    QObject(parent),
    m_networkUuid(networkUuid),
    m_ieeeAddress(ieeeAddress)
{

}

QUuid ZigbeeNode::networkUuid() const
{
    return m_networkUuid;
}

QString ZigbeeNode::ieeeAddress() const
{
    return m_ieeeAddress;
}

quint16 ZigbeeNode::networkAddress() const
{
    return m_networkAddress;
}

void ZigbeeNode::setNetworkAddress(quint16 networkAddress)
{
    if (m_networkAddress == networkAddress)
        return;

    m_networkAddress = networkAddress;
    emit networkAddressChanged(m_networkAddress);
}

ZigbeeNode::ZigbeeNodeType ZigbeeNode::type() const
{
    return m_type;
}

void ZigbeeNode::setType(ZigbeeNode::ZigbeeNodeType type)
{
    if (m_type == type)
        return;

    m_type = type;
    emit typeChanged(m_type);
}

ZigbeeNode::ZigbeeNodeState ZigbeeNode::state() const
{
    return m_state;
}

void ZigbeeNode::setState(ZigbeeNode::ZigbeeNodeState state)
{
    if (m_state == state)
        return;

    m_state = state;
    emit stateChanged(m_state);
}

QString ZigbeeNode::manufacturer() const
{
    return m_manufacturer;
}

void ZigbeeNode::setManufacturer(const QString &manufacturer)
{
    if (m_manufacturer == manufacturer)
        return;

    m_manufacturer = manufacturer;
    emit manufacturerChanged(m_manufacturer);
}

QString ZigbeeNode::model() const
{
    return m_model;
}

void ZigbeeNode::setModel(const QString &model)
{
    if (m_model == model)
        return;

    m_model = model;
    emit modelChanged(m_model);
}

QString ZigbeeNode::version() const
{
    return m_version;
}

void ZigbeeNode::setVersion(const QString &version)
{
    if (m_version == version)
        return;

    m_version = version;
    emit versionChanged(m_version);
}

bool ZigbeeNode::rxOnWhenIdle() const
{
    return m_rxOnWhenIdle;
}

void ZigbeeNode::setRxOnWhenIdle(bool rxOnWhenIdle)
{
    if (m_rxOnWhenIdle == rxOnWhenIdle)
        return;

    m_rxOnWhenIdle = rxOnWhenIdle;
    emit rxOnWhenIdleChanged(m_rxOnWhenIdle);
}

bool ZigbeeNode::reachable() const
{
    return m_reachable;
}

void ZigbeeNode::setReachable(bool reachable)
{
    if (m_reachable == reachable)
        return;

    m_reachable = reachable;
    emit reachableChanged(m_reachable);
}

uint ZigbeeNode::lqi() const
{
    return m_lqi;
}

void ZigbeeNode::setLqi(uint lqi)
{
    if (m_lqi == lqi)
        return;

    m_lqi = lqi;
    emit lqiChanged(m_lqi);

}

QDateTime ZigbeeNode::lastSeen() const
{
    return m_lastSeen;
}

void ZigbeeNode::setLastSeen(const QDateTime &lastSeen)
{
    if (m_lastSeen == lastSeen)
        return;

    m_lastSeen = lastSeen;
    emit lastSeenChanged(m_lastSeen);
}

QList<ZigbeeNodeNeighbor *> ZigbeeNode::neighbors() const
{
    return m_neighbors;
}

void ZigbeeNode::addOrUpdateNeighbor(quint16 networkAddress, ZigbeeNodeRelationship relationship, quint8 lqi, quint8 depth, bool permitJoining)
{
    foreach (ZigbeeNodeNeighbor *neighbor, m_neighbors) {
        if (neighbor->networkAddress() == networkAddress) {
            if (neighbor->relationship() != relationship) {
                neighbor->setRelationship(relationship);
                m_neighborsDirty = true;
            }
            if (neighbor->lqi() != lqi) {
                neighbor->setLqi(lqi);
                m_neighborsDirty = true;
            }
            if (neighbor->permitJoining() != permitJoining) {
                neighbor->setPermitJoining(permitJoining);
                m_neighborsDirty = true;
            }
            return;
        }
    }
    ZigbeeNodeNeighbor *neighbor = new ZigbeeNodeNeighbor(networkAddress, this);
    neighbor->setRelationship(relationship);
    neighbor->setLqi(lqi);
    neighbor->setDepth(depth);
    m_neighbors.append(neighbor);
    m_neighborsDirty = true;
}

void ZigbeeNode::commitNeighbors(QList<quint16> toBeKept)
{
    QMutableListIterator<ZigbeeNodeNeighbor*> iter(m_neighbors);

    while (iter.hasNext()) {
        ZigbeeNodeNeighbor *neighbor = iter.next();
        if (!toBeKept.contains(neighbor->networkAddress())) {
            iter.remove();
            neighbor->deleteLater();
            m_neighborsDirty = true;
        }
    }
    if (m_neighborsDirty) {
        emit neighborsChanged();
        m_neighborsDirty = false;
    }
}

ZigbeeNode::ZigbeeNodeState ZigbeeNode::stringToNodeState(const QString &nodeState)
{
    if (nodeState == "ZigbeeNodeStateUninitialized") {
        return ZigbeeNodeStateUninitialized;
    } else if (nodeState == "ZigbeeNodeStateInitializing") {
        return ZigbeeNodeStateInitializing;
    } else if (nodeState == "ZigbeeNodeStateInitialized") {
        return ZigbeeNodeStateInitialized;
    } else {
        return ZigbeeNodeStateHandled;
    }
}

ZigbeeNode::ZigbeeNodeType ZigbeeNode::stringToNodeType(const QString &nodeType)
{
    if (nodeType == "ZigbeeNodeTypeCoordinator") {
        return ZigbeeNodeTypeCoordinator;
    } else if (nodeType == "ZigbeeNodeTypeRouter") {
        return ZigbeeNodeTypeRouter;
    } else {
        return ZigbeeNodeTypeEndDevice;
    }
}

ZigbeeNodeNeighbor::ZigbeeNodeNeighbor(quint16 networkAddress, QObject *parent):
    QObject(parent),
    m_networkAddress(networkAddress)
{

}

quint16 ZigbeeNodeNeighbor::networkAddress() const
{
    return m_networkAddress;
}

ZigbeeNode::ZigbeeNodeRelationship ZigbeeNodeNeighbor::relationship() const
{
    return m_relationship;
}

void ZigbeeNodeNeighbor::setRelationship(ZigbeeNode::ZigbeeNodeRelationship relationship)
{
    if (m_relationship != relationship) {
        m_relationship = relationship;
        emit relationshipChanged();
    }
}

quint8 ZigbeeNodeNeighbor::lqi() const
{
    return m_lqi;
}

void ZigbeeNodeNeighbor::setLqi(quint8 lqi)
{
    if (m_lqi != lqi) {
        m_lqi = lqi;
        emit lqiChanged();
    }
}

quint8 ZigbeeNodeNeighbor::depth() const
{
    return m_depth;
}

void ZigbeeNodeNeighbor::setDepth(quint8 depth)
{
    if (m_depth != depth) {
        m_depth = depth;
        emit depthChanged();
    }
}

bool ZigbeeNodeNeighbor::permitJoining() const
{
    return m_permitJoining;
}

void ZigbeeNodeNeighbor::setPermitJoining(bool permitJoining)
{
    if (m_permitJoining != permitJoining) {
        m_permitJoining = permitJoining;
        emit permitJoiningChanged();
    }
}

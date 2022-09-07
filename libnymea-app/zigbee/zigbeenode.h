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

#ifndef ZIGBEENODE_H
#define ZIGBEENODE_H

#include <QUuid>
#include <QObject>
#include <QDateTime>
#include <QVariantMap>

class ZigbeeNodeNeighbor;
class ZigbeeNodeRoute;

class ZigbeeNode : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QUuid networkUuid READ networkUuid CONSTANT)
    Q_PROPERTY(QString ieeeAddress READ ieeeAddress CONSTANT)
    Q_PROPERTY(quint16 networkAddress READ networkAddress WRITE setNetworkAddress NOTIFY networkAddressChanged)
    Q_PROPERTY(ZigbeeNodeType type READ type WRITE setType NOTIFY typeChanged)
    Q_PROPERTY(ZigbeeNodeState state READ state WRITE setState NOTIFY stateChanged)
    Q_PROPERTY(QString manufacturer READ manufacturer WRITE setManufacturer NOTIFY manufacturerChanged)
    Q_PROPERTY(QString model READ model WRITE setModel NOTIFY modelChanged)
    Q_PROPERTY(QString version READ version WRITE setVersion NOTIFY versionChanged)
    Q_PROPERTY(bool rxOnWhenIdle READ rxOnWhenIdle WRITE setRxOnWhenIdle NOTIFY rxOnWhenIdleChanged)
    Q_PROPERTY(bool reachable READ reachable WRITE setReachable NOTIFY reachableChanged)
    Q_PROPERTY(uint lqi READ lqi WRITE setLqi NOTIFY lqiChanged)
    Q_PROPERTY(QDateTime lastSeen READ lastSeen WRITE setLastSeen NOTIFY lastSeenChanged)
    Q_PROPERTY(QList<ZigbeeNodeNeighbor*> neighbors READ neighbors NOTIFY neighborsChanged)
    Q_PROPERTY(QList<ZigbeeNodeRoute*> routes READ routes NOTIFY routesChanged)

public:
    enum ZigbeeNodeType {
        ZigbeeNodeTypeCoordinator,
        ZigbeeNodeTypeRouter,
        ZigbeeNodeTypeEndDevice
    };
    Q_ENUM(ZigbeeNodeType)

    enum ZigbeeNodeState {
        ZigbeeNodeStateUninitialized,
        ZigbeeNodeStateInitializing,
        ZigbeeNodeStateInitialized,
        ZigbeeNodeStateHandled
    };
    Q_ENUM(ZigbeeNodeState)

    enum ZigbeeNodeRelationship {
        ZigbeeNodeRelationshipParent,
        ZigbeeNodeRelationshipChild,
        ZigbeeNodeRelationshipSibling,
        ZigbeeNodeRelationshipNone,
        ZigbeeNodeRelationshipPreviousChild
    };
    Q_ENUM(ZigbeeNodeRelationship)

    enum ZigbeeNodeRouteStatus {
        ZigbeeNodeRouteStatusActive,
        ZigbeeNodeRouteStatusDiscoveryUnderway,
        ZigbeeNodeRouteStatusDiscoveryFailed,
        ZigbeeNodeRouteStatusInactive,
        ZigbeeNodeRouteStatusValidationUnderway
    };
    Q_ENUM(ZigbeeNodeRouteStatus)

    explicit ZigbeeNode(const QUuid &networkUuid, const QString &ieeeAddress, QObject *parent = nullptr);

    QUuid networkUuid() const;
    QString ieeeAddress() const;

    quint16 networkAddress() const;
    void setNetworkAddress(quint16 networkAddress);

    ZigbeeNodeType type() const;
    void setType(ZigbeeNodeType type);

    ZigbeeNodeState state() const;
    void setState(ZigbeeNodeState state);

    QString manufacturer() const;
    void setManufacturer(const QString &manufacturer);

    QString model() const;
    void setModel(const QString &model);

    QString version() const;
    void setVersion(const QString &version);

    bool rxOnWhenIdle() const;
    void setRxOnWhenIdle(bool rxOnWhenIdle);

    bool reachable() const;
    void setReachable(bool reachable);

    uint lqi() const;
    void setLqi(uint lqi);

    QDateTime lastSeen() const;
    void setLastSeen(const QDateTime &lastSeen);

    QList<ZigbeeNodeNeighbor*> neighbors() const;
    void addOrUpdateNeighbor(quint16 networkAddress, ZigbeeNodeRelationship relationship, quint8 lqi, quint8 depth, bool permitJoining);
    void commitNeighbors(QList<quint16> toBeKept);

    QList<ZigbeeNodeRoute*> routes() const;
    void addOrUpdateRoute(quint16 destinationAddress, quint16 nextHopAddress, ZigbeeNodeRouteStatus status, bool memoryConstrained, bool manyToOne);
    void commitRoutes(QList<quint16> toBeKept);

    static ZigbeeNodeState stringToNodeState(const QString &nodeState);
    static ZigbeeNodeType stringToNodeType(const QString &nodeType);

signals:
    void networkAddressChanged(quint16 networkAddress);
    void typeChanged(ZigbeeNodeType type);
    void stateChanged(ZigbeeNodeState state);
    void manufacturerChanged(const QString &manufacturer);
    void modelChanged(const QString &model);
    void versionChanged(const QString &version);
    void rxOnWhenIdleChanged(bool rxOnWhenIdle);
    void reachableChanged(bool reachable);
    void lqiChanged(uint lqi);
    void lastSeenChanged(const QDateTime &lastSeen);
    void neighborsChanged();
    void routesChanged();

private:
    QUuid m_networkUuid;
    QString m_ieeeAddress;
    quint16 m_networkAddress = 0;
    ZigbeeNodeType m_type = ZigbeeNodeTypeEndDevice;
    ZigbeeNodeState m_state = ZigbeeNodeStateUninitialized;
    QString m_manufacturer;
    QString m_model;
    QString m_version;
    bool m_rxOnWhenIdle = false;
    bool m_reachable = false;
    uint m_lqi = 0;
    QDateTime m_lastSeen;
    QList<ZigbeeNodeNeighbor*> m_neighbors;
    bool m_neighborsDirty = false;
    QList<ZigbeeNodeRoute*> m_routes;
    bool m_routesDirty = false;
};

class ZigbeeNodeNeighbor: public QObject
{
    Q_OBJECT
    Q_PROPERTY(quint16 networkAddress READ networkAddress CONSTANT)
    Q_PROPERTY(ZigbeeNode::ZigbeeNodeRelationship relationship READ relationship NOTIFY relationshipChanged)
    Q_PROPERTY(quint8 lqi READ lqi NOTIFY lqiChanged)
    Q_PROPERTY(quint8 depth READ depth NOTIFY depthChanged)
    Q_PROPERTY(bool permitJoining READ permitJoining NOTIFY permitJoiningChanged)

public:
    ZigbeeNodeNeighbor(quint16 networkAddress, QObject *parent);

    quint16 networkAddress() const;

    ZigbeeNode::ZigbeeNodeRelationship relationship() const;
    void setRelationship(ZigbeeNode::ZigbeeNodeRelationship relationship);

    quint8 lqi() const;
    void setLqi(quint8 lqi);

    quint8 depth() const;
    void setDepth(quint8 depth);

    bool permitJoining() const;
    void setPermitJoining(bool permitJoining);

signals:
    void relationshipChanged();
    void lqiChanged();
    void depthChanged();
    void permitJoiningChanged();

private:
    quint16 m_networkAddress;
    ZigbeeNode::ZigbeeNodeRelationship m_relationship;
    quint8 m_lqi = 0;
    quint8 m_depth = 0;
    bool m_permitJoining = false;
};

class ZigbeeNodeRoute: public QObject
{
    Q_OBJECT
    Q_PROPERTY(quint16 destinationAddress READ destinationAddress CONSTANT)
    Q_PROPERTY(quint16 nextHopAddress READ nextHopAddress NOTIFY nextHopAddressChanged)
    Q_PROPERTY(ZigbeeNode::ZigbeeNodeRouteStatus status READ status NOTIFY statusChanged)
    Q_PROPERTY(bool memoryConstrained READ memoryConstrained NOTIFY memoryConstrainedChanged)
    Q_PROPERTY(bool manyToOne READ manyToOne NOTIFY manyToOneChanged)

public:
    ZigbeeNodeRoute(quint16 destinationAddress, QObject *parent);

    quint16 destinationAddress() const;

    quint16 nextHopAddress() const;
    void setNextHopAddress(quint16 nextHopAddress);

    ZigbeeNode::ZigbeeNodeRouteStatus status() const;
    void setStatus(ZigbeeNode::ZigbeeNodeRouteStatus status);

    bool memoryConstrained() const;
    void setMemoryConstrained(bool memoryConstrained);

    bool manyToOne() const;
    void setManyToOne(bool manyToOne);

signals:
    void nextHopAddressChanged();
    void statusChanged();
    void memoryConstrainedChanged();
    void manyToOneChanged();

private:
    quint16 m_destinationAddress;
    quint16 m_nextHopAddress;
    ZigbeeNode::ZigbeeNodeRouteStatus m_status = ZigbeeNode::ZigbeeNodeRouteStatusInactive;
    bool m_memoryConstrained = false;
    bool m_manyToOne = false;
};

#endif // ZIGBEENODE_H

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
class ZigbeeNodeBinding;
class ZigbeeNodeEndpoint;

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
    Q_PROPERTY(QList<ZigbeeNodeBinding*> bindings READ bindings NOTIFY bindingsChanged)
    Q_PROPERTY(QList<ZigbeeNodeEndpoint*> endpoints READ endpoints NOTIFY endpointsChanged)

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

    enum ZigbeeNodeBindingType {
        ZigbeeNodeBindingTypeDevice,
        ZigbeeNodeBindingTypeGroup
    };
    Q_ENUM(ZigbeeNodeBindingType)

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

    QList<ZigbeeNodeBinding*> bindings() const;
    void addBinding(const QString &sourceAddress, quint8 sourceEndpointId, quint16 clusterId, quint16 groupAddress);
    void addBinding(const QString &sourceAddress, quint8 sourceEndpointId, quint16 clusterId, const QString &destinationAddress, quint8 destinationEndpointId);
    void commitBindings();

    QList<ZigbeeNodeEndpoint*> endpoints() const;
    Q_INVOKABLE ZigbeeNodeEndpoint *getEndpoint(quint8 endpointId) const;
    void addEndpoint(ZigbeeNodeEndpoint *endpoint);

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
    void bindingsChanged();
    void endpointsChanged();

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
    QList<ZigbeeNodeBinding*> m_bindings;
    bool m_bindingsDirty = false;
    QList<ZigbeeNodeEndpoint*> m_endpoints;
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

class ZigbeeNodeBinding: public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString sourceAddress READ sourceAddress CONSTANT)
    Q_PROPERTY(quint8 sourceEndpointId READ sourceEndpointId CONSTANT)
    Q_PROPERTY(quint16 clusterId READ clusterId CONSTANT)
    Q_PROPERTY(ZigbeeNode::ZigbeeNodeBindingType type READ type CONSTANT)
    Q_PROPERTY(quint16 groupAddress READ groupAddress CONSTANT)
    Q_PROPERTY(QString destinationAddress READ destinationAddress CONSTANT)
    Q_PROPERTY(quint8 destinationEndpointId READ destinationEndpointId CONSTANT)

public:
    ZigbeeNodeBinding(const QString &sourceAddress, quint8 sourceEndointId, quint16 clusterId, quint16 groupAddress, QObject *parent);
    ZigbeeNodeBinding(const QString &sourceAddress, quint8 sourceEndointId, quint16 clusterId, const QString &destinationAddress, quint8 destinationEndpoint, QObject *parent);

    QString sourceAddress() const;
    quint8 sourceEndpointId() const;
    quint16 clusterId() const;
    ZigbeeNode::ZigbeeNodeBindingType type() const;
    quint16 groupAddress() const;
    QString destinationAddress() const;
    quint8 destinationEndpointId() const;

private:
    QString m_sourceAddress;
    quint8 m_sourceEndpointId = 0;
    quint16 m_clusterId = 0;
    ZigbeeNode::ZigbeeNodeBindingType m_type = ZigbeeNode::ZigbeeNodeBindingTypeDevice;
    quint16 m_groupAddress = 0;
    QString m_destinationAddress;
    quint8 m_destinationEndpointId = 0;
};

class ZigbeeCluster: public QObject
{
    Q_OBJECT
    Q_PROPERTY(quint16 clusterId READ clusterId CONSTANT)
    Q_PROPERTY(ZigbeeClusterDirection direction READ direction CONSTANT)
public:
    enum ZigbeeClusterDirection {
        ZigbeeClusterDirectionServer,
        ZigbeeClusterDirectionClient
    };
    Q_ENUM(ZigbeeClusterDirection)

    enum ZigbeeClusterId {
        // Basics
        ZigbeeClusterIdUnknown                = 0xffff,
        ZigbeeClusterIdBasic                  = 0x0000,
        ZigbeeClusterIdPowerConfiguration     = 0x0001,
        ZigbeeClusterIdDeviceTemperature      = 0x0002,
        ZigbeeClusterIdIdentify               = 0x0003,
        ZigbeeClusterIdGroups                 = 0x0004,
        ZigbeeClusterIdScenes                 = 0x0005,
        ZigbeeClusterIdOnOff                  = 0x0006,
        ZigbeeClusterIdOnOffCOnfiguration     = 0x0007,
        ZigbeeClusterIdLevelControl           = 0x0008,
        ZigbeeClusterIdAlarms                 = 0x0009,
        ZigbeeClusterIdTime                   = 0x000A,
        ZigbeeClusterIdRssiLocation           = 0x000B,
        ZigbeeClusterIdAnalogInput            = 0x000C,
        ZigbeeClusterIdAnalogOutput           = 0x000D,
        ZigbeeClusterIdAnalogValue            = 0x000E,
        ZigbeeClusterIdBinaryInput            = 0x000F,
        ZigbeeClusterIdBinaryOutput           = 0x0010,
        ZigbeeClusterIdBinaryValue            = 0x0011,
        ZigbeeClusterIdMultistateInput        = 0x0012,
        ZigbeeClusterIdMultistateOutput       = 0x0013,
        ZigbeeClusterIdMultistateValue        = 0x0014,
        ZigbeeClusterIdCommissoning           = 0x0015,

        // Over the air uppgrade (OTA)
        ZigbeeClusterIdOtaUpgrade             = 0x0019,

        // Poll controll
        ZigbeeClusterIdPollControl            = 0x0020,


        // Closures
        ZigbeeClusterIdShadeConfiguration     = 0x0100,

        // Door Lock
        ZigbeeClusterIdDoorLock               = 0x0101,

        // Heating, Ventilation and Air-Conditioning (HVAC)
        ZigbeeClusterIdPumpConfigurationControl = 0x0200,
        ZigbeeClusterIdThermostat               = 0x0201,
        ZigbeeClusterIdFanControll              = 0x0202,
        ZigbeeClusterIdDehumiditationControl    = 0x0203,
        ZigbeeClusterIdThermostatUserControl    = 0x0204,

        // Lighting
        ZigbeeClusterIdColorControl           = 0x0300,
        ZigbeeClusterIdBallastConfiguration   = 0x0301,

        // Sensing
        ZigbeeClusterIdIlluminanceMeasurement         = 0x0400,
        ZigbeeClusterIdIlluminanceLevelSensing        = 0x0401,
        ZigbeeClusterIdTemperatureMeasurement         = 0x0402,
        ZigbeeClusterIdPressureMeasurement            = 0x0403,
        ZigbeeClusterIdFlowMeasurement                = 0x0404,
        ZigbeeClusterIdRelativeHumidityMeasurement    = 0x0405,
        ZigbeeClusterIdOccupancySensing               = 0x0406,

        // Security and Safty
        ZigbeeClusterIdIasZone = 0x0500,
        ZigbeeClusterIdIasAce  = 0x0501,
        ZigbeeClusterIdIasWd   = 0x0502,

        // Smart energy
        ZigbeeClusterIdPrice                        = 0x0700,
        ZigbeeClusterIdDemandResponseAndLoadControl = 0x0701,
        ZigbeeClusterIdMetering                     = 0x0702,
        ZigbeeClusterIdMessaging                    = 0x0703,
        ZigbeeClusterIdTunneling                    = 0x0704,
        ZigbeeClusterIdKeyEstablishment             = 0x0800,

        // ZLL
        ZigbeeClusterIdTouchlinkCommissioning = 0x1000,

        // NXP Appliances
        ZigbeeClusterIdApplianceControl           = 0x001B,
        ZigbeeClusterIdApplianceIdentification    = 0x0B00,
        ZigbeeClusterIdApplianceEventsAlerts      = 0x0B02,
        ZigbeeClusterIdApplianceStatistics        = 0x0B03,

        // Electrical Measurement
        ZigbeeClusterIdElectricalMeasurement      = 0x0B04,
        ZigbeeClusterIdDiagnostics                = 0x0B05,

        // Zigbee green power
        ZigbeeClusterIdGreenPower                 = 0x0021,

        // Manufacturer specific
        ZigbeeClusterIdManufacturerSpecificPhilips = 0xfc00,

    };
    Q_ENUM(ZigbeeClusterId)


    ZigbeeCluster(quint16 clusterId, ZigbeeClusterDirection direction, QObject *parent = nullptr);

    quint16 clusterId() const;
    ZigbeeClusterDirection direction() const;

    Q_INVOKABLE QString clusterName() const;

private:
    quint16 m_clusterId = 0;
    ZigbeeClusterDirection m_direction;
};

class ZigbeeNodeEndpoint: public QObject
{
    Q_OBJECT
    Q_PROPERTY(quint8 endpointId READ endpointId CONSTANT)
    Q_PROPERTY(QList<ZigbeeCluster*> inputClusters READ inputClusters NOTIFY inputClustersChanged)
    Q_PROPERTY(QList<ZigbeeCluster*> outputClusters READ outputClusters NOTIFY outputClustersChanged)
public:
    ZigbeeNodeEndpoint(quint8 endpointId, const QList<ZigbeeCluster*> &inputClusters = QList<ZigbeeCluster*>(), const QList<ZigbeeCluster*> &outputClusters = QList<ZigbeeCluster*>(), QObject *parent = nullptr);

    quint8 endpointId() const;
    QList<ZigbeeCluster*> inputClusters() const;
    Q_INVOKABLE ZigbeeCluster *getInputCluster(quint16 clusterId) const;
    void addInputCluster(ZigbeeCluster *cluster);

    QList<ZigbeeCluster*> outputClusters() const;
    Q_INVOKABLE ZigbeeCluster *getOutputCluster(quint16 clusterId) const;
    void addOutputCluster(ZigbeeCluster *cluster);

signals:
    void inputClustersChanged();
    void outputClustersChanged();

private:
    quint8 m_endpointId = 0;
    QList<ZigbeeCluster*> m_inputClusters;
    QList<ZigbeeCluster*> m_outputClusters;
};

#endif // ZIGBEENODE_H

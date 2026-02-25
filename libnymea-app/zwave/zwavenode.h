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

#ifndef ZWAVENODE_H
#define ZWAVENODE_H

#include <QObject>
#include <QUuid>
#include <QAbstractListModel>
#include <QSortFilterProxyModel>

class ZWaveNode : public QObject
{
    Q_OBJECT
    Q_PROPERTY(quint8 nodeId READ nodeId CONSTANT)
    Q_PROPERTY(QUuid networkUuid READ networkUuid CONSTANT)
    Q_PROPERTY(bool initialized READ initialized NOTIFY initializedChanged)
    Q_PROPERTY(bool reachable READ reachable NOTIFY reachableChanged)
    Q_PROPERTY(bool failed READ failed NOTIFY failedChanged)
    Q_PROPERTY(bool sleeping READ sleeping NOTIFY sleepingChanged)
    Q_PROPERTY(quint8 linkQuality READ linkQuality NOTIFY linkQualityChanged)
    Q_PROPERTY(quint8 securityMode READ securityMode NOTIFY securityModeChanged)
    Q_PROPERTY(ZWaveNodeType nodeType READ nodeType NOTIFY nodeTypeChanged)
    Q_PROPERTY(QString nodeTypeString READ nodeTypeString NOTIFY nodeTypeChanged)
    Q_PROPERTY(ZWaveNodeRole role READ role NOTIFY roleChanged)
    Q_PROPERTY(QString roleString READ roleString NOTIFY roleChanged)
    Q_PROPERTY(ZWaveDeviceType deviceType READ deviceType NOTIFY deviceTypeChanged)
    Q_PROPERTY(QString deviceTypeString READ deviceTypeString NOTIFY deviceTypeChanged)
    Q_PROPERTY(quint16 manufacturerId READ manufacturerId NOTIFY manufacturerIdChanged)
    Q_PROPERTY(QString manufacturerName READ manufacturerName NOTIFY manufacturerNameChanged)
    Q_PROPERTY(QString name READ name NOTIFY nameChanged)
    Q_PROPERTY(quint16 productId READ productId NOTIFY productIdChanged)
    Q_PROPERTY(QString productName READ productName NOTIFY productNameChanged)
    Q_PROPERTY(quint16 productType READ productType NOTIFY productTypeChanged)
    Q_PROPERTY(quint8 version READ version NOTIFY versionChanged)
    Q_PROPERTY(bool isZWavePlusDevice READ isZWavePlusDevice NOTIFY isZWavePlusDeviceChanged)
    Q_PROPERTY(bool isSecurityDevice READ isSecurityDevice NOTIFY isSecurityDeviceChanged)
    Q_PROPERTY(bool isBeamingDevice READ isBeamingDevice NOTIFY isBeamingDeviceChanged)

public:
    enum ZWaveNodeType {
        ZWaveNodeTypeUnknown = 0x00,
        ZWaveNodeTypeController = 0x01,
        ZWaveNodeTypeStaticController = 0x02,
        ZWaveNodeTypeSlave = 0x03,
        ZWaveNodeTypeRoutingSlave = 0x04,
    };
    Q_ENUM(ZWaveNodeType)

    enum ZWaveNodeRole {
        ZWaveNodeRoleUnknown = -0x01,
        ZWaveNodeRoleCentralController = 0x00,
        ZWaveNodeRoleSubController = 0x01,
        ZWaveNodeRolePortableController = 0x02,
        ZWaveNodeRolePortableReportingController = 0x03,
        ZWaveNodeRolePortableSlave = 0x04,
        ZWaveNodeRoleAlwaysOnSlabe = 0x05,
        ZWaveNodeRoleReportingSleepingSlave = 0x06,
        ZWaveNodeRoleListeningSleepingSlave = 0x07
    };
    Q_ENUM(ZWaveNodeRole)

    enum ZWaveDeviceType {
        ZWaveDeviceTypeUnknown = 0x0000,
        ZWaveDeviceTypeCentralController = 0x0100,
        ZWaveDeviceTypeDisplaySimple = 0x0200,
        ZWaveDeviceTypeDoorLockKeypad = 0x0300,
        ZWaveDeviceTypeFanSwitch = 0x0400,
        ZWaveDeviceTypeGateway = 0x0500,
        ZWaveDeviceTypeLightDimmerSwitch = 0x0600,
        ZWaveDeviceTypeOnOffPowerSwitch = 0x0700,
        ZWaveDeviceTypePowerStrip = 0x0800,
        ZWaveDeviceTypeRemoteControlAV = 0x0900,
        ZWaveDeviceTypeRemoteControlMultiPurpose = 0x0a00,
        ZWaveDeviceTypeRemoteControlSimple = 0x0b00,
        ZWaveDeviceTypeKeyFob = 0x0b01,
        ZWaveDeviceTypeSensorNotification = 0x0c00,
        ZWaveDeviceTypeSmokeAlarmSensor = 0x0c01,
        ZWaveDeviceTypeCOAlarmSensor = 0x0c02,
        ZWaveDeviceTypeCO2AlarmSensor = 0x0c03,
        ZWaveDeviceTypeHeatAlarmSensor = 0x0c04,
        ZWaveDeviceTypeWaterAlarmSensor = 0x0c05,
        ZWaveDeviceTypeAccessControlSensor = 0x0c06,
        ZWaveDeviceTypeHomeSecuritySensor = 0x0c07,
        ZWaveDeviceTypePowerManagementSensor = 0x0c08,
        ZWaveDeviceTypeSystemSensor = 0x0c09,
        ZWaveDeviceTypeEmergencyAlarmSensor = 0x0c0a,
        ZWaveDeviceTypeClockSensor = 0x0c0b,
        ZWaveDeviceTypeMultiDeviceAlarmSensor = 0x0cff,
        ZWaveDeviceTypeMultilevelSensor = 0x0d00,
        ZWaveDeviceTypeAirTemperatureSensor = 0x0d01,
        ZWaveDeviceTypeGeneralPurposeSensor = 0x0d02,
        ZWaveDeviceTypeLuminanceSensor = 0x0d03,
        ZWaveDeviceTypePowerSensor = 0x0d04,
        ZWaveDeviceTypeHumiditySensor = 0x0d05,
        ZWaveDeviceTypeVelocitySensor = 0x0d06,
        ZWaveDeviceTypeDirectionSensor = 0x0d07,
        ZWaveDeviceTypeAtmosphericPressureSensor = 0x0d08,
        ZWaveDeviceTypeBarometricPressureSensor = 0x0d09,
        ZWaveDeviceTypeSolarRadiationSensor = 0x0d0a,
        ZWaveDeviceTypeDewPointSensor = 0x0d0b,
        ZWaveDeviceTypeRainRateSensor = 0x0d0c,
        ZWaveDeviceTypeTideLevelSensor = 0x0d0d,
        ZWaveDeviceTypeWeightSensor = 0x0d0e,
        ZWaveDeviceTypeVoltageSensor = 0x0d0f,
        ZWaveDeviceTypeCurrentSensor = 0x0d10,
        ZWaveDeviceTypeCO2LevelSensor = 0x0d11,
        ZWaveDeviceTypeAirFlowSensor = 0x0d12,
        ZWaveDeviceTypeTankCapacitySensor = 0x0d13,
        ZWaveDeviceTypeDistanceSensor = 0x0d14,
        ZWaveDeviceTypeAnglePositionSensor = 0x0d15,
        ZWaveDeviceTypeRotationSensor = 0x0d16,
        ZWaveDeviceTypeWaterTemperatureSensor = 0x0d17,
        ZWaveDeviceTypeSoilTemperatureSensor = 0x0d18,
        ZWaveDeviceTypeSeismicIntensitySensor = 0x0d19,
        ZWaveDeviceTypeSeismicMagnitudeSensor = 0x0d1a,
        ZWaveDeviceTypeUltraVioletSensor = 0x0d1b,
        ZWaveDeviceTypeElectricalResistivitySensor = 0x0d1c,
        ZWaveDeviceTypeElectricalConductivitySensor = 0x0d1d,
        ZWaveDeviceTypeLoudnessSensor = 0x0d1e,
        ZWaveDeviceTypeMoistureSensor = 0x0d1f,
        ZWaveDeviceTypeFrequencySensor = 0x0d20,
        ZWaveDeviceTypeTimeSensor = 0x0d21,
        ZWaveDeviceTypeTargetTemperatureSensor = 0x0d22,
        ZWaveDeviceTypeMultiDeviceSensor = 0x0dff,
        ZWaveDeviceTypeSetTopBox = 0x0e00,
        ZWaveDeviceTypeSiren = 0x0f00,
        ZWaveDeviceTypeSubEnergyMeter = 0x1000,
        ZWaveDeviceTypeSubSystemController = 0x1100,
        ZWaveDeviceTypeThermostatHVAC = 0x1200,
        ZWaveDeviceTypeThermostatSetback = 0x1300,
        ZWaveDeviceTypeTV = 0x1400,
        ZWaveDeviceTypeValveOpenClose = 0x1500,
        ZWaveDeviceTypeWallController = 0x1600,
        ZWaveDeviceTypeWholeHomeMeterSimple = 0x1700,
        ZWaveDeviceTypeWindowCoveringNoPosEndpoint = 0x1800,
        ZWaveDeviceTypeWindowCoveringEndpointAware = 0x1900,
        ZWaveDeviceTypeWindowCoveringPositionEndpointAware = 0x1a00,
    };
    Q_ENUM(ZWaveDeviceType)

    explicit ZWaveNode(const QUuid &networkUuid, quint8 id, QObject *parent = nullptr);

    QUuid networkUuid() const;
    quint8 nodeId() const;

    bool initialized() const;
    void setInitialized(bool initialized);

    bool reachable() const;
    void setReachable(bool reachable);

    bool failed() const;
    void setFailed(bool failed);

    bool sleeping() const;
    void setSleeping(bool sleeping);

    quint8 linkQuality() const;
    void setLinkQuality(quint8 linkQuality);

    quint8 securityMode() const;
    void setSecurityMode(quint8 securityMode);

    ZWaveNodeType nodeType() const;
    void setNodeType(ZWaveNodeType nodeType);
    QString nodeTypeString() const;

    ZWaveNodeRole role() const;
    void setRole(ZWaveNodeRole role);
    QString roleString() const;

    ZWaveDeviceType deviceType() const;
    void setDeviceType(ZWaveDeviceType deviceType);
    QString deviceTypeString() const;

//    PlusDeviceType plusDeviceType() const;

    quint16 manufacturerId() const;
    void setManufacturerId(quint16 manufacturerId);

    QString manufacturerName() const;
    void setManufacturerName(const QString &manufacturerName);

    QString name() const;
    void setName(const QString &name);

    quint16 productId() const;
    void setProductId(quint16 productId);

    QString productName() const;
    void setProductName(const QString &productName);

    quint16 productType() const;
    void setProductType(quint16 productType);

    quint8 version() const;
    void setVersion(quint8 version);

    bool isZWavePlusDevice() const;
    void setIsZWavePlusDevice(bool isZWavePlusDevice);

    bool isSecurityDevice() const;
    void setIsSecurityDevice(bool isSecurityDevice);

    bool isBeamingDevice() const;
    void setIsBeamingDevice(bool isBeamingDevice);

signals:
    void initializedChanged();
    void reachableChanged();
    void failedChanged();
    void sleepingChanged();
    void linkQualityChanged();
    void securityModeChanged();
    void nodeTypeChanged();
    void deviceTypeChanged();
    void roleChanged();
    void plusDeviceTypeChanged();
    void manufacturerIdChanged();

    void manufacturerNameChanged();
    void nameChanged();
    void productIdChanged();
    void productNameChanged();
    void productTypeChanged();
    void versionChanged();
    void isZWavePlusDeviceChanged();
    void isSecurityDeviceChanged();
    void isBeamingDeviceChanged();

private:
    quint8 m_nodeId = 0;
    QUuid m_networkUuid;

    bool m_initialized = false;
    bool m_reachable = false;
    bool m_failed = false;
    bool m_sleeping = false;
    quint8 m_linkQuality = 0;
    quint8 m_securityMode = 0;

    ZWaveNodeType m_nodeType = ZWaveNodeTypeUnknown;
    ZWaveNodeRole m_role = ZWaveNodeRoleUnknown;
    ZWaveDeviceType m_deviceType = ZWaveDeviceTypeUnknown;
    quint16 m_manufacturerId = 0;
    QString m_manufacturerName;
    QString m_name;
    quint16 m_productId = 0;
    QString m_productName;
    quint16 m_productType = 0;
    quint8 m_version = 0;
    bool m_isZWavePlusDevice = false;
    bool m_isSecurityDevice = false;
    bool m_isBeamingDevice = false;
};

class ZWaveNodes: public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)
public:
    enum Roles {
        RoleId
    };
    Q_ENUM(Roles)

    ZWaveNodes(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

    void clear();
    void addNode(ZWaveNode *node);
    void removeNode(quint8 nodeId);

    Q_INVOKABLE ZWaveNode *get(int index) const;
    Q_INVOKABLE ZWaveNode *getNode(quint8 nodeId);

signals:
    void countChanged();

private:
    QList<ZWaveNode*> m_list;
};

class ZWaveNodesProxy: public QSortFilterProxyModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)
    Q_PROPERTY(ZWaveNodes* zwaveNodes READ zwaveNodes WRITE setZWaveNodes NOTIFY zwaveNodesChanged)
    Q_PROPERTY(bool showController READ showController WRITE setShowController NOTIFY showControllerChanged)
    Q_PROPERTY(bool showOnline READ showOnline WRITE setShowOnline NOTIFY showOnlineChanged)
    Q_PROPERTY(bool showOffline READ showOffline WRITE setShowOffline NOTIFY showOfflineChanged)

    Q_PROPERTY(bool newOnTop READ newOnTop WRITE setNewOnTop NOTIFY newOnTopChanged)

public:
    ZWaveNodesProxy(QObject *parent = nullptr);

    ZWaveNodes* zwaveNodes() const;
    void setZWaveNodes(ZWaveNodes* nodes);

    bool showController() const;
    void setShowController(bool showController);

    bool showOnline() const;
    void setShowOnline(bool showOnline);

    bool showOffline() const;
    void setShowOffline(bool showOffline);

    bool newOnTop() const;
    void setNewOnTop(bool newOnTop);

    Q_INVOKABLE ZWaveNode *get(int index) const;

signals:
    void countChanged();
    void zwaveNodesChanged();
    void showControllerChanged();
    void showOnlineChanged();
    void showOfflineChanged();
    void newOnTopChanged();

private:
    ZWaveNodes* m_nodes;
    bool m_showController = true;
    bool m_showOnline = true;
    bool m_showOffline = true;
    bool m_newOnTop = false;
};

#endif // ZWAVENODE_H

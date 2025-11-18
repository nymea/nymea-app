// SPDX-License-Identifier: GPL-3.0-or-later

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
* Copyright (C) 2013 - 2024, nymea GmbH
* Copyright (C) 2024 - 2025, chargebyte austria GmbH
*
* This file is part of nymea-app.
*
* nymea-app is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* nymea-app is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with nymea-app. If not, see <https://www.gnu.org/licenses/>.
*
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#ifndef ZONEINFO_H
#define ZONEINFO_H

#include <QObject>
#include <QUuid>
#include <QAbstractListModel>

#include "temperatureschedule.h"

class ZoneInfo : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QUuid id READ id CONSTANT)
    Q_PROPERTY(ZoneStatus zoneStatus READ zoneStatus NOTIFY zoneStatusChanged)
    Q_PROPERTY(QString name READ name NOTIFY nameChanged)
    Q_PROPERTY(double currentSetpoint READ currentSetpoint NOTIFY currentSetpointChanged)
    Q_PROPERTY(double standbySetpoint READ standbySetpoint NOTIFY standbySetpointChanged)
    Q_PROPERTY(double setpointOverride READ setpointOverride NOTIFY setpointOverrideChanged)
    Q_PROPERTY(SetpointOverrideMode setpointOverrideMode READ setpointOverrideMode NOTIFY setpointOverrideChanged)
    Q_PROPERTY(QDateTime setpointOverrideEnd READ setpointOverrideEnd NOTIFY setpointOverrideChanged)
    Q_PROPERTY(TemperatureWeekSchedule* weekSchedule READ weekSchedule CONSTANT)
    Q_PROPERTY(QList<QUuid> thermostats READ thermostats NOTIFY thermostatsChanged)
    Q_PROPERTY(QList<QUuid> windowSensors READ windowSensors NOTIFY windowSensorsChanged)
    Q_PROPERTY(QList<QUuid> indoorSensors READ indoorSensors NOTIFY indoorSensorsChanged)
    Q_PROPERTY(QList<QUuid> outdoorSensors READ outdoorSensors NOTIFY outdoorSensorsChanged)
    Q_PROPERTY(QList<QUuid> notifications READ notifications NOTIFY notificationsChanged)
    Q_PROPERTY(double temperature READ temperature NOTIFY temperatureChanged)
    Q_PROPERTY(double humidity READ humidity NOTIFY humidityChanged)
    Q_PROPERTY(uint voc READ voc NOTIFY vocChanged)
    Q_PROPERTY(double pm25 READ pm25 NOTIFY pm25Changed)
public:
    enum ZoneStatusFlag {
        ZoneStatusFlagNone = 0x00,
        ZoneStatusFlagTimeScheduleActive = 0x01,
        ZoneStatusFlagSetpointOverrideActive = 0x02,
        ZoneStatusFlagWindowOpen = 0x10,
        ZoneStatusFlagBadAir = 0x20,
        ZoneStatusFlagHighHumidity = 0x40
    };
    Q_ENUM(ZoneStatusFlag)
    Q_DECLARE_FLAGS(ZoneStatus, ZoneStatusFlag)
//    Q_DECLARE_OPERATORS_FOR_FLAGS(ZoneStatus)
    Q_FLAG(ZoneStatus)

    enum SetpointOverrideMode {
        SetpointOverrideModeNone = 0,
        SetpointOverrideModeTimed,
        SetpointOverrideModeUnlimited,
        SetpointOverrideModeEventual
    };
    Q_ENUM(SetpointOverrideMode)

    explicit ZoneInfo(const QUuid &id, QObject *parent = nullptr);

    QUuid id() const;

    QString name() const;
    void setName(const QString &name);

    ZoneStatus zoneStatus() const;
    void setZoneStatus(ZoneStatus zoneStatus);

    double currentSetpoint() const;
    void setCurrentSetpoint(double currentSetpoint);

    double standbySetpoint() const;
    void setStandbySetpoint(double standbySetpoint);

    double setpointOverride() const;
    SetpointOverrideMode setpointOverrideMode() const;
    QDateTime setpointOverrideEnd() const;
    void setSetpointOverride(double setpointOverride, SetpointOverrideMode mode, const QDateTime &end);

    TemperatureWeekSchedule *weekSchedule() const;

    QList<QUuid> thermostats() const;
    void setThermostats(const QList<QUuid> &thermostats);

    QList<QUuid> windowSensors() const;
    void setWindowSensors(const QList<QUuid> &windowSensors);

    QList<QUuid> indoorSensors() const;
    void setIndoorSensors(const QList<QUuid> &indoorSensors);

    QList<QUuid> outdoorSensors() const;
    void setOutdoorSensors(const QList<QUuid> &outdoorSensors);

    QList<QUuid> notifications() const;
    void setNotifications(const QList<QUuid> &notifications);

    double temperature() const;
    void setTemperature(double temperature);

    double humidity() const;
    void setHumidity(double humidity);

    uint voc() const;
    void setVoc(uint voc);

    double pm25() const;
    void setPm25(double pm25);

signals:
    void nameChanged();
    void zoneStatusChanged();
    void currentSetpointChanged();
    void standbySetpointChanged();
    void setpointOverrideChanged();
    void thermostatsChanged();
    void windowSensorsChanged();
    void indoorSensorsChanged();
    void outdoorSensorsChanged();
    void notificationsChanged();

    void temperatureChanged();
    void humidityChanged();
    void vocChanged();
    void pm25Changed();

private:
    QUuid m_id;
    ZoneStatus m_zoneStatus = ZoneStatusFlagNone;
    QString m_name;
    double m_currentSetpoint = 18;
    double m_standbySetpoint = 18;
    double m_setpointOverride = 18;
    SetpointOverrideMode m_setpointOverrideMode = SetpointOverrideModeNone;
    QDateTime m_setpointOverrideEnd;
    TemperatureWeekSchedule *m_weekSchedule = nullptr;
    QList<QUuid> m_thermostats;
    QList<QUuid> m_windowSensors;
    QList<QUuid> m_indoorSensors;
    QList<QUuid> m_outdoorSensors;
    QList<QUuid> m_notifications;
    double m_temperature = 0;
    double m_humidity = 0;
    uint m_voc = 0;
    double m_pm25 = 0;
};

class ZoneInfos: public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)
public:
    enum Roles {
        RoleId,
        RoleName,
    };
    ZoneInfos(QObject *parent = nullptr): QAbstractListModel(parent) {}

    int rowCount(const QModelIndex & = QModelIndex()) const override { return m_list.count(); }
    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

    void addZoneInfo(ZoneInfo *zoneInfo);
    void removeZoneInfo(const QUuid &zoneId);

    Q_INVOKABLE ZoneInfo* get(int index) const;
    Q_INVOKABLE ZoneInfo* getZoneInfo(const QUuid &zoneId) const;

signals:
    void countChanged();

private:
    QList<ZoneInfo*> m_list;
};

#endif // ZONEINFO_H

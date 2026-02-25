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

#include "zoneinfo.h"

ZoneInfo::ZoneInfo(const QUuid &id, QObject *parent)
    : QObject{parent},
      m_id(id)
{
    m_weekSchedule = new TemperatureWeekSchedule(this);
}

QUuid ZoneInfo::id() const
{
    return m_id;
}

QString ZoneInfo::name() const
{
    return m_name;
}

void ZoneInfo::setName(const QString &name)
{
    if (m_name != name) {
        m_name = name;
        emit nameChanged();
    }
}

ZoneInfo::ZoneStatus ZoneInfo::zoneStatus() const
{
    return m_zoneStatus;
}

void ZoneInfo::setZoneStatus(ZoneStatus zoneStatus)
{
    if (m_zoneStatus != zoneStatus) {
        m_zoneStatus = zoneStatus;
        emit zoneStatusChanged();
    }
}

double ZoneInfo::currentSetpoint() const
{
    return m_currentSetpoint;
}

void ZoneInfo::setCurrentSetpoint(double currentSetpoint)
{
    if (m_currentSetpoint != currentSetpoint) {
        m_currentSetpoint = currentSetpoint;
        emit currentSetpointChanged();
    }
}

double ZoneInfo::standbySetpoint() const
{
    return m_standbySetpoint;
}

void ZoneInfo::setStandbySetpoint(double standbySetpoint)
{
    if (m_standbySetpoint != standbySetpoint) {
        m_standbySetpoint = standbySetpoint;
        emit standbySetpointChanged();
    }
}

double ZoneInfo::setpointOverride() const
{
    return m_setpointOverride;
}

ZoneInfo::SetpointOverrideMode ZoneInfo::setpointOverrideMode() const
{
    return m_setpointOverrideMode;
}

QDateTime ZoneInfo::setpointOverrideEnd() const
{
    return m_setpointOverrideEnd;
}

void ZoneInfo::setSetpointOverride(double setpointOverride, SetpointOverrideMode mode, const QDateTime &end)
{
    if (m_setpointOverride != setpointOverride || m_setpointOverrideMode != mode || m_setpointOverrideEnd != end) {
        m_setpointOverride = setpointOverride;
        m_setpointOverrideMode = mode;
        m_setpointOverrideEnd = end;
        emit setpointOverrideChanged();
    }
}

TemperatureWeekSchedule *ZoneInfo::weekSchedule() const
{
    return m_weekSchedule;
}

QList<QUuid> ZoneInfo::thermostats() const
{
    return m_thermostats;
}

void ZoneInfo::setThermostats(const QList<QUuid> &thermostats)
{
    if (m_thermostats != thermostats) {
        m_thermostats = thermostats;
        emit thermostatsChanged();
    }
}

QList<QUuid> ZoneInfo::windowSensors() const
{
    return m_windowSensors;
}

void ZoneInfo::setWindowSensors(const QList<QUuid> &windowSensors)
{
    if (m_windowSensors != windowSensors) {
        m_windowSensors = windowSensors;
        emit windowSensorsChanged();
    }
}

QList<QUuid> ZoneInfo::indoorSensors() const
{
    return m_indoorSensors;
}

void ZoneInfo::setIndoorSensors(const QList<QUuid> &indoorSensors)
{
    if (m_indoorSensors != indoorSensors) {
        m_indoorSensors = indoorSensors;
        emit indoorSensorsChanged();
    }
}

QList<QUuid> ZoneInfo::outdoorSensors() const
{
    return m_outdoorSensors;
}

void ZoneInfo::setOutdoorSensors(const QList<QUuid> &outdoorSensors)
{
    if (m_outdoorSensors != outdoorSensors) {
        m_outdoorSensors = outdoorSensors;
        emit outdoorSensorsChanged();
    }
}

QList<QUuid> ZoneInfo::notifications() const
{
    return m_notifications;
}

void ZoneInfo::setNotifications(const QList<QUuid> &notifications)
{
    if (m_notifications != notifications) {
        m_notifications = notifications;
        emit notificationsChanged();
    }
}

double ZoneInfo::temperature() const
{
    return m_temperature;
}

void ZoneInfo::setTemperature(double temperature)
{
    if (m_temperature != temperature) {
        m_temperature = temperature;
        emit temperatureChanged();
    }
}

double ZoneInfo::humidity() const
{
    return m_humidity;
}

void ZoneInfo::setHumidity(double humidity)
{
    if (m_humidity != humidity) {
        m_humidity = humidity;
        emit humidityChanged();
    }
}

uint ZoneInfo::voc() const
{
    return m_voc;
}

void ZoneInfo::setVoc(uint voc)
{
    if (m_voc != voc) {
        m_voc = voc;
        emit vocChanged();
    }
}

double ZoneInfo::pm25() const
{
    return m_pm25;
}

void ZoneInfo::setPm25(double pm25)
{
    if (m_pm25 != pm25) {
        m_pm25 = pm25;
        emit pm25Changed();
    }
}

QVariant ZoneInfos::data(const QModelIndex &index, int role) const
{
    switch (role) {
    case RoleId:
        return m_list.at(index.row())->id();
    case RoleName:
        return m_list.at(index.row())->name();
    }
    return QVariant();
}

QHash<int, QByteArray> ZoneInfos::roleNames() const
{
    return {
        {RoleId, "id"},
        {RoleName, "name"}
    };
}

void ZoneInfos::addZoneInfo(ZoneInfo *zoneInfo)
{
    zoneInfo->setParent(this);
    connect(zoneInfo, &ZoneInfo::nameChanged, this, [=](){
        QModelIndex idx = index(static_cast<int>(m_list.indexOf(zoneInfo)));
        emit dataChanged(idx, idx, {RoleName});
    });
    beginInsertRows(QModelIndex(), static_cast<int>(m_list.count()), static_cast<int>(m_list.count()));
    m_list.append(zoneInfo);
    endInsertRows();
    emit countChanged();
}

void ZoneInfos::removeZoneInfo(const QUuid &zoneId)
{
    int idx = -1;
    for (int i = 0; i < m_list.count(); i++) {
        ZoneInfo *zone = m_list.at(i);
        if (zone->id() == zoneId) {
            idx = i;
            break;
        }
    }
    if (idx < 0) {
        return;
    }
    beginRemoveRows(QModelIndex(), idx, idx);
    m_list.takeAt(idx)->deleteLater();
    endRemoveRows();
    emit countChanged();
}

ZoneInfo *ZoneInfos::get(int index) const
{
    if (index < 0 || index >= m_list.count()) {
        return nullptr;
    }
    return m_list.at(index);
}

ZoneInfo *ZoneInfos::getZoneInfo(const QUuid &zoneId) const
{
    foreach (ZoneInfo *zone, m_list) {
        if (zone->id() == zoneId) {
            return zone;
        }
    }
    return nullptr;
}

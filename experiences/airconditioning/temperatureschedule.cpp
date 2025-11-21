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

#include "temperatureschedule.h"

#include <QDebug>

TemperatureSchedule::TemperatureSchedule(QObject *parent)
    : QObject{parent}
{
//    qWarning() << "++++ TempSchedule" << this;

}

TemperatureSchedule::~TemperatureSchedule()
{
//    qWarning() << "---- TempSchedule" << this;
}

QTime TemperatureSchedule::startTime() const
{
    return m_startTime;
}

void TemperatureSchedule::setStartTime(const QTime &startTime)
{
    if (m_startTime != startTime) {
        m_startTime = startTime;
        emit startTimeChanged();
    }
}

QTime TemperatureSchedule::endTime() const
{
    return m_endTime;
}

void TemperatureSchedule::setEndTime(const QTime &endTime)
{
    if (m_endTime != endTime) {
        m_endTime = endTime;
        emit endTimeChanged();
    }
}

double TemperatureSchedule::temperature() const
{
    return m_temperature;
}

void TemperatureSchedule::setTemperature(double temperature)
{
    if (m_temperature != temperature) {
        m_temperature = temperature;
        emit temperatureChanged();
    }
}

TemperatureSchedule *TemperatureSchedule::clone() const
{
    TemperatureSchedule *ret = new TemperatureSchedule();
    ret->setStartTime(m_startTime);
    ret->setEndTime(m_endTime);
    ret->setTemperature(m_temperature);
    return ret;
}

TemperatureDaySchedule::TemperatureDaySchedule(QObject *parent):
    QAbstractListModel(parent)
{
//    qWarning() << "++++ DaySchedule" << this;

}

TemperatureDaySchedule::~TemperatureDaySchedule()
{
//    qWarning() << "---- DaySchedule" << this;
}

QVariant TemperatureDaySchedule::data(const QModelIndex &index, int role) const
{
    switch (role) {
    case RoleStartTime:
        return m_list.at(index.row())->startTime();
    case RoleEndTime:
        return m_list.at(index.row())->endTime();
    case RoleTemperature:
        return m_list.at(index.row())->temperature();
    }
    return QVariant();
}

QHash<int, QByteArray> TemperatureDaySchedule::roleNames() const
{
    return {
        {RoleStartTime, "startTime"},
        {RoleEndTime, "endTime"},
        {RoleTemperature, "temperature"}
    };
}

void TemperatureDaySchedule::clear()
{
    beginResetModel();
    qDeleteAll(m_list);
    m_list.clear();
    endResetModel();
}

void TemperatureDaySchedule::addSchedule(TemperatureSchedule *schedule)
{
    schedule->setParent(this);
    beginInsertRows(QModelIndex(), static_cast<int>(m_list.count()), static_cast<int>(m_list.count()));
    m_list.append(schedule);
    endInsertRows();
    emit countChanged();
}

TemperatureSchedule *TemperatureDaySchedule::get(int index) const
{
    if (index < 0 || index >= m_list.count()) {
        return nullptr;
    }
    return m_list.at(index);
}

TemperatureDaySchedule *TemperatureDaySchedule::clone() const
{
    // Note: passes ownership to caller (no parent)!
    TemperatureDaySchedule *ret = new TemperatureDaySchedule();
    for (int i = 0; i < m_list.count(); i++) {
        ret->addSchedule(m_list.at(i)->clone());
    }
    return ret;
}

TemperatureSchedule *TemperatureDaySchedule::createSchedule(const QTime &startTime, const QTime &endTime, double temperature)
{
    if (startTime >= endTime) {
        qWarning() << "Starttime is greater endTime. Not creating schedule";
        return nullptr;
    }
    int idx = 0;
    for (int i = 0; i < m_list.count(); i++) {
        TemperatureSchedule *existing = m_list.at(i);
        if (startTime < existing->startTime() && endTime < existing->endTime()) {
            break;
        }
        if (startTime < existing->startTime() && endTime > existing->startTime()) {
            qWarning() << "Collision detected. Not creating schedule";
            return nullptr;
        }
        if (startTime > existing->startTime() && startTime < existing->endTime()) {
            qWarning() << "Collision detected. Not creating schedule";
            return nullptr;
        }
        idx = i + 1;

    }
    TemperatureSchedule *newSchedule = new TemperatureSchedule(this);
    newSchedule->setStartTime(startTime);
    newSchedule->setEndTime(endTime);
    newSchedule->setTemperature(temperature);

    beginInsertRows(QModelIndex(), idx, idx);
    m_list.insert(idx, newSchedule);
    endInsertRows();
    emit countChanged();
    return newSchedule;
}

void TemperatureDaySchedule::removeSchedule(TemperatureSchedule *schedule)
{
    for (int i = 0; i < m_list.count(); i++) {
        if (m_list.at(i) == schedule) {
            beginRemoveRows(QModelIndex(), i, i);
            m_list.takeAt(i)->deleteLater();
            endRemoveRows();
            emit countChanged();
        }
    }
}

TemperatureWeekSchedule::TemperatureWeekSchedule(QObject *parent):
    QAbstractListModel(parent)
{
//    qWarning() << "++++ WeekSchedule" << this;

    for (int i = 0; i < 7; i++) {
        m_list.append(new TemperatureDaySchedule(this));
    }
}

TemperatureWeekSchedule::~TemperatureWeekSchedule()
{
//    qWarning() << "---- WeekSchedule" << this;
}

TemperatureDaySchedule *TemperatureWeekSchedule::get(int index) const
{
    if (index < 0 || index >= m_list.count()) {
        return nullptr;
    }
    return m_list.at(index);
}

TemperatureWeekSchedule *TemperatureWeekSchedule::clone() const
{
    TemperatureWeekSchedule *weekSchedule = new TemperatureWeekSchedule();
    for (int day = 0; day < 7; day++) {
        TemperatureDaySchedule *daySchedule = get(day);
        for (int i = 0; i < daySchedule->rowCount(); i++) {
            weekSchedule->get(day)->addSchedule(daySchedule->get(i)->clone());
        }
    }
    return weekSchedule;
}


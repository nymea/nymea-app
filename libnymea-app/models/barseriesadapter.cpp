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

#include "barseriesadapter.h"

#include <QDebug>

BarSeriesAdapter::BarSeriesAdapter(QObject *parent) : QObject(parent)
{

}

LogsModel *BarSeriesAdapter::logsModel() const
{
    return m_logsModel;
}

void BarSeriesAdapter::setLogsModel(LogsModel *logsModel)
{
    if (m_logsModel != logsModel) {
        m_logsModel = logsModel;
        emit logsModelChanged();
        update();
        connect(logsModel, &LogsModel::logEntryAdded, this, &BarSeriesAdapter::logEntryAdded);
    }
}

QtCharts::QAbstractBarSeries *BarSeriesAdapter::barSeries() const
{
    return m_barSeries;
}

void BarSeriesAdapter::setBarSeries(QtCharts::QAbstractBarSeries *barSeries)
{
    if (m_barSeries != barSeries) {
        m_barSeries = barSeries;
        emit barSeriesChanged();
        update();
    }
}

BarSeriesAdapter::Interval BarSeriesAdapter::interval() const
{
    return m_interval;
}

void BarSeriesAdapter::setInterval(BarSeriesAdapter::Interval interval)
{
    if (m_interval != interval) {
        m_interval = interval;
        emit intervalChanged();
    }
}

void BarSeriesAdapter::update()
{
    if (!m_barSeries || !m_logsModel) {
        return;
    }
    m_set = new QtCharts::QBarSet(m_barSeries->name());
    m_barSeries->append(m_set);

    for (int i = 0; i < m_logsModel->rowCount(); i++) {
        LogEntry *entry = m_logsModel->get(i);
        qDebug() << "have entry" << entry->timestamp().toString();
    }
}

void BarSeriesAdapter::ensureSlots(const QDateTime &start, const QDateTime &end)
{
    if (!m_barSeries || !m_logsModel) {
        return;
    }

    QDateTime startTime = start;
    switch (m_interval) {
    case IntervalMinutes:
        startTime.setTime(QTime(startTime.time().hour(), startTime.time().minute()));
        break;
    case IntervalHours:
        startTime.setTime(QTime(startTime.time().hour(), 0));
        break;
    case IntervalDays:
        startTime.setTime(QTime(0, 0));
        break;
    }


    QDateTime endTime = end;
    if (!endTime.isValid()) {
        endTime = QDateTime::currentDateTime();
    }
    endTime.setTime(QTime(endTime.time().hour(), endTime.time().minute()));

    QDateTime oldestExistingSlot;
    if (m_timeslots.isEmpty()) {
        oldestExistingSlot = endTime;
    } else {
        oldestExistingSlot = m_timeslots.first().datetime;
    }

    if (startTime < oldestExistingSlot) {
        long duration = oldestExistingSlot.toMSecsSinceEpoch() - startTime.toMSecsSinceEpoch();
        long slotCount = duration / (m_interval * 1000);
        qDebug() << "Need" << slotCount << "new slots appended";

        for (int i = 0; i < slotCount; i++) {
            QDateTime slotTime = oldestExistingSlot.addSecs(-m_interval * (i + 1));
//            qDebug() << "Adding" << slotTime.toString();
            TimeSlot timeslot;
            timeslot.datetime = slotTime;
            m_set->insert(0, 0);
            m_timeslots.prepend(timeslot);
        }
    }

    QDateTime newestExistingSlot;
    if (m_timeslots.isEmpty()) {
        newestExistingSlot = startTime;
    } else {
        newestExistingSlot = m_timeslots.last().datetime;
    }

    if (endTime > newestExistingSlot) {
        long duration = endTime.toMSecsSinceEpoch() - newestExistingSlot.toMSecsSinceEpoch();
        long slotCount = duration / (m_interval * 1000);
//        qDebug() << "Need" << slotCount << "new slots prepended";

        for (int i = 0; i < slotCount; i++) {
            QDateTime slotTime = newestExistingSlot.addSecs(m_interval * (i + 1));
            TimeSlot timeslot;
            timeslot.datetime = slotTime;
            m_set->append(0);
            m_timeslots.append(timeslot);
        }
    }

    if (m_timeslots.isEmpty()) {
//        qDebug() << "Need to initialize list with 1 entry";
        TimeSlot timeslot;
        timeslot.datetime = startTime;
        m_set->append(0);
        m_timeslots.append(timeslot);
    }

    qDebug() << "Ensuring slots from" << start << "to" << end << "oldest" << oldestExistingSlot << "newest" << newestExistingSlot;

}

void BarSeriesAdapter::logEntryAdded(LogEntry *entry)
{
    qDebug() << "****"  << m_barSeries << m_logsModel;
    if (!m_barSeries || !m_logsModel) {
        return;
    }
    ensureSlots(QDateTime::fromMSecsSinceEpoch(qMin(m_logsModel->startTime().toMSecsSinceEpoch(), entry->timestamp().toMSecsSinceEpoch())), QDateTime::fromMSecsSinceEpoch(qMax(m_logsModel->endTime().toMSecsSinceEpoch(), entry->timestamp().toMSecsSinceEpoch())));

    QDateTime timestamp = entry->timestamp();

    QDateTime timeSlotStart = timestamp;
    switch (m_interval) {
    case IntervalMinutes:
        timeSlotStart.setTime(QTime(timestamp.time().hour(), timestamp.time().minute()));
        break;
    case IntervalHours:
        timeSlotStart.setTime(QTime(timestamp.time().hour(), 0));
        break;
    case IntervalDays:
        timeSlotStart.setTime(QTime(0, 0));
        break;
    }

//    qDebug() << "Item time:" << timeSlotStart;

    TimeSlot first = m_timeslots.first();
    TimeSlot last = m_timeslots.last();
    long slotIdx = (timeSlotStart.toMSecsSinceEpoch() - first.datetime.toMSecsSinceEpoch()) / (m_interval * 1000);
    qDebug() << "first" << first.datetime.toString();
    qDebug() << "last" << last.datetime.toString();
    qDebug() << "this" << timeSlotStart.toString();
    qDebug() << "idx" << slotIdx;


    m_timeslots[slotIdx].entries.append(entry);
    m_set->replace(slotIdx, m_timeslots[slotIdx].value());
//    qDebug() << "Adding entry" << entry->timestamp() << "timestlot" << timeSlotStart << "at" << slotIdx << "value" << m_timeslots[slotIdx].value();

//    if (!m_timeslots.contains(timeSlotStart)) {
//        TimeSlot timeslot;
//        timeslot.startTime = timeSlotStart;


//    }
//    TimeSlot timeslot = m_timeslots.value(timeSlotStart);
//    timeslot.entries.append(entry);
}

qreal BarSeriesAdapter::TimeSlot::value() const
{
    qreal value = 0;
    foreach (LogEntry *entry, entries) {
        value += entry->value().toDouble();
    }
    if (entries.count() > 1) {
       value /= entries.count();
    }
    return value;
}

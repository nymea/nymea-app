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

#ifndef BARSERIESADAPTER_H
#define BARSERIESADAPTER_H

#include "logsmodel.h"

#include <QObject>
#include <QBarSeries>
#include <QBarSet>

class BarSeriesAdapter : public QObject
{
    Q_OBJECT
    Q_PROPERTY(LogsModel* logsModel READ logsModel WRITE setLogsModel NOTIFY logsModelChanged)
    Q_PROPERTY(QtCharts::QAbstractBarSeries* barSeries READ barSeries WRITE setBarSeries NOTIFY barSeriesChanged)

    Q_PROPERTY(Interval interval READ interval WRITE setInterval NOTIFY intervalChanged)

public:
    enum Interval {
        IntervalMinutes = 60,
        IntervalHours =  60 * 60,
        IntervalDays = 24 * 60  * 60
    };
    Q_ENUM(Interval)

    explicit BarSeriesAdapter(QObject *parent = nullptr);

    LogsModel *logsModel() const;
    void setLogsModel(LogsModel *logsModel);

    QtCharts::QAbstractBarSeries *barSeries() const;
    void setBarSeries(QtCharts::QAbstractBarSeries *barSeries);

    Interval interval() const;
    void setInterval(Interval interval);

signals:
    void logsModelChanged();
    void barSeriesChanged();
    void intervalChanged();

private:
    void update();

    void ensureSlots(const QDateTime &start, const QDateTime &end);

private slots:
    void logEntryAdded(LogEntry *entry);

private:
    class TimeSlot {
    public:
        QDateTime datetime;
        QList<LogEntry*> entries;
        qreal value() const;
    };

    LogsModel *m_logsModel = nullptr;
    QtCharts::QAbstractBarSeries *m_barSeries = nullptr;
    QtCharts::QBarSet *m_set = nullptr;
    Interval m_interval = IntervalMinutes;

    QList<TimeSlot> m_timeslots;
};

#endif // BARSERIESADAPTER_H

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

#ifndef BOOLSERIESADAPTER_H
#define BOOLSERIESADAPTER_H

#include "logsmodel.h"

#include <QObject>
#include <QXYSeries>

class BoolSeriesAdapter : public QObject
{
    Q_OBJECT
    Q_PROPERTY(LogsModel* logsModel READ logsModel WRITE setLogsModel NOTIFY logsModelChanged)
    Q_PROPERTY(QtCharts::QXYSeries* xySeries READ xySeries WRITE setXySeries NOTIFY xySeriesChanged)

    Q_PROPERTY(bool inverted READ inverted WRITE setInverted NOTIFY invertedChanged)

public:
    explicit BoolSeriesAdapter(QObject *parent = nullptr);

    LogsModel* logsModel() const;
    void setLogsModel(LogsModel *logsModel);

    QtCharts::QXYSeries* xySeries() const;
    void setXySeries(QtCharts::QXYSeries *series);

    bool inverted() const;
    void setInverted(bool inverted);

signals:
    void xySeriesChanged();
    void logsModelChanged();
    void invertedChanged();

private slots:
    void logEntryAdded(LogEntry *entry);

private:
    qreal calculateSampleValue(int index);

    quint64 findIndex(qulonglong timestamp);

private:
    LogsModel* m_model = nullptr;
    QtCharts::QXYSeries* m_series = nullptr;
    bool m_inverted = false;

};

#endif // BOOLSERIESADAPTER_H

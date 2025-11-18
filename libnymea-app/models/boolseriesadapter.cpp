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

#include "boolseriesadapter.h"

BoolSeriesAdapter::BoolSeriesAdapter(QObject *parent)
    : QObject{parent}
{

}

LogsModel *BoolSeriesAdapter::logsModel() const
{
    return m_model;
}

void BoolSeriesAdapter::setLogsModel(LogsModel *logsModel)
{
    if (m_model != logsModel) {
        m_model = logsModel;
        emit logsModelChanged();
//        update();
        connect(logsModel, &LogsModel::logEntryAdded, this, &BoolSeriesAdapter::logEntryAdded);
    }

}

QtCharts::QXYSeries *BoolSeriesAdapter::xySeries() const
{
    return m_series;
}

void BoolSeriesAdapter::setXySeries(QtCharts::QXYSeries *series)
{
    if (m_series != series) {
        m_series = series;
        emit xySeriesChanged();

        m_series->clear();
        m_series->append(QDateTime::currentDateTime().addYears(1).toMSecsSinceEpoch(), 0);
        m_series->append(0, 0);
        qWarning() << "Initialized series" << m_series->count();
    }
}

bool BoolSeriesAdapter::inverted() const
{
    return m_inverted;
}

void BoolSeriesAdapter::setInverted(bool inverted)
{
    if (m_inverted != inverted) {
        m_inverted = inverted;
        emit invertedChanged();
    }
}

void BoolSeriesAdapter::logEntryAdded(LogEntry *entry)
{
    if (!m_series) {
        return;
    }

    int idx = findIndex(entry->timestamp().toMSecsSinceEpoch());
    qreal value = entry->value().toBool() != m_inverted ? 1 : 0;

    if (m_series->count() >= 2000) {
        qCWarning(dcLogEngine()) << "Thing logs too excessively. Discarding entry.";
        return;
    }

//    QDebug dbg = qWarning();
//    dbg << "List before insert:\n";
//    for (int i = 0; i < m_series->count(); i++) {
//        dbg << i << QDateTime::fromMSecsSinceEpoch(m_series->at(i).x()) << m_series->at(i).y() << "\n";
//    }

//    qWarning() << "Inserting" << entry->timestamp() << entry->value() << "real value:" << value << "at" << idx << "total:" << m_series->count();
    // We're keeping a fake entry at the beginning (timestamp 0) with a static value of 0
    // and on in the beginning (+1 year from now) for which we'll update the value according to
    // the newest real entry to continue painting the last value.

    // Update the future value if this is the new newest real entry
    if (idx == 1) {
        m_series->replace(0, QDateTime::currentDateTime().addYears(1).toMSecsSinceEpoch(), value);
    }
    // If the next older entry is different than this, first insert the other value right before this one
    if (qFuzzyIsNull(m_series->at(idx).y()) != qFuzzyIsNull(value)) {
        m_series->insert(idx, QPointF(entry->timestamp().toMSecsSinceEpoch() - 1, !value));
    }

    m_series->insert(idx, QPointF(entry->timestamp().toMSecsSinceEpoch(), value));

    // If the next newer entry is differnt than this, also insert this value right before the next one
    if (qFuzzyIsNull(m_series->at(idx-1).y()) != qFuzzyIsNull(value)) {
        m_series->insert(idx, QPointF(m_series->at(idx-1).x() - 1, value));
    }

//    qWarning() << "***** series count" << m_series->count();
//    dbg << "List after insert:\n";
//    for (int i = 0; i < m_series->count(); i++) {
//        dbg << i << QDateTime::fromMSecsSinceEpoch(m_series->at(i).x()) << m_series->at(i).y() << "\n";
//    }
}

quint64 BoolSeriesAdapter::findIndex(qulonglong timestamp)
{
    if (m_series->count() == 2) {
        return 1;
    }

    // In 99.9% of the cases we'll be prepending (adding live entries) or appending (fetching history)
    if (timestamp < m_series->at(m_series->count() - 2).x()) {
        return m_series->count() - 1;
    }
    if (timestamp > m_series->at(1).x()) {
        return 1;
    }

    // If for any reason a entry in the middle is added (can't think of one but hey), a binary search will probably do.
    int idx = m_series->count() / 2;
    int range = idx;
    int i = 0;
    while (true) {
//        qWarning() << "CNT:" << m_series->count()
//                   << "first:" << QDateTime::fromMSecsSinceEpoch(m_series->at(1).x())
//                   << "last:" << QDateTime::fromMSecsSinceEpoch(m_series->at(m_series->count()- 2).x())
//                   << "current:" << idx << QDateTime::fromMSecsSinceEpoch(m_series->at(idx).x())
//                   << "search:" << QDateTime::fromMSecsSinceEpoch(timestamp);
        if (timestamp >= m_series->at(idx).x() && timestamp < m_series->at(idx-1).x()) {
            return idx;
        }
        if (timestamp <= m_series->at(idx).x() && timestamp > m_series->at(idx+1).x()) {
            return idx+1;
        }
        range = qMax(1, range / 2);
        if (timestamp > m_series->at(idx).x()) {
            idx = idx - range;
        } else {
            idx = idx + range;
        }

        if (i++ > 2000) {
            break;
        }
    }
    return 1;
}

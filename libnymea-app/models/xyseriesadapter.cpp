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

#include "xyseriesadapter.h"

#include <QDebug>

#include <QLoggingCategory>
Q_DECLARE_LOGGING_CATEGORY(dcLogEngine)

XYSeriesAdapter::XYSeriesAdapter(QObject *parent) : QObject(parent)
{

}

LogsModel *XYSeriesAdapter::logsModel() const
{
    return m_model;
}

void XYSeriesAdapter::setLogsModel(LogsModel *logsModel)
{
    if (m_model != logsModel) {
        m_model = logsModel;
        emit logsModelChanged();
//        update();
        connect(logsModel, &LogsModel::logEntryAdded, this, &XYSeriesAdapter::logEntryAdded);
    }
}

QXYSeries *XYSeriesAdapter::xySeries() const
{
    return m_series;
}

void XYSeriesAdapter::setXySeries(QXYSeries *series)
{
    if (m_series != series) {
        m_series = series;
        emit xySeriesChanged();

        ensureSamples(QDateTime::currentDateTime(), QDateTime::currentDateTime().addMSecs(2 * 60000));
    }
}

QXYSeries *XYSeriesAdapter::baseSeries() const
{
    return m_baseSeries;
}

void XYSeriesAdapter::setBaseSeries(QXYSeries *series)
{
    if (m_baseSeries != series) {
        m_baseSeries = series;
        emit baseSeriesChanged();

        connect(m_baseSeries, &QXYSeries::pointAdded, this, [=](int index){
            if (m_series->count() > index) {
                qreal value = calculateSampleValue(index);
                m_series->replace(index, m_series->at(index).x(), value);
                if (value < m_minValue) {
                    m_minValue = value;
//                    qDebug() << "New min:" << m_minValue;
                    emit minValueChanged();
                }
                if (value > m_maxValue) {
                    m_maxValue = value;
//                    qDebug() << "New max:" << m_maxValue;
                    emit maxValueChanged();
                }
            }
        });
        connect(m_baseSeries, &QXYSeries::pointReplaced, this, [=](int index){
            if (m_series->count() > index) {
                qreal value = calculateSampleValue(index);
                m_series->replace(index, m_series->at(index).x(), value);
                if (value < m_minValue) {
                    m_minValue = value;
//                    qDebug() << "New min:" << m_minValue;
                    emit minValueChanged();
                }
                if (value > m_maxValue) {
                    m_maxValue = value;
//                    qDebug() << "New max:" << m_maxValue;
                    emit maxValueChanged();
                }
            }
        });
    }
}

XYSeriesAdapter::SampleRate XYSeriesAdapter::sampleRate() const
{
    return m_sampleRate;
}

void XYSeriesAdapter::setSampleRate(XYSeriesAdapter::SampleRate sampleRate)
{
    if (m_sampleRate != sampleRate) {
        m_sampleRate = sampleRate;
        emit sampleRateChanged();
    }
}

bool XYSeriesAdapter::smooth() const
{
    return m_smooth;
}

void XYSeriesAdapter::setSmooth(bool smooth)
{
    if (m_smooth != smooth) {
        m_smooth = smooth;
        emit smoothChanged();
    }
}

bool XYSeriesAdapter::inverted() const
{
    return m_inverted;
}

void XYSeriesAdapter::setInverted(bool inverted)
{
    if (m_inverted != inverted) {
        m_inverted = inverted;
        emit invertedChanged();
    }
}

qreal XYSeriesAdapter::maxValue() const
{
    return m_maxValue;
}

qreal XYSeriesAdapter::minValue() const
{
    return m_minValue;
}

void XYSeriesAdapter::ensureSamples(const QDateTime &from, const QDateTime &to)
{
    if (!m_series) {
        return;
    }

    if (m_samples.isEmpty()) {
        Sample *sample = new Sample();
        sample->timestamp = from.addSecs(m_sampleRate / 2);
//        qWarning() << "Added first" << from << sample->timestamp;
        m_newestSample = sample->timestamp;
        m_oldestSample = m_newestSample;
        m_samples.append(sample);
        m_series->insert(0, QPointF(sample->timestamp.toMSecsSinceEpoch(), 0));
    }

    while (to > m_newestSample) {
        Sample *sample = new Sample();
        sample->timestamp = m_newestSample.addSecs(m_sampleRate);
        Sample *oldNewest = m_samples.first();
        if (oldNewest->entries.count() > 0) {
            sample->startingPoint = oldNewest->entries.last();
        } else if (oldNewest->startingPoint != nullptr) {
            sample->startingPoint = oldNewest->startingPoint;
        }
        m_newestSample = sample->timestamp;
        m_samples.prepend(sample);
        m_series->insert(0, QPointF(sample->timestamp.toMSecsSinceEpoch(), m_series->at(0).y()));
    }

    while (from < m_oldestSample.addSecs(-m_sampleRate)) {
//        qWarning() << "Added one before" << from << m_oldestSample.addMSecs(-m_sampleRate) << m_oldestSample;
        Sample *sample = new Sample();
        sample->timestamp = m_oldestSample.addSecs(-m_sampleRate);
        m_oldestSample = sample->timestamp;
        m_samples.append(sample);
        m_series->append(sample->timestamp.toMSecsSinceEpoch(), 0);
    }
//    qWarning() << "Ensuring samples:" << from.toString("yyyy-MM-dd hh:mm:ss") << to.toString("yyyy-MM-dd hh:mm:ss") << "Oldest:" << m_oldestSample.toString("yyyy-MM-dd hh:mm:ss") << "Newest:" << m_newestSample.toString("yyyy-MM-dd hh:mm:ss") ;
}

void XYSeriesAdapter::logEntryAdded(LogEntry *entry)
{
    if (!m_series) {
        return;
    }

    ensureSamples(entry->timestamp(), entry->timestamp());

    int idx = entry->timestamp().secsTo(m_newestSample) / m_sampleRate;
    if (idx > m_samples.count()) {
        qCWarning(dcLogEngine) << objectName() << "Overflowing integer size for XYSeriesAdapter!";
        return;
    }
//    qWarning() << objectName() << "Inserting sample at:" << idx << entry->timestamp().toString("yyyy-MM-dd hh:mm:ss");
    Sample *sample = m_samples.at(idx);
    LogEntry *oldLast = nullptr;
    // In theory we'd need to insert sorted, but only the last one actually matters for subsequent samples
    // For the current sample we're calculating the median anyways, so just append/prepend t be a bit faster
    if (sample->entries.count() > 0 && sample->entries.last()->timestamp() < entry->timestamp()) {
        oldLast = sample->entries.last();
        sample->entries.append(entry);
    } else {
        sample->entries.prepend(entry);
    }
    LogEntry *newLast = sample->entries.last();

    qreal value = calculateSampleValue(idx);
    m_series->replace(idx, sample->timestamp.toMSecsSinceEpoch(), value);
//    qWarning() << "sample value updated" << idx << sample->timestamp.toString("yyyy-MM-dd hh:mm:ss") << value;

    if (value < m_minValue) {
        m_minValue = value;
//        qDebug() << "New min:" << m_minValue;
        emit minValueChanged();
    }
    if (value > m_maxValue) {
        m_maxValue = value;
//        qDebug() << "New max:" << m_maxValue;
        emit maxValueChanged();
    }

    // check if we need to update more samples
    for (int i = idx - 1; i >= 0; i--) {
        Sample *nextSample = m_samples.at(i);
        if (nextSample->startingPoint == oldLast) {
            nextSample->startingPoint = newLast;
            qreal value = calculateSampleValue(i);
//            qWarning() << "Updating" << i << value;
            m_series->replace(i, nextSample->timestamp.toMSecsSinceEpoch(), value);

        } else {
            break;
        }
    }
}

qreal XYSeriesAdapter::calculateSampleValue(int index)
{
    Sample *sample = m_samples.at(index);
    qreal value = 0;
    int count = 0;
    if (sample->startingPoint) {
        value = sample->startingPoint->value().toDouble();
        count++;
    }

    foreach (LogEntry *entry, sample->entries) {
        value += entry->value().toDouble();
        count++;
    }

    if (count > 1) {
        value /= count;
    }

    if (m_baseSeries && m_baseSeries->count() > index) {
        value += m_baseSeries->at(index).y();
    }

    if (m_inverted) {
        value *= -1;
    }

    return value;
}

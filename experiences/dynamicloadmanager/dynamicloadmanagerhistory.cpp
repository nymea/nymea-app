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

#include "dynamicloadmanagerhistory.h"

#include <QMetaEnum>
#include <algorithm>

namespace {
QDateTime parseTimestamp(const QVariant &value)
{
    // Backend serializes the sample timestamp either as an ISO string or as epoch milliseconds.
    if (value.typeId() == QMetaType::QString)
        return QDateTime::fromString(value.toString(), Qt::ISODateWithMs);
    if (value.typeId() == QMetaType::Double || value.typeId() == QMetaType::LongLong || value.typeId() == QMetaType::ULongLong)
        return QDateTime::fromMSecsSinceEpoch(value.toLongLong());
    return value.toDateTime();
}

void fillPhase(double target[3], const QVariantMap &map)
{
    target[0] = map.value("l1").toDouble();
    target[1] = map.value("l2").toDouble();
    target[2] = map.value("l3").toDouble();
}
}

DynamicLoadManagerHistory::DynamicLoadManagerHistory(QObject *parent)
    : QAbstractListModel(parent)
{
    m_refreshTimer.setSingleShot(true);
    m_refreshTimer.setInterval(0);
    connect(&m_refreshTimer, &QTimer::timeout, this, &DynamicLoadManagerHistory::refresh);
}

int DynamicLoadManagerHistory::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return m_samples.size();
}

QVariant DynamicLoadManagerHistory::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() >= m_samples.size())
        return QVariant();

    const Sample &s = m_samples.at(index.row());
    switch (role) {
    case TimestampRole: return s.timestamp;
    case NodeTypeRole: return s.nodeType;
    case SampleRateRole: return s.sampleRate;
    case MeasuredLoadL1Role: return s.measuredLoad[0];
    case MeasuredLoadL2Role: return s.measuredLoad[1];
    case MeasuredLoadL3Role: return s.measuredLoad[2];
    case AllocationL1Role: return s.allocation[0];
    case AllocationL2Role: return s.allocation[1];
    case AllocationL3Role: return s.allocation[2];
    case EffectiveLimitL1Role: return s.effectiveLimit[0];
    case EffectiveLimitL2Role: return s.effectiveLimit[1];
    case EffectiveLimitL3Role: return s.effectiveLimit[2];
    case ReserveL1Role: return s.reserve[0];
    case ReserveL2Role: return s.reserve[1];
    case ReserveL3Role: return s.reserve[2];
    case SumOfChildrenL1Role: return s.sumOfChildren[0];
    case SumOfChildrenL2Role: return s.sumOfChildren[1];
    case SumOfChildrenL3Role: return s.sumOfChildren[2];
    case FaultedRole: return s.faulted;
    case InputFreshRole: return s.inputFresh;
    }
    return QVariant();
}

QHash<int, QByteArray> DynamicLoadManagerHistory::roleNames() const
{
    return {
        {TimestampRole, "timestamp"},
        {NodeTypeRole, "nodeType"},
        {SampleRateRole, "sampleRate"},
        {MeasuredLoadL1Role, "measuredLoadL1"},
        {MeasuredLoadL2Role, "measuredLoadL2"},
        {MeasuredLoadL3Role, "measuredLoadL3"},
        {AllocationL1Role, "allocationL1"},
        {AllocationL2Role, "allocationL2"},
        {AllocationL3Role, "allocationL3"},
        {EffectiveLimitL1Role, "effectiveLimitL1"},
        {EffectiveLimitL2Role, "effectiveLimitL2"},
        {EffectiveLimitL3Role, "effectiveLimitL3"},
        {ReserveL1Role, "reserveL1"},
        {ReserveL2Role, "reserveL2"},
        {ReserveL3Role, "reserveL3"},
        {SumOfChildrenL1Role, "sumOfChildrenL1"},
        {SumOfChildrenL2Role, "sumOfChildrenL2"},
        {SumOfChildrenL3Role, "sumOfChildrenL3"},
        {FaultedRole, "faulted"},
        {InputFreshRole, "inputFresh"},
    };
}

DynamicLoadManagerManager *DynamicLoadManagerHistory::manager() const
{
    return m_manager;
}

void DynamicLoadManagerHistory::setManager(DynamicLoadManagerManager *manager)
{
    if (m_manager == manager)
        return;

    if (m_manager)
        disconnect(m_manager, nullptr, this, nullptr);

    m_manager = manager;
    connectManager();
    emit managerChanged();
    scheduleRefresh();
}

QString DynamicLoadManagerHistory::nodeId() const
{
    return m_nodeId;
}

void DynamicLoadManagerHistory::setNodeId(const QString &nodeId)
{
    if (m_nodeId == nodeId)
        return;
    m_nodeId = nodeId;
    emit nodeIdChanged();
    scheduleRefresh();
}

QDateTime DynamicLoadManagerHistory::from() const
{
    return m_from;
}

void DynamicLoadManagerHistory::setFrom(const QDateTime &from)
{
    if (m_from == from)
        return;
    m_from = from;
    emit fromChanged();
    scheduleRefresh();
}

QDateTime DynamicLoadManagerHistory::to() const
{
    return m_to;
}

void DynamicLoadManagerHistory::setTo(const QDateTime &to)
{
    if (m_to == to)
        return;
    m_to = to;
    emit toChanged();
    scheduleRefresh();
}

DynamicLoadManagerHistory::SampleRate DynamicLoadManagerHistory::sampleRate() const
{
    return m_sampleRate;
}

void DynamicLoadManagerHistory::setSampleRate(SampleRate sampleRate)
{
    if (m_sampleRate == sampleRate)
        return;
    m_sampleRate = sampleRate;
    emit sampleRateChanged();
    scheduleRefresh();
}

bool DynamicLoadManagerHistory::includeCurrent() const
{
    return m_includeCurrent;
}

void DynamicLoadManagerHistory::setIncludeCurrent(bool includeCurrent)
{
    if (m_includeCurrent == includeCurrent)
        return;
    m_includeCurrent = includeCurrent;
    emit includeCurrentChanged();
    scheduleRefresh();
}

bool DynamicLoadManagerHistory::live() const
{
    return m_live;
}

void DynamicLoadManagerHistory::setLive(bool live)
{
    if (m_live == live)
        return;
    m_live = live;
    emit liveChanged();
}

bool DynamicLoadManagerHistory::busy() const
{
    return m_busy;
}

double DynamicLoadManagerHistory::minValue() const
{
    return m_minValue;
}

double DynamicLoadManagerHistory::maxValue() const
{
    return m_maxValue;
}

QVariantMap DynamicLoadManagerHistory::get(int index) const
{
    QVariantMap map;
    if (index < 0 || index >= m_samples.size())
        return map;
    const QHash<int, QByteArray> roles = roleNames();
    for (auto it = roles.constBegin(); it != roles.constEnd(); ++it)
        map.insert(QString::fromUtf8(it.value()), data(this->index(index), it.key()));
    return map;
}

void DynamicLoadManagerHistory::classBegin()
{
}

void DynamicLoadManagerHistory::componentComplete()
{
    m_componentComplete = true;
    refresh();
}

void DynamicLoadManagerHistory::scheduleRefresh()
{
    if (!m_componentComplete)
        return;
    m_refreshTimer.start();
}

void DynamicLoadManagerHistory::connectManager()
{
    if (!m_manager)
        return;
    connect(m_manager, &DynamicLoadManagerManager::nodeHistoryEntryAdded, this, &DynamicLoadManagerHistory::nodeHistoryEntryAdded);
    connect(m_manager, &DynamicLoadManagerManager::destroyed, this, [this] { m_manager = nullptr; });
}

void DynamicLoadManagerHistory::refresh()
{
    if (!m_manager || !m_manager->engine() || m_nodeId.isEmpty())
        return;

    QVariantMap params;
    params.insert("nodeId", m_nodeId);
    if (m_from.isValid())
        params.insert("from", m_from.toUTC().toString(Qt::ISODateWithMs));
    if (m_to.isValid())
        params.insert("to", m_to.toUTC().toString(Qt::ISODateWithMs));
    QMetaEnum sampleRateEnum = QMetaEnum::fromType<SampleRate>();
    params.insert("sampleRate", sampleRateEnum.valueToKey(m_sampleRate));
    params.insert("includeCurrent", m_includeCurrent);

    m_manager->engine()->jsonRpcClient()->sendCommand("DynamicLoadManager.GetNodeHistory", params, this, "historyReply");

    m_busy = true;
    emit busyChanged();
}

void DynamicLoadManagerHistory::historyReply(int commandId, const QVariantMap &params)
{
    Q_UNUSED(commandId)
    m_busy = false;
    emit busyChanged();

    QVector<Sample> samples;
    const QVariantList entries = params.value("nodeHistoryEntries").toList();
    samples.reserve(entries.size());
    for (const QVariant &entry : entries)
        samples.append(parseSample(entry.toMap()));

    std::sort(samples.begin(), samples.end(), [](const Sample &a, const Sample &b) {
        return a.timestamp < b.timestamp;
    });

    beginResetModel();
    m_samples = samples;
    endResetModel();
    recomputeRange();
    emit countChanged();
}

void DynamicLoadManagerHistory::nodeHistoryEntryAdded(const QVariantMap &entry)
{
    // Live additions are emitted at 1 minute resolution only.
    if (!m_live || m_sampleRate != SampleRate1Min)
        return;
    if (entry.value("nodeId").toString() != m_nodeId)
        return;

    Sample sample = parseSample(entry);
    if (m_to.isValid() && sample.timestamp > m_to)
        return;

    int row = m_samples.size();
    while (row > 0 && m_samples.at(row - 1).timestamp > sample.timestamp)
        --row;

    beginInsertRows(QModelIndex(), row, row);
    m_samples.insert(row, sample);
    endInsertRows();
    recomputeRange();
    emit countChanged();
}

DynamicLoadManagerHistory::Sample DynamicLoadManagerHistory::parseSample(const QVariantMap &map)
{
    Sample s;
    s.timestamp = parseTimestamp(map.value("timestamp"));
    s.nodeType = map.value("nodeType").toString();
    s.sampleRate = map.value("sampleRate").toInt();
    fillPhase(s.measuredLoad, map.value("measuredLoad").toMap());
    fillPhase(s.allocation, map.value("allocation").toMap());
    fillPhase(s.effectiveLimit, map.value("effectiveLimit").toMap());
    fillPhase(s.reserve, map.value("reserve").toMap());
    fillPhase(s.sumOfChildren, map.value("sumOfChildren").toMap());
    s.faulted = map.value("faulted").toBool();
    s.inputFresh = map.value("inputFresh", true).toBool();
    return s;
}

void DynamicLoadManagerHistory::recomputeRange()
{
    double minValue = 0;
    double maxValue = 0;
    bool first = true;
    for (const Sample &s : m_samples) {
        const double values[] = {
            s.measuredLoad[0], s.measuredLoad[1], s.measuredLoad[2],
            s.allocation[0], s.allocation[1], s.allocation[2],
            s.effectiveLimit[0], s.effectiveLimit[1], s.effectiveLimit[2],
        };
        for (double v : values) {
            if (first) {
                minValue = maxValue = v;
                first = false;
            } else {
                minValue = qMin(minValue, v);
                maxValue = qMax(maxValue, v);
            }
        }
    }
    if (!qFuzzyCompare(m_minValue, minValue) || !qFuzzyCompare(m_maxValue, maxValue)) {
        m_minValue = minValue;
        m_maxValue = maxValue;
        emit rangeChanged();
    }
}

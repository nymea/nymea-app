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

#include "dynamicloadmanagerevents.h"

#include <algorithm>

namespace {
QDateTime parseTimestamp(const QVariant &value)
{
    if (value.typeId() == QMetaType::QString)
        return QDateTime::fromString(value.toString(), Qt::ISODateWithMs);
    if (value.typeId() == QMetaType::Double || value.typeId() == QMetaType::LongLong || value.typeId() == QMetaType::ULongLong)
        return QDateTime::fromMSecsSinceEpoch(value.toLongLong());
    return value.toDateTime();
}
}

DynamicLoadManagerEvents::DynamicLoadManagerEvents(QObject *parent)
    : QAbstractListModel(parent)
{
    m_refreshTimer.setSingleShot(true);
    m_refreshTimer.setInterval(0);
    connect(&m_refreshTimer, &QTimer::timeout, this, &DynamicLoadManagerEvents::refresh);
}

int DynamicLoadManagerEvents::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return m_events.size();
}

QVariant DynamicLoadManagerEvents::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() >= m_events.size())
        return QVariant();

    const Event &e = m_events.at(index.row());
    switch (role) {
    case TimestampRole: return e.timestamp;
    case NodeIdRole: return e.nodeId;
    case EventTypeRole: return e.eventType;
    case SeverityRole: return e.severity;
    case ReasonRole: return e.reason;
    case DetailsRole: return e.details;
    }
    return QVariant();
}

QHash<int, QByteArray> DynamicLoadManagerEvents::roleNames() const
{
    return {
        {TimestampRole, "timestamp"},
        {NodeIdRole, "nodeId"},
        {EventTypeRole, "eventType"},
        {SeverityRole, "severity"},
        {ReasonRole, "reason"},
        {DetailsRole, "details"},
    };
}

DynamicLoadManagerManager *DynamicLoadManagerEvents::manager() const
{
    return m_manager;
}

void DynamicLoadManagerEvents::setManager(DynamicLoadManagerManager *manager)
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

QString DynamicLoadManagerEvents::nodeId() const
{
    return m_nodeId;
}

void DynamicLoadManagerEvents::setNodeId(const QString &nodeId)
{
    if (m_nodeId == nodeId)
        return;
    m_nodeId = nodeId;
    emit nodeIdChanged();
    scheduleRefresh();
}

QDateTime DynamicLoadManagerEvents::from() const
{
    return m_from;
}

void DynamicLoadManagerEvents::setFrom(const QDateTime &from)
{
    if (m_from == from)
        return;
    m_from = from;
    emit fromChanged();
    scheduleRefresh();
}

QDateTime DynamicLoadManagerEvents::to() const
{
    return m_to;
}

void DynamicLoadManagerEvents::setTo(const QDateTime &to)
{
    if (m_to == to)
        return;
    m_to = to;
    emit toChanged();
    scheduleRefresh();
}

bool DynamicLoadManagerEvents::includeDescendants() const
{
    return m_includeDescendants;
}

void DynamicLoadManagerEvents::setIncludeDescendants(bool includeDescendants)
{
    if (m_includeDescendants == includeDescendants)
        return;
    m_includeDescendants = includeDescendants;
    emit includeDescendantsChanged();
    scheduleRefresh();
}

bool DynamicLoadManagerEvents::live() const
{
    return m_live;
}

void DynamicLoadManagerEvents::setLive(bool live)
{
    if (m_live == live)
        return;
    m_live = live;
    emit liveChanged();
}

bool DynamicLoadManagerEvents::busy() const
{
    return m_busy;
}

QVariantMap DynamicLoadManagerEvents::get(int index) const
{
    QVariantMap map;
    if (index < 0 || index >= m_events.size())
        return map;
    const QHash<int, QByteArray> roles = roleNames();
    for (auto it = roles.constBegin(); it != roles.constEnd(); ++it)
        map.insert(QString::fromUtf8(it.value()), data(this->index(index), it.key()));
    return map;
}

void DynamicLoadManagerEvents::classBegin()
{
}

void DynamicLoadManagerEvents::componentComplete()
{
    m_componentComplete = true;
    refresh();
}

void DynamicLoadManagerEvents::scheduleRefresh()
{
    if (!m_componentComplete)
        return;
    m_refreshTimer.start();
}

void DynamicLoadManagerEvents::connectManager()
{
    if (!m_manager)
        return;
    connect(m_manager, &DynamicLoadManagerManager::nodeHistoryEventAdded, this, &DynamicLoadManagerEvents::nodeHistoryEventAdded);
    connect(m_manager, &DynamicLoadManagerManager::configurationChanged, this, &DynamicLoadManagerEvents::rebuildNodeFilter);
    connect(m_manager, &DynamicLoadManagerManager::destroyed, this, [this] { m_manager = nullptr; });
}

void DynamicLoadManagerEvents::refresh()
{
    if (!m_manager || !m_manager->engine() || m_nodeId.isEmpty())
        return;

    rebuildNodeFilter();

    QVariantMap params;
    params.insert("nodeId", m_nodeId);
    if (m_from.isValid())
        params.insert("from", m_from.toUTC().toString(Qt::ISODateWithMs));
    if (m_to.isValid())
        params.insert("to", m_to.toUTC().toString(Qt::ISODateWithMs));
    params.insert("includeDescendants", m_includeDescendants);

    m_manager->engine()->jsonRpcClient()->sendCommand("DynamicLoadManager.GetNodeEvents", params, this, "eventsReply");

    m_busy = true;
    emit busyChanged();
}

void DynamicLoadManagerEvents::eventsReply(int commandId, const QVariantMap &params)
{
    Q_UNUSED(commandId)
    m_busy = false;
    emit busyChanged();

    QVector<Event> events;
    const QVariantList list = params.value("nodeHistoryEvents").toList();
    events.reserve(list.size());
    for (const QVariant &entry : list)
        events.append(parseEvent(entry.toMap()));

    // Newest first.
    std::sort(events.begin(), events.end(), [](const Event &a, const Event &b) {
        return a.timestamp > b.timestamp;
    });

    beginResetModel();
    m_events = events;
    endResetModel();
    emit countChanged();
}

void DynamicLoadManagerEvents::nodeHistoryEventAdded(const QVariantMap &event)
{
    if (!m_live)
        return;

    Event e = parseEvent(event);
    if (!m_nodeFilter.contains(e.nodeId))
        return;
    if (m_to.isValid() && e.timestamp > m_to)
        return;

    // Insert keeping descending-by-timestamp order (newest first).
    int row = 0;
    while (row < m_events.size() && m_events.at(row).timestamp > e.timestamp)
        ++row;

    beginInsertRows(QModelIndex(), row, row);
    m_events.insert(row, e);
    endInsertRows();
    emit countChanged();
}

DynamicLoadManagerEvents::Event DynamicLoadManagerEvents::parseEvent(const QVariantMap &map)
{
    Event e;
    e.timestamp = parseTimestamp(map.value("timestamp"));
    e.nodeId = map.value("nodeId").toString();
    e.eventType = map.value("eventType").toString();
    e.severity = map.value("severity").toString();
    e.reason = map.value("reason").toString();
    e.details = map.value("details").toMap();
    return e;
}

void DynamicLoadManagerEvents::rebuildNodeFilter()
{
    m_nodeFilter.clear();
    if (m_nodeId.isEmpty())
        return;
    m_nodeFilter.insert(m_nodeId);
    if (m_includeDescendants && m_manager) {
        const QVariantMap root = m_manager->configuration().value("root").toMap();
        collectDescendants(root, false, m_nodeFilter);
    }
}

void DynamicLoadManagerEvents::collectDescendants(const QVariantMap &node, bool collecting, QSet<QString> &ids) const
{
    const QString id = node.value("id").toString();
    const bool isTarget = id == m_nodeId;
    if (collecting && !id.isEmpty())
        ids.insert(id);

    const QVariantList children = node.value("children").toList();
    for (const QVariant &child : children)
        collectDescendants(child.toMap(), collecting || isTarget, ids);
}

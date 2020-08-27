/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
* Copyright 2013 - 2020, nymea GmbH
* Contact: contact@nymea.io
*
* This file is part of nymea.
* This project including source code and documentation is protected by
* copyright law, and remains the property of nymea GmbH. All rights, including
* reproduction, publication, editing and translation, are reserved. The use of
* this project is subject to the terms of a license agreement to be concluded
* with nymea GmbH in accordance with the terms of use of nymea GmbH, available
* under https://nymea.io/license
*
* GNU General Public License Usage
* Alternatively, this project may be redistributed and/or modified under the
* terms of the GNU General Public License as published by the Free Software
* Foundation, GNU version 3. This project is distributed in the hope that it
* will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty
* of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
* Public License for more details.
*
* You should have received a copy of the GNU General Public License along with
* this project. If not, see <https://www.gnu.org/licenses/>.
*
* For any further details and any questions please contact us under
* contact@nymea.io or see our FAQ/Licensing Information on
* https://nymea.io/license/faq
*
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#include "logsmodel.h"
#include <QDateTime>
#include <QDebug>
#include <QMetaEnum>
#include <QJsonDocument>

#include "engine.h"
#include "types/logentry.h"
#include "logmanager.h"

LogsModel::LogsModel(QObject *parent) : QAbstractListModel(parent)
{

}

Engine *LogsModel::engine() const
{
    return m_engine;
}

void LogsModel::setEngine(Engine *engine)
{
    if (m_engine != engine) {
        m_engine = engine;
        connect(engine->logManager(), &LogManager::logEntryReceived, this, &LogsModel::newLogEntryReceived);
        emit engineChanged();
    }
}

int LogsModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return m_list.count();
}

QVariant LogsModel::data(const QModelIndex &index, int role) const
{
    switch (role) {
    case RoleTimestamp:
        return m_list.at(index.row())->timestamp();
    case RoleValue:
        return m_list.at(index.row())->value();
    case RoleThingId:
    case RoleDeviceId:
        return m_list.at(index.row())->thingId();
    case RoleTypeId:
        return m_list.at(index.row())->typeId();
    case RoleSource:
        return m_list.at(index.row())->source();
    case RoleLoggingEventType:
        return m_list.at(index.row())->loggingEventType();
    }
    return QVariant();
}

QHash<int, QByteArray> LogsModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles.insert(RoleTimestamp, "timestamp");
    roles.insert(RoleValue, "value");
    roles.insert(RoleThingId, "thingId");
    roles.insert(RoleDeviceId, "deviceId");
    roles.insert(RoleTypeId, "typeId");
    roles.insert(RoleSource, "source");
    roles.insert(RoleLoggingEventType, "loggingEventType");
    return roles;
}

bool LogsModel::busy() const
{
    return m_busy;
}

bool LogsModel::live() const
{
    return m_live;
}

void LogsModel::setLive(bool live)
{
    if (m_live != live) {
        m_live = live;
        emit liveChanged();
    }
}

QUuid LogsModel::thingId() const
{
    return m_thingId;
}

void LogsModel::setThingId(const QUuid &thingId)
{
    if (m_thingId != thingId) {
        m_thingId = thingId;
        emit thingIdChanged();
    }
}

QStringList LogsModel::typeIds() const
{
    QStringList strings;
    foreach (const QUuid &id, m_typeIds) {
        strings.append(id.toString());
    }
    return strings;
}

void LogsModel::setTypeIds(const QStringList &typeIds)
{
    QList<QUuid> fixedTypeIds;
    foreach (const QString &id, typeIds) {
        fixedTypeIds.append(QUuid(id));
    }
    if (m_typeIds != fixedTypeIds) {
        m_typeIds = fixedTypeIds;
        emit typeIdsChanged();
        beginResetModel();
        qDeleteAll(m_list);
        m_list.clear();
        endResetModel();
        fetchMore();
    }
}

QDateTime LogsModel::startTime() const
{
    return m_startTime;
}

void LogsModel::setStartTime(const QDateTime &startTime)
{
    if (m_startTime != startTime) {
        m_startTime = startTime;
        emit startTimeChanged();
    }
}

QDateTime LogsModel::endTime() const
{
    return m_endTime;
}

void LogsModel::setEndTime(const QDateTime &endTime)
{
    if (m_endTime != endTime) {
        m_endTime = endTime;
        emit endTimeChanged();
    }
}

QDateTime LogsModel::viewStartTime() const
{
    return m_viewStartTime;
}

void LogsModel::setViewStartTime(const QDateTime &viewStartTime)
{
    if (m_viewStartTime != viewStartTime) {
        m_viewStartTime = viewStartTime;
        emit viewStartTimeChanged();
        if (m_list.count() == 0 || m_list.last()->timestamp() > m_viewStartTime) {
            if (m_canFetchMore) {
                fetchMore();
            }
        }
    }
}

LogEntry *LogsModel::get(int index) const
{
    if (index >= 0 && index < m_list.count()) {
        return m_list.at(index);
    }
    return nullptr;
}

void LogsModel::logsReply(const QVariantMap &data)
{
    int offset = data.value("params").toMap().value("offset").toInt();
    int count = data.value("params").toMap().value("count").toInt();

//    qDebug() << qUtf8Printable(QJsonDocument::fromVariant(data).toJson());

    QList<LogEntry*> newBlock;
    QList<QVariant> logEntries = data.value("params").toMap().value("logEntries").toList();
    foreach (const QVariant &logEntryVariant, logEntries) {
        QVariantMap entryMap = logEntryVariant.toMap();
        QDateTime timeStamp = QDateTime::fromMSecsSinceEpoch(entryMap.value("timestamp").toLongLong());
        QString thingId;
        if (m_engine->jsonRpcClient()->ensureServerVersion("5.0")) {
            thingId = entryMap.value("thingId").toString();
        } else {
            thingId = entryMap.value("deviceId").toString();
        }
        QString typeId = entryMap.value("typeId").toString();
        QMetaEnum sourceEnum = QMetaEnum::fromType<LogEntry::LoggingSource>();
        LogEntry::LoggingSource loggingSource = static_cast<LogEntry::LoggingSource>(sourceEnum.keyToValue(entryMap.value("source").toByteArray()));
        QMetaEnum loggingEventTypeEnum = QMetaEnum::fromType<LogEntry::LoggingEventType>();
        LogEntry::LoggingEventType loggingEventType = static_cast<LogEntry::LoggingEventType>(loggingEventTypeEnum.keyToValue(entryMap.value("eventType").toByteArray()));
        QVariant value = loggingEventType == LogEntry::LoggingEventTypeActiveChange ? entryMap.value("active").toBool() : entryMap.value("value");
        LogEntry *entry = new LogEntry(timeStamp, value, thingId, typeId, loggingSource, loggingEventType, this);
        newBlock.append(entry);
    }

//    qDebug() << "Received logs from" << offset << "to" << offset + count << "Actual count:" << newBlock.count();

    if (count < m_blockSize) {
        m_canFetchMore = false;
    }

    if (newBlock.isEmpty()) {
        m_busyInternal = false;
        m_busy = false;
        emit busyChanged();
        return;
    }

    beginInsertRows(QModelIndex(), offset, offset + newBlock.count() - 1);
    for (int i = 0; i < newBlock.count(); i++) {
        LogEntry *entry = newBlock.at(i);
        m_list.insert(offset + i, entry);
        emit logEntryAdded(entry);
    }
    endInsertRows();
    emit countChanged();

    m_busyInternal = false;

    if (m_viewStartTime.isValid() && m_list.count() > 0 && m_list.last()->timestamp() > m_viewStartTime && m_canFetchMore) {
        fetchMore();
    } else {
        m_busy = false;
        emit busyChanged();
    }
}

void LogsModel::fetchMore(const QModelIndex &parent)
{
    Q_UNUSED(parent)

    if (!m_engine) {
        qWarning() << "Cannot update. Engine not set";
        return;
    }
    if (m_busyInternal) {
        return;
    }

    if ((!m_startTime.isNull() && m_endTime.isNull()) || (m_startTime.isNull() && !m_endTime.isNull())) {
        qDebug() << "Need neither or both, startTime and endTime set";
        return;
    }

    m_busyInternal = true;
    if (!m_busy) {
        m_busy = true;
        emit busyChanged();
    }


    QVariantMap params;
    if (!m_thingId.isNull()) {
        QVariantList thingIds;
        thingIds.append(m_thingId);
        if (m_engine->jsonRpcClient()->ensureServerVersion("5.0")) {
            params.insert("thingIds", thingIds);
        } else {
            params.insert("deviceIds", thingIds);
        }
    }
    if (!m_typeIds.isEmpty()) {
        QVariantList typeIds;
        foreach (const QUuid &typeId, m_typeIds) {
            typeIds.append(typeId);
        }
        params.insert("typeIds", typeIds);
    }
    if (!m_startTime.isNull() && !m_endTime.isNull()) {
        QVariantList timeFilters;
        QVariantMap timeFilter;
        timeFilter.insert("startDate", m_startTime.toSecsSinceEpoch());
        timeFilter.insert("endDate", m_endTime.toSecsSinceEpoch());
        timeFilters.append(timeFilter);
        params.insert("timeFilters", timeFilters);
    }

    params.insert("limit", m_blockSize);
    params.insert("offset", m_list.count());

    qDebug() << "Fetching logs from" << m_startTime.toString() << "to" << m_endTime.toString() << "with offset" << m_list.count() << "and limit" << m_blockSize;

    m_engine->jsonRpcClient()->sendCommand("Logging.GetLogEntries", params, this, "logsReply");
    //    qDebug() << "GetLogEntries called";
}

void LogsModel::classBegin()
{

}

void LogsModel::componentComplete()
{
    fetchMore();
}

bool LogsModel::canFetchMore(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
//    qDebug() << "canFetchMore" << (m_engine && m_canFetchMore);
    return m_engine && m_canFetchMore;
}

void LogsModel::newLogEntryReceived(const QVariantMap &data)
{
//    qDebug() << "***** model NG" << data << m_live;
    if (!m_live) {
        return;
    }

    QVariantMap entryMap = data;
    QUuid thingId;
    if (m_engine->jsonRpcClient()->ensureServerVersion("5.0")) {
        thingId = entryMap.value("deviceId").toUuid();
    } else {
        thingId = entryMap.value("thingId").toUuid();
    }
    if (!m_thingId.isNull() && thingId != m_thingId) {
        return;
    }

    QUuid typeId = entryMap.value("typeId").toUuid();
    if (!m_typeIds.isEmpty() && !m_typeIds.contains(typeId)) {
        return;
    }

    beginInsertRows(QModelIndex(), 0, 0);
    QDateTime timeStamp = QDateTime::fromMSecsSinceEpoch(entryMap.value("timestamp").toLongLong());
    QMetaEnum sourceEnum = QMetaEnum::fromType<LogEntry::LoggingSource>();
    LogEntry::LoggingSource loggingSource = static_cast<LogEntry::LoggingSource>(sourceEnum.keyToValue(entryMap.value("source").toByteArray()));
    QMetaEnum loggingEventTypeEnum = QMetaEnum::fromType<LogEntry::LoggingEventType>();
    LogEntry::LoggingEventType loggingEventType = static_cast<LogEntry::LoggingEventType>(loggingEventTypeEnum.keyToValue(entryMap.value("eventType").toByteArray()));
    QVariant value = loggingEventType == LogEntry::LoggingEventTypeActiveChange ? entryMap.value("active").toBool() : entryMap.value("value");
    LogEntry *entry = new LogEntry(timeStamp, value, thingId, typeId, loggingSource, loggingEventType, this);
    m_list.prepend(entry);
    endInsertRows();
    emit countChanged();

    emit logEntryAdded(entry);

}

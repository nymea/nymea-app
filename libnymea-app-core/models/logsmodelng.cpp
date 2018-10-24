#include "logsmodelng.h"
#include <QDateTime>
#include <QDebug>
#include <QMetaEnum>

#include "engine.h"
#include "types/logentry.h"
#include "logmanager.h"

LogsModelNg::LogsModelNg(QObject *parent) : QAbstractListModel(parent),
    m_lineSeries(new QtCharts::QLineSeries(this))
{

}

Engine *LogsModelNg::engine() const
{
    return m_engine;
}

void LogsModelNg::setEngine(Engine *engine)
{
    if (m_engine != engine) {
        m_engine = engine;
        connect(engine->logManager(), &LogManager::logEntryReceived, this, &LogsModelNg::newLogEntryReceived);
        emit engineChanged();
    }
}

int LogsModelNg::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return m_list.count();
}

QVariant LogsModelNg::data(const QModelIndex &index, int role) const
{
    switch (role) {
    case RoleTimestamp:
        return m_list.at(index.row())->timestamp();
    case RoleValue:
        return m_list.at(index.row())->value();
    case RoleDeviceId:
        return m_list.at(index.row())->deviceId();
    case RoleTypeId:
        return m_list.at(index.row())->typeId();
    case RoleSource:
        return m_list.at(index.row())->source();
    case RoleLoggingEventType:
        return m_list.at(index.row())->loggingEventType();
    }
    return QVariant();
}

QHash<int, QByteArray> LogsModelNg::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles.insert(RoleTimestamp, "timestamp");
    roles.insert(RoleValue, "value");
    roles.insert(RoleDeviceId, "deviceId");
    roles.insert(RoleTypeId, "typeId");
    roles.insert(RoleSource, "source");
    roles.insert(RoleLoggingEventType, "loggingEventType");
    return roles;
}

bool LogsModelNg::busy() const
{
    return m_busy;
}

bool LogsModelNg::live() const
{
    return m_live;
}

void LogsModelNg::setLive(bool live)
{
    if (m_live != live) {
        m_live = live;
        emit liveChanged();
    }
}

QString LogsModelNg::deviceId() const
{
    return m_deviceId;
}

void LogsModelNg::setDeviceId(const QString &deviceId)
{
    if (m_deviceId != deviceId) {
        m_deviceId = deviceId;
        emit deviceIdChanged();
    }
}

QStringList LogsModelNg::typeIds() const
{
    return m_typeIds;
}

void LogsModelNg::setTypeIds(const QStringList &typeIds)
{
    if (m_typeIds != typeIds) {
        m_typeIds = typeIds;
        emit typeIdsChanged();
    }
}

QDateTime LogsModelNg::startTime() const
{
    return m_startTime;
}

void LogsModelNg::setStartTime(const QDateTime &startTime)
{
    if (m_startTime != startTime) {
        m_startTime = startTime;
        emit startTimeChanged();
    }
}

QDateTime LogsModelNg::endTime() const
{
    return m_endTime;
}

void LogsModelNg::setEndTime(const QDateTime &endTime)
{
    if (m_endTime != endTime) {
        m_endTime = endTime;
        emit endTimeChanged();
    }
}

QtCharts::QLineSeries *LogsModelNg::lineSeries() const
{
    return m_lineSeries;
}

void LogsModelNg::setLineSeries(QtCharts::QLineSeries *lineSeries)
{
    m_lineSeries = lineSeries;
}

void LogsModelNg::logsReply(const QVariantMap &data)
{
//    qDebug() << "logs reply" << data;

    m_busy = false;
    emit busyChanged();

    int offset = data.value("params").toMap().value("offset").toInt();
    int count = data.value("params").toMap().value("count").toInt();

    QList<LogEntry*> newBlock;
    QList<QVariant> logEntries = data.value("params").toMap().value("logEntries").toList();
    foreach (const QVariant &logEntryVariant, logEntries) {
        QVariantMap entryMap = logEntryVariant.toMap();
        QDateTime timeStamp = QDateTime::fromMSecsSinceEpoch(entryMap.value("timestamp").toLongLong());
        QString deviceId = entryMap.value("deviceId").toString();
        QString typeId = entryMap.value("typeId").toString();
        QMetaEnum sourceEnum = QMetaEnum::fromType<LogEntry::LoggingSource>();
        LogEntry::LoggingSource loggingSource = static_cast<LogEntry::LoggingSource>(sourceEnum.keyToValue(entryMap.value("source").toByteArray()));
        QMetaEnum loggingEventTypeEnum = QMetaEnum::fromType<LogEntry::LoggingEventType>();
        LogEntry::LoggingEventType loggingEventType = static_cast<LogEntry::LoggingEventType>(loggingEventTypeEnum.keyToValue(entryMap.value("eventType").toByteArray()));
        QVariant value = loggingEventType == LogEntry::LoggingEventTypeActiveChange ? entryMap.value("active").toBool() : entryMap.value("value");
        LogEntry *entry = new LogEntry(timeStamp, value, deviceId, typeId, loggingSource, loggingEventType, this);
        newBlock.append(entry);
    }

    if (count < m_blockSize) {
        m_canFetchMore = false;
    }

    if (newBlock.isEmpty()) {
        return;
    }

    beginInsertRows(QModelIndex(), offset, offset + newBlock.count() - 1);
    for (int i = 0; i < newBlock.count(); i++) {
        m_list.insert(offset + i, newBlock.at(i));
        qDebug() << "Adding line series point:" << i << newBlock.at(i)->timestamp().toSecsSinceEpoch() << newBlock.at(i)->value().toReal();
        m_lineSeries->insert(offset + i, QPointF(newBlock.at(i)->timestamp().toSecsSinceEpoch(), newBlock.at(i)->value().toReal()));
    }
    endInsertRows();
    emit countChanged();
}

void LogsModelNg::fetchMore(const QModelIndex &parent)
{
    Q_UNUSED(parent)
    qDebug() << "fetchMore called";

    if (!m_engine->jsonRpcClient()) {
        qWarning() << "Cannot update. JsonRpcClient not set";
        return;
    }
    if (m_busy) {
        return;
    }

    if ((!m_startTime.isNull() && m_endTime.isNull()) || (m_startTime.isNull() && !m_endTime.isNull())) {
        // Need neither or both, startTime and endTime set
        return;
    }

    m_busy = true;
    emit busyChanged();

    QVariantMap params;
    if (!m_deviceId.isEmpty()) {
        QVariantList deviceIds;
        deviceIds.append(m_deviceId);
        params.insert("deviceIds", deviceIds);
    }
    if (!m_typeIds.isEmpty()) {
        QVariantList typeIds;
        foreach (const QString &typeId, m_typeIds) {
            typeIds.append(typeId);
        }
        params.insert("typeIds", typeIds);
    }
    if (!m_startTime.isNull() && !m_endTime.isNull()) {
        QVariantList timeFilters;
        QVariantMap timeFilter;
        timeFilter.insert("startDate", m_currentFetchStartTime.toSecsSinceEpoch());
        timeFilter.insert("endDate", m_currentFetchEndTime.toSecsSinceEpoch());
        timeFilters.append(timeFilter);
        params.insert("timeFilters", timeFilters);
    }

    params.insert("limit", m_blockSize);
    params.insert("offset", m_list.count());

    m_engine->jsonRpcClient()->sendCommand("Logging.GetLogEntries", params, this, "logsReply");
    qDebug() << "GetLogEntries called";
}

bool LogsModelNg::canFetchMore(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    qDebug() << "canFetchMore" << m_canFetchMore;
    return m_canFetchMore;
}

void LogsModelNg::newLogEntryReceived(const QVariantMap &data)
{
    if (!m_live) {
        return;
    }

    QVariantMap entryMap = data;
    QString deviceId = entryMap.value("deviceId").toString();
    if (!m_deviceId.isNull() && deviceId != m_deviceId) {
        return;
    }

    QString typeId = entryMap.value("typeId").toString();
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
    LogEntry *entry = new LogEntry(timeStamp, value, deviceId, typeId, loggingSource, loggingEventType, this);
    m_list.prepend(entry);
    endInsertRows();
    emit countChanged();

}



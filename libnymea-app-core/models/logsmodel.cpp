#include "logsmodel.h"

#include "engine.h"
#include "logmanager.h"

#include <QMetaEnum>

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

bool LogsModel::busy() const
{
    return m_busy;
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

QHash<int, QByteArray> LogsModel::roleNames() const
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

QString LogsModel::deviceId() const
{
    return m_deviceId;
}

void LogsModel::setDeviceId(const QString &deviceId)
{
    if (m_deviceId != deviceId) {
        m_deviceId = deviceId;
        emit deviceIdChanged();
    }
}

QStringList LogsModel::typeIds() const
{
    return m_typeIds;
}

void LogsModel::setTypeIds(const QStringList &typeIds)
{
    if (m_typeIds != typeIds) {
        m_typeIds = typeIds;
        emit typeIdsChanged();
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

LogEntry *LogsModel::get(int index) const
{
    if (index >= 0 && index < m_list.count()) {
        return m_list.at(index);
    }
    return nullptr;
}

void LogsModel::notificationReceived(const QVariantMap &data)
{
    qDebug() << "KLogModel notificatiion" << data;
}

void LogsModel::update()
{
    if (!m_engine) {
        qWarning() << "LogsModel: Can't update, no engine set";
        return;
    }
    if (m_busy) {
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
    QVariantList timeFilters;
    QVariantMap timeFilter;
    timeFilter.insert("startDate", m_startTime.toSecsSinceEpoch());
    timeFilter.insert("endDate", m_endTime.toSecsSinceEpoch());
    timeFilters.append(timeFilter);
    params.insert("timeFilters", timeFilters);
    m_engine->jsonRpcClient()->sendCommand("Logging.GetLogEntries", params, this, "logsReply");
}

void LogsModel::fetchEarlier(int hours)
{
    if (!m_engine) {
        return;
    }
    if (m_busy) {
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
    QVariantList timeFilters;
    QVariantMap timeFilter;
    timeFilter.insert("endDate", m_startTime.toSecsSinceEpoch());
    m_startTime = m_startTime.addSecs(-60*60*hours);
    timeFilter.insert("startDate", m_startTime.toSecsSinceEpoch());
    timeFilters.append(timeFilter);
    params.insert("timeFilters", timeFilters);
    m_engine->jsonRpcClient()->sendCommand("Logging.GetLogEntries", params, this, "fetchEarlierReply");
}

void LogsModel::logsReply(const QVariantMap &data)
{
    qDebug() << "logs reply";// << data;
    beginResetModel();
    qDeleteAll(m_list);
    m_list.clear();

    QList<QVariant> logEntries = data.value("params").toMap().value("logEntries").toList();
    foreach (const QVariant &logEntryVariant, logEntries) {
        QVariantMap entryMap = logEntryVariant.toMap();
        QDateTime timeStamp = QDateTime::fromMSecsSinceEpoch(entryMap.value("timestamp").toLongLong());
        QString deviceId = entryMap.value("deviceId").toString();
        QString typeId = entryMap.value("typeId").toString();
        QMetaEnum sourceEnum = QMetaEnum::fromType<LogEntry::LoggingSource>();
        LogEntry::LoggingSource loggingSource = (LogEntry::LoggingSource)sourceEnum.keyToValue(entryMap.value("source").toByteArray());
        QMetaEnum loggingEventTypeEnum = QMetaEnum::fromType<LogEntry::LoggingEventType>();
        LogEntry::LoggingEventType loggingEventType = (LogEntry::LoggingEventType)loggingEventTypeEnum.keyToValue(entryMap.value("eventType").toByteArray());
        QVariant value = loggingEventType == LogEntry::LoggingEventTypeActiveChange ? entryMap.value("active").toBool() : entryMap.value("value");
        LogEntry *entry = new LogEntry(timeStamp, value, deviceId, typeId, loggingSource, loggingEventType, this);
        m_list.append(entry);
    }

    endResetModel();
    emit countChanged();

    m_busy = false;
    emit busyChanged();
}

void LogsModel::fetchEarlierReply(const QVariantMap &data)
{
    qDebug() << "logs reply";// << data;

    QList<QVariant> logEntries = data.value("params").toMap().value("logEntries").toList();
    QList<LogEntry*> newEntries;
    foreach (const QVariant &logEntryVariant, logEntries) {
        QVariantMap entryMap = logEntryVariant.toMap();
        QDateTime timeStamp = QDateTime::fromMSecsSinceEpoch(entryMap.value("timestamp").toLongLong());
        QString deviceId = entryMap.value("deviceId").toString();
        QString typeId = entryMap.value("typeId").toString();
        QMetaEnum sourceEnum = QMetaEnum::fromType<LogEntry::LoggingSource>();
        LogEntry::LoggingSource loggingSource = (LogEntry::LoggingSource)sourceEnum.keyToValue(entryMap.value("source").toByteArray());
        QMetaEnum loggingEventTypeEnum = QMetaEnum::fromType<LogEntry::LoggingEventType>();
        LogEntry::LoggingEventType loggingEventType = (LogEntry::LoggingEventType)loggingEventTypeEnum.keyToValue(entryMap.value("eventType").toByteArray());
        QVariant value = loggingEventType == LogEntry::LoggingEventTypeActiveChange ? entryMap.value("active").toBool() : entryMap.value("value");
        LogEntry *entry = new LogEntry(timeStamp, value, deviceId, typeId, loggingSource, loggingEventType, this);
        newEntries.append(entry);
    }
    beginInsertRows(QModelIndex(), 0, newEntries.count() - 1);
    newEntries.append(m_list);
    m_list = newEntries;
    endInsertRows();
    emit countChanged();

    m_busy = false;
    emit busyChanged();
}

void LogsModel::newLogEntryReceived(const QVariantMap &data)
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

    beginInsertRows(QModelIndex(), m_list.count(), m_list.count());
    QDateTime timeStamp = QDateTime::fromMSecsSinceEpoch(entryMap.value("timestamp").toLongLong());
    QMetaEnum sourceEnum = QMetaEnum::fromType<LogEntry::LoggingSource>();
    LogEntry::LoggingSource loggingSource = (LogEntry::LoggingSource)sourceEnum.keyToValue(entryMap.value("source").toByteArray());
    QMetaEnum loggingEventTypeEnum = QMetaEnum::fromType<LogEntry::LoggingEventType>();
    LogEntry::LoggingEventType loggingEventType = (LogEntry::LoggingEventType)loggingEventTypeEnum.keyToValue(entryMap.value("eventType").toByteArray());
    QVariant value = loggingEventType == LogEntry::LoggingEventTypeActiveChange ? entryMap.value("active").toBool() : entryMap.value("value");
    LogEntry *entry = new LogEntry(timeStamp, value, deviceId, typeId, loggingSource, loggingEventType, this);
    m_list.append(entry);
    endInsertRows();
    emit countChanged();
}

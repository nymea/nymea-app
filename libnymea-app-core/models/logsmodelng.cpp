#include "logsmodelng.h"
#include <QDateTime>
#include <QDebug>
#include <QMetaEnum>

#include "engine.h"
#include "types/logentry.h"

LogsModelNg::LogsModelNg(QObject *parent) : QAbstractListModel(parent)
{

}

JsonRpcClient *LogsModelNg::jsonRpcClient() const
{
    return m_jsonRpcClient;
}

void LogsModelNg::setJsonRpcClient(JsonRpcClient *jsonRpcClient)
{
    if (m_jsonRpcClient != jsonRpcClient) {
        m_jsonRpcClient = jsonRpcClient;
        emit jsonRpcClientChanged();
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

QString LogsModelNg::typeId() const
{
    return m_typeId;
}

void LogsModelNg::setTypeId(const QString &typeId)
{
    if (m_typeId != typeId) {
        m_typeId = typeId;
        emit typeIdChanged();
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
        update();
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
        update();
    }
}

void LogsModelNg::update()
{
    if (!m_jsonRpcClient) {
        qWarning() << "Cannot update. JsonRpcClient not set";
        return;
    }
    if (m_busy) {
        return;
    }

    if (m_startTime.isNull() || m_endTime.isNull()) {
        // Need both, startTime and endTime set
        return;
    }

    m_currentFetchStartTime = QDateTime();
    m_currentFetchEndTime = QDateTime();
    bool haveData = false;
    for(int i = 0; i < m_fetchedPeriods.length(); i++) {
        if (m_fetchedPeriods.at(i).first < m_startTime) {
            if (m_fetchedPeriods.at(i).second == true) {
                haveData = true;
                continue;
            }
            if (m_fetchedPeriods.at(i).second == false) {
                haveData = false;
                continue;
            }
        }
        if (m_fetchedPeriods.at(i).first == m_startTime) {
            if (m_fetchedPeriods.at(i).second == true) {
                haveData = true;
                continue;
            }
            if (m_fetchedPeriods.at(i).second == false) {
                m_currentFetchStartTime = m_startTime;
                continue;
            }
        }
        if (m_fetchedPeriods.at(i).first > m_startTime) {
            if (m_fetchedPeriods.at(i).second == true) {
                if (m_currentFetchStartTime.isNull()) {
                    m_currentFetchStartTime = m_startTime;
                }
                m_currentFetchEndTime = m_fetchedPeriods.at(i).first;
                break;
            }
            if (m_fetchedPeriods.at(i).second == false) {
                if (m_currentFetchStartTime.isNull()) {
                    haveData = false;
                    m_currentFetchStartTime = m_fetchedPeriods.at(i).first;
                }
                continue;
            }
        }
    }
    if (haveData) {
        qDebug() << "all the data is fetched";
        m_busy = false;
        emit busyChanged();
        return;
    }
    if (m_currentFetchStartTime.isNull()) {
        m_currentFetchStartTime = m_startTime;
    }
    if (m_currentFetchEndTime.isNull()) {
        m_currentFetchEndTime = m_endTime;
    }
    qDebug() << "Fetching from" << m_currentFetchStartTime << "to" << m_currentFetchEndTime;

    m_busy = true;
    emit busyChanged();

    QVariantMap params;
    if (!m_deviceId.isEmpty()) {
        QVariantList deviceIds;
        deviceIds.append(m_deviceId);
        params.insert("deviceIds", deviceIds);
    }
    if (!m_typeId.isEmpty()) {
        QVariantList typeIds;
        typeIds.append(m_typeId);
        params.insert("typeIds", typeIds);
    }
    QVariantList timeFilters;
    QVariantMap timeFilter;
    timeFilter.insert("startDate", m_currentFetchStartTime.toSecsSinceEpoch());
    timeFilter.insert("endDate", m_currentFetchEndTime.toSecsSinceEpoch());
    timeFilters.append(timeFilter);
    params.insert("timeFilters", timeFilters);
    m_jsonRpcClient->sendCommand("Logging.GetLogEntries", params, this, "logsReply");
}

void LogsModelNg::logsReply(const QVariantMap &data)
{
    qDebug() << "logs reply";// << data;

    // First update the fetched periods information
    int insertIndex = -1;
    bool noNeedToInsert = false;
    for (int i = 0; i < m_fetchedPeriods.count(); i++) {
        if (m_fetchedPeriods.at(i).first < m_currentFetchStartTime) {
            // skip it
            insertIndex = i+1;
            continue;
        }
        if (m_fetchedPeriods.at(i).first == m_currentFetchStartTime) {
            if (m_fetchedPeriods.at(i).second == false) {
                // Have an end marker where we start inserting. We can drop the existing end marker and just update the end marker
                if (m_fetchedPeriods.count() > i+1) {
                    if (m_fetchedPeriods.at(i+1).first < m_currentFetchEndTime) {
                        qWarning() << "Overlap detected!";
                    } else if (m_fetchedPeriods.at(i+1).first == m_currentFetchEndTime) {
                        if (m_fetchedPeriods.at(i+1).second == true) {
                            m_fetchedPeriods.removeAt(i+1);
                        }
                    }
                }
                m_fetchedPeriods.removeAt(i);
                noNeedToInsert = true;
                break;
            }
        }
        if (m_fetchedPeriods.at(i).first > m_currentFetchStartTime) {
            break;
        }
    }

    if (!noNeedToInsert) {
        if (insertIndex == -1) {
            insertIndex = 0;
        }
        m_fetchedPeriods.insert(insertIndex, qMakePair<QDateTime,bool>(m_currentFetchStartTime, true));
        m_fetchedPeriods.insert(insertIndex+1, qMakePair<QDateTime,bool>(m_currentFetchEndTime, false));
    }
    qDebug() << "new fetched periods:" << m_fetchedPeriods << "insertIndex:" << insertIndex;
    m_busy = false;
    emit busyChanged();


    QList<LogEntry*> newBlock;
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
        newBlock.append(entry);
    }

    // Now let's find where to insert stuff in the model
    if (!newBlock.isEmpty()) {
        int indexToInsert = 0;
        for (int i = 0; i < m_list.count(); i++) {
            LogEntry *entry = m_list.at(i);
            if (entry->timestamp() < newBlock.first()->timestamp()) {
                continue;
            }
            indexToInsert = i;
            break;
        }

        beginInsertRows(QModelIndex(), indexToInsert, indexToInsert + newBlock.count() - 1);
        for (int i = 0; i < newBlock.count(); i++) {
            m_list.insert(indexToInsert + i, newBlock.at(i));
        }
        endInsertRows();
        emit countChanged();
    }

    update();
}


#include "logsmodel.h"

#include "engine.h"

LogsModel::LogsModel(QObject *parent) : QAbstractListModel(parent)
{

}

bool LogsModel::busy() const
{
    return m_busy;
}

int LogsModel::rowCount(const QModelIndex &parent) const
{
    return m_list.count();
}

QVariant LogsModel::data(const QModelIndex &index, int role) const
{
    return QVariant();
}

QHash<int, QByteArray> LogsModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles.insert(RoleValue, "value");
    return roles;
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

QString LogsModel::typeId() const
{
    return m_typeId;
}

void LogsModel::setTypeId(const QString &typeId)
{
    if (m_typeId != typeId) {
        m_typeId = typeId;
        emit typeIdChanged();
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

void LogsModel::update()
{
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
    timeFilter.insert("startDate", m_startTime.toSecsSinceEpoch());
    timeFilter.insert("endDate", m_endTime.toSecsSinceEpoch());
    timeFilters.append(timeFilter);
    params.insert("timeFilters", timeFilters);
    Engine::instance()->jsonRpcClient()->sendCommand("Logging.GetLogEntries", params, this, "logsReply");
}

void LogsModel::logsReply(const QVariantMap &data)
{
    m_busy = false;
    emit busyChanged();
    beginResetModel();
    qDeleteAll(m_list);
    m_list.clear();

    QList<QVariant> logEntries = data.value("params").toMap().value("logEntries").toList();
    foreach (const QVariant &logEntryVariant, logEntries) {
        LogEntry *entry = new LogEntry(QDateTime::fromMSecsSinceEpoch(logEntryVariant.toMap().value("timestamp").toLongLong()), logEntryVariant.toMap().value("value"), this);
        m_list.append(entry);
        qDebug() << "Added log entry" << entry->dayString() << QDateTime::fromMSecsSinceEpoch(logEntryVariant.toMap().value("timestamp").toLongLong()).date().dayOfWeek();
    }

    endResetModel();
    emit countChanged();
}

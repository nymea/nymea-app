#include "newlogsmodel.h"

#include "engine.h"

#include "logging.h"
//NYMEA_LOGGING_CATEGORY(dcLogEngine, "LogEngine")
Q_DECLARE_LOGGING_CATEGORY(dcLogEngine)

#include <QJsonDocument>
#include <QMetaEnum>

NewLogsModel::NewLogsModel(QObject *parent)
    : QAbstractListModel{parent}
{

}

int NewLogsModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return m_list.count();
}

QVariant NewLogsModel::data(const QModelIndex &index, int role) const
{
    switch (role) {
    case RoleSource:
        return m_list.at(index.row())->source();
    case RoleTimestamp:
        return m_list.at(index.row())->timestamp();
    case RoleValues:
        return m_list.at(index.row())->values();
    }

    return QVariant();
}

QHash<int, QByteArray> NewLogsModel::roleNames() const
{
    return {
        {RoleSource, "source"},
        {RoleTimestamp, "timestamp"},
        {RoleValues, "values"}
    };
}

void NewLogsModel::classBegin()
{

}

void NewLogsModel::componentComplete()
{
    m_completed = true;
//    fetchMore();
}

bool NewLogsModel::canFetchMore(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return m_canFetchMore;
}

void NewLogsModel::fetchMore(const QModelIndex &parent)
{
    Q_UNUSED(parent)

    if (!m_engine) {
        return;
    }
    if (!m_completed) {
        return;
    }

    fetchLogs();

}

Engine *NewLogsModel::engine() const
{
    return m_engine;
}

void NewLogsModel::setEngine(Engine *engine)
{
    if (m_engine != engine) {
        m_engine = engine;
        emit engineChanged();

//        if (m_completed && m_canFetchMore) {
//            fetchMore();
//        }
    }
}

QString NewLogsModel::source() const
{
    return m_sources.count() > 0 ? m_sources.first() : "";
}

void NewLogsModel::setSource(const QString &source)
{
    if (m_sources != QStringList(source)) {
        m_sources = QStringList(source);
        emit sourcesChanged();
    }
}

QStringList NewLogsModel::sources() const
{
    return m_sources;
}

void NewLogsModel::setSources(const QStringList &sources)
{
    if (m_sources != sources) {
        m_sources = sources;
        emit sourcesChanged();
    }
}

QStringList NewLogsModel::columns() const
{
    return m_columns;
}

void NewLogsModel::setColumns(const QStringList &columns)
{
    if (m_columns != columns) {
        m_columns = columns;
        emit columnsChanged();
    }
}

QVariantMap NewLogsModel::filter() const
{
    return m_filter;
}

void NewLogsModel::setFilter(const QVariantMap &filter)
{
    if (m_filter != filter) {
        m_filter = filter;
        emit filterChanged();
    }
}

QDateTime NewLogsModel::startTime() const
{
    return m_startTime;
}

void NewLogsModel::setStartTime(const QDateTime &startTime)
{
    if (m_startTime != startTime) {
        m_startTime = startTime;
        emit startTimeChanged();
    }
}

QDateTime NewLogsModel::endTime() const
{
    return m_endTime;
}

void NewLogsModel::setEndTime(const QDateTime &endTime)
{
    if (m_endTime != endTime) {
        m_endTime = endTime;
        emit endTimeChanged();
    }
}

NewLogsModel::SampleRate NewLogsModel::sampleRate() const
{
    return m_sampleRate;
}

void NewLogsModel::setSampleRate(SampleRate sampleRate)
{
    if (m_sampleRate != sampleRate) {
        m_sampleRate = sampleRate;
        emit sampleRateChanged();
        clear();
    }
}

bool NewLogsModel::busy() const
{
    return m_busy;
}

NewLogEntry *NewLogsModel::get(int index) const
{
    if (index < 0 || index >= m_list.count()) {
        return nullptr;
    }
    return m_list.at(index);
}

NewLogEntry *NewLogsModel::find(const QDateTime &timestamp) const
{
//    qCDebug(dcLogEngine()) << "finding:" << timestamp.toString();
    if (m_list.isEmpty()) {
        return nullptr;
    }
    int idx = m_list.count() / 2;
    int jump = m_list.count() / 4;
    int stopper = 10;
    while (stopper-- > 0) {
//        qCDebug(dcLogEngine()) << "idx:" << idx << "cnt:" << m_list.count() << "jmp" << jump;
        NewLogEntry *entry = m_list.at(idx);
        if (entry->timestamp() == timestamp) {
//            qCDebug(dcLogEngine()) << "found exact";
            return entry;
        }
        qint64 diff = timestamp.msecsTo(entry->timestamp());
        if (entry->timestamp() > timestamp) {
//            qCDebug(dcLogEngine()) << "entry is newer than searched:" << entry->timestamp().toString() << timestamp.toString();
            if (idx == m_list.count() - 1) {
//                qCDebug(dcLogEngine()) << "Is oldest.";
                return entry;
            }
            NewLogEntry *previousEntry = m_list.at(idx+1);
            if (previousEntry->timestamp() < timestamp) {
                qint64 previousDiff = timestamp.msecsTo(previousEntry->timestamp());
//                qCDebug(dcLogEngine()) << "time between this and previous:" << entry->timestamp().toString() << previousEntry->timestamp().toString() << (qAbs(previousDiff) < qAbs(diff) ? "next" : "this");
                return qAbs(previousDiff) < qAbs(diff) ? previousEntry : entry;
            }
            idx += jump;
        } else if (entry->timestamp() < timestamp) {
//            qCDebug(dcLogEngine()) << "entry is older than searched:" << entry->timestamp().toString() << timestamp.toString();
            if (idx == 0) {
//                qCDebug(dcLogEngine()) << "Is newest.";
                return entry;
            }
            NewLogEntry *nextEntry = m_list.at(idx-1);
            if (nextEntry->timestamp() > timestamp) {
                qint64 nextDiff = timestamp.msecsTo(nextEntry->timestamp());
//                qCDebug(dcLogEngine()) << "time between next and this:" << nextEntry->timestamp().toString() << "-" << entry->timestamp().toString()  << (qAbs(nextDiff) > qAbs(diff) ? "prev" : "this");
                return qAbs(nextDiff) < qAbs(diff) ? nextEntry : entry;
            }
            idx -= jump;
        }
        jump = qMax(1, jump / 2);
    };
    return nullptr;
}

void NewLogsModel::clear()
{
    int count = m_list.count();
    beginResetModel();
    qDeleteAll(m_list);
    m_list.clear();
    endResetModel();
    emit countChanged();
    emit entriesRemoved(0, count);
}

void NewLogsModel::fetchLogs()
{
    if (!m_engine) {
        return;
    }
    QVariantMap params {
        {"sources", m_sources},
        {"columns", m_columns},
        {"filter", m_filter}
    };

    if (!m_startTime.isNull() && !m_endTime.isNull()) {
        QDateTime startTime;
        QDateTime endTime;

        QDateTime oldestExisting = m_list.count() > 0 ? m_list.last()->timestamp() : QDateTime();
        QDateTime newestExisting = m_list.count() > 0 ? m_list.first()->timestamp() : QDateTime();
        qCDebug(dcLogEngine()) << "request timeframe: " << m_startTime.toString() << " - " << m_endTime.toString();
        qCDebug(dcLogEngine()) << "existing timeframe:" << oldestExisting.toString() << "- " << newestExisting.toString();

        if (oldestExisting.isNull() || newestExisting.isNull()) {
            startTime = m_startTime;
            endTime = qMin(QDateTime::currentDateTime(), m_endTime);
        } else {

            if (m_startTime < oldestExisting) {
                startTime = m_startTime;
                endTime = qMin(QDateTime::currentDateTime(), qMin(m_endTime, oldestExisting));
            } else if (newestExisting < m_endTime) {
                startTime = qMax(m_startTime, newestExisting);
                endTime = qMin(QDateTime::currentDateTime(), m_endTime);
            } else {
                // Nothing to do...
                return;
            }
        }

        qCDebug(dcLogEngine()) << "Actual request:" << startTime.toString() << " - " << endTime.toString();
        params.insert("startTime", startTime.toMSecsSinceEpoch());
        params.insert("endTime", endTime.toMSecsSinceEpoch());
        QMetaEnum sampleRateEnum = QMetaEnum::fromType<SampleRate>();
        params.insert("sampleRate", sampleRateEnum.valueToKey(m_sampleRate));
    } else {
        params.insert("limit", m_blockSize);
        if (m_list.count() > 0) {
            params.insert("offset", m_list.count() - 1); // -1 because we'll fetch the last existing one again as the receiving logic checks if timestamps line up for proper insertion. It will be removed again there
            params.insert("endTime", m_list.first()->timestamp().toMSecsSinceEpoch());
        }
    }

//    if (!m_startTime.isNull()) {
//        params.insert("startTime", m_startTime.toMSecsSinceEpoch());
//    }
//    if (!m_endTime.isNull()) {
//        params.insert("endTime", m_endTime.toMSecsSinceEpoch());
//    }
    qCDebug(dcLogEngine()) << "Fetching logs:" << QJsonDocument::fromVariant(params).toJson();
    m_engine->jsonRpcClient()->sendCommand("Logging.GetLogEntries", params, this, "logsReply");
}

void NewLogsModel::logsReply(int commandId, const QVariantMap &data)
{

    QList<NewLogEntry*> entries;
    foreach (const QVariant &entryVariant, data.value("logEntries").toList()) {
        QVariantMap map = entryVariant.toMap();
        QString source = map.value("source").toString();
        QDateTime timestamp = QDateTime::fromMSecsSinceEpoch(map.value("timestamp").toULongLong());
        QVariantMap values = map.value("values").toMap();
        NewLogEntry *entry = new NewLogEntry(source, timestamp, values, this);
        entries.append(entry);
    }

    m_canFetchMore = entries.count() >= m_blockSize;
    qCDebug(dcLogEngine()) << "Logs received:" << entries.count() << "Requested:" << m_blockSize;

    if (!entries.isEmpty()) {
        qCDebug(dcLogEngine()) << "Logs received:" << entries.first()->timestamp().toString() << " - " << entries.last()->timestamp().toString();
        if (m_list.isEmpty()) {
            qCDebug(dcLogEngine()) << "Inserting into emptry model";
            beginInsertRows(QModelIndex(), 0, entries.count() - 1);
            m_list.append(entries);
            endInsertRows();
            emit entriesAdded(0, entries);

        } else if (entries.last()->timestamp() == m_list.last()->timestamp()) {
            qCDebug(dcLogEngine()) << "First item of new list already existing... no new data...";
            qDeleteAll(entries);

        } else if (entries.last()->timestamp() < m_list.last()->timestamp()) {
            if (entries.first()->timestamp() == m_list.last()->timestamp()) {
                qCDebug(dcLogEngine()) << "Appending received items";
                beginRemoveRows(QModelIndex(), m_list.count() - 1, m_list.count() - 1);
                m_list.takeLast()->deleteLater();
                endRemoveRows();
                emit entriesRemoved(m_list.count(), 1);

                int insertIdx = m_list.count();
                beginInsertRows(QModelIndex(), insertIdx, insertIdx + entries.count() - 1);
                m_list = m_list + entries;
                endInsertRows();
                emit entriesAdded(insertIdx, entries);
            } else {
                // Start of fetched entries does not line up with end of existing entries. Discarding existing entries
                qCDebug(dcLogEngine()) << "Start of fetched entries does not line up with end of existing entries. Discarding existing entries" << entries.first()->timestamp().toString() << " - " << m_list.last()->timestamp().toString();
                clear();

                // If the mismatch is in the visible area, we'll discard everything and fetch again
                // Else if the mismatch is outside the visible area, we'll just discard the old data and work with what we received
                if ((entries.first()->timestamp() >= m_endTime && entries.last()->timestamp() >= m_endTime)
                        || (entries.first()->timestamp() <= m_startTime && entries.last()->timestamp() <= m_endTime)) {
                    clear();
                    beginInsertRows(QModelIndex(), 0, entries.count() - 1);
                    m_list.append(entries);
                    endInsertRows();
                    emit entriesAdded(0, entries);
                } else {
                    clear();
                    fetchLogs();
                }
            }

        } else if (entries.last()->timestamp() == m_list.first()->timestamp()) {
            beginRemoveRows(QModelIndex(), 0, 0);
            m_list.takeAt(0)->deleteLater();
            endRemoveRows();
            emit entriesRemoved(0, 1);
            qCDebug(dcLogEngine()) << "Prepending received items";
            beginInsertRows(QModelIndex(), 0, entries.count() - 1);
            m_list = entries + m_list;
            endInsertRows();
            emit entriesAdded(0, entries);

        } else {
            // End of fetched entries does not line up with start of existing entries. Discarding existing entries
            qCDebug(dcLogEngine()) << "End of fetched entries does not line up with start of existing entries" << m_list.last()->timestamp().toString() << " - " << m_list.first()->timestamp().toString();
            clear();
            beginInsertRows(QModelIndex(), 0, entries.count() - 1);
            m_list.append(entries);
            endInsertRows();
            emit entriesAdded(0, entries);
        }
    }

    emit countChanged();
}

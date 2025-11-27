#include "newlogsmodel.h"

#include "engine.h"
#include "logmanager.h"

#include "logging.h"
//NYMEA_LOGGING_CATEGORY(dcLogEngine, "LogEngine")
Q_DECLARE_LOGGING_CATEGORY(dcLogEngine)

#include <QJsonDocument>
#include <QMetaEnum>

NewLogsModel::NewLogsModel(QObject *parent)
    : QAbstractListModel{parent}
{
    // Workaround for older Qt versions (5.12 and older) which can't deal with the QList<EnergyLogEntry*> argument
    connect(this, &NewLogsModel::entriesAdded, this, [this](int index, const QList<NewLogEntry*> &entries){
        emit entriesAddedIdx(index, entries.count());
    });

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
    // Cannot fetchMore when there are multiple sources as paging doesn't really work in that case
    return m_canFetchMore && (m_sources.count() == 1 || m_list.isEmpty());
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
    if (m_engine == engine) {
        return;
    }

    if (m_engine) {
        disconnect(m_engine->logManager(), &LogManager::logEntryReceived, this, &NewLogsModel::newLogEntryReceived);
    }

    m_engine = engine;
    emit engineChanged();

    if (m_engine) {
        connect(m_engine->logManager(), &LogManager::logEntryReceived, this, &NewLogsModel::newLogEntryReceived);
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

Qt::SortOrder NewLogsModel::sortOrder() const
{
    return m_sortOrder;
}

void NewLogsModel::setSortOrder(Qt::SortOrder sortOrder)
{
    if (m_sortOrder != sortOrder) {
        m_sortOrder = sortOrder;
        emit sortOrderChanged();
    }
}

bool NewLogsModel::busy() const
{
    return m_busy;
}

bool NewLogsModel::live() const
{
    return m_live;
}

void NewLogsModel::setLive(bool live)
{
    if (m_live != live) {
        m_live = live;
        emit liveChanged();
    }
}

int NewLogsModel::fetchBlockSize() const
{
    return m_blockSize;
}

void NewLogsModel::setFetchBlockSize(int fetchBlockSize)
{
    if (m_blockSize != fetchBlockSize) {
        m_blockSize = fetchBlockSize;
        emit fetchBlockSizeChanged();
    }
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
        if (m_sortOrder == Qt::AscendingOrder) {
            if (entry->timestamp() > timestamp) {
//                qCDebug(dcLogEngine()) << "entry is newer than searched:" << entry->timestamp().toString() << timestamp.toString();
                if (idx == 0) {
//                    qCDebug(dcLogEngine()) << "Is oldest.";
                    return entry;
                }
                NewLogEntry *previousEntry = m_list.at(idx-1);
                if (previousEntry->timestamp() < timestamp) {
                    qint64 previousDiff = timestamp.msecsTo(previousEntry->timestamp());
//                    qCDebug(dcLogEngine()) << "time between this and previous:" << entry->timestamp().toString() << previousEntry->timestamp().toString() << (qAbs(previousDiff) < qAbs(diff) ? "next" : "this");
                    return qAbs(previousDiff) < qAbs(diff) ? previousEntry : entry;
                }
                idx -= jump;
            } else if (entry->timestamp() < timestamp) {
//                qCDebug(dcLogEngine()) << "entry is older than searched:" << entry->timestamp().toString() << timestamp.toString();
                if (idx == m_list.count() - 1) {
//                    qCDebug(dcLogEngine()) << "Is newest.";
                    return entry;
                }
                NewLogEntry *nextEntry = m_list.at(idx+1);
                if (nextEntry->timestamp() > timestamp) {
                    qint64 nextDiff = timestamp.msecsTo(nextEntry->timestamp());
//                    qCDebug(dcLogEngine()) << "time between next and this:" << nextEntry->timestamp().toString() << "-" << entry->timestamp().toString()  << (qAbs(nextDiff) > qAbs(diff) ? "prev" : "this");
                    return qAbs(nextDiff) < qAbs(diff) ? nextEntry : entry;
                }
                idx += jump;
            }
        } else {
            if (entry->timestamp() > timestamp) {
//                qCDebug(dcLogEngine()) << "entry is newer than searched:" << entry->timestamp().toString() << timestamp.toString();
                if (idx == m_list.count() - 1) {
//                    qCDebug(dcLogEngine()) << "Is newest.";
                    return entry;
                }
                NewLogEntry *previousEntry = m_list.at(idx+1);
//                qCDebug(dcLogEngine) << "previous:" << previousEntry->timestamp().toString();
                if (previousEntry->timestamp() < timestamp) {
                    qint64 previousDiff = timestamp.msecsTo(previousEntry->timestamp());
//                    qCDebug(dcLogEngine()) << "time between previous and this:" << previousEntry->timestamp().toString() << entry->timestamp().toString() << previousDiff;
                    return qAbs(previousDiff) < qAbs(diff) ? previousEntry : entry;
                }
                idx += jump;
            } else if (entry->timestamp() < timestamp) {
//                qCDebug(dcLogEngine()) << "entry is older than searched:" << entry->timestamp().toString() << timestamp.toString();
                if (idx == 0) {
//                    qCDebug(dcLogEngine()) << "Is oldest.";
                    return entry;
                }
                NewLogEntry *nextEntry = m_list.at(idx-1);
//                qCDebug(dcLogEngine) << "next:" << nextEntry;
                if (nextEntry->timestamp() > timestamp) {
                    qint64 nextDiff = timestamp.msecsTo(nextEntry->timestamp());
//                    qCDebug(dcLogEngine()) << "time between this and next:" << entry->timestamp().toString() << nextEntry->timestamp().toString() << nextDiff;
                    return qAbs(nextDiff) < qAbs(diff) ? nextEntry : entry;
                }
                idx -= jump;
            }
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
    m_currentNewest = QDateTime();
    m_lastOffset = 0;
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


    if (m_sampleRate == SampleRateAny) { // Discrete logs

        if (!m_startTime.isNull() && !m_endTime.isNull()) { // Either specific time frame
            params.insert("startTime", m_startTime.toMSecsSinceEpoch());
            params.insert("endTime", m_endTime.toMSecsSinceEpoch());

        } else {
            params.insert("limit", m_blockSize);
            if (m_list.count() > 0) {
                if (m_currentNewest.isNull()) {
                    m_currentNewest = QDateTime::currentDateTime();
                }
                params.insert("offset", m_lastOffset);
                params.insert("endTime", m_currentNewest.toMSecsSinceEpoch());
            }
            m_lastOffset += m_blockSize;
        }

    } else {
        if (!m_startTime.isNull() && !m_endTime.isNull()) {
            params.insert("startTime", m_startTime.toMSecsSinceEpoch());
            params.insert("endTime", m_endTime.toMSecsSinceEpoch());

            QMetaEnum sampleRateEnum = QMetaEnum::fromType<SampleRate>();
            params.insert("sampleRate", sampleRateEnum.valueToKey(m_sampleRate));
        } else {
            qCWarning(dcLogEngine()) << "startTime and endTime is required when asking for resampling";
            return;
        }
    }

    QMetaEnum sortOrderEnum = QMetaEnum::fromType<Qt::SortOrder>();
    params.insert("sortOrder", sortOrderEnum.valueToKey(m_sortOrder));

    qCDebug(dcLogEngine()) << "Fetching logs:" << QJsonDocument::fromVariant(params).toJson();
    m_engine->jsonRpcClient()->sendCommand("Logging.GetLogEntries", params, this, "logsReply");

    m_busy = true;
    emit busyChanged();
}

void NewLogsModel::logsReply(int commandId, const QVariantMap &data)
{
    Q_UNUSED(commandId)

    m_busy = false;
    emit busyChanged();

    QList<NewLogEntry*> entries;
    foreach (const QVariant &entryVariant, data.value("logEntries").toList()) {
        QVariantMap map = entryVariant.toMap();
        QString source = map.value("source").toString();
        QDateTime timestamp = QDateTime::fromMSecsSinceEpoch(map.value("timestamp").toULongLong());
        QVariantMap values = map.value("values").toMap();
        NewLogEntry *entry = new NewLogEntry(source, timestamp, values, this);
        entries.append(entry);
        qCDebug(dcLogEngine()) << "Log entry:" << entry->timestamp() << entry->values();;
    }

    m_canFetchMore = entries.count() >= m_blockSize;
    qCDebug(dcLogEngine()) << "Logs received:" << entries.count();

    if (!m_startTime.isNull() && !m_endTime.isNull()) {
        beginResetModel();
        QList<NewLogEntry*> oldEntries = m_list;
        m_list.clear();
        endResetModel();
        emit entriesRemoved(0, oldEntries.count());
        qDeleteAll(oldEntries);

        if (!entries.isEmpty()) {
            beginInsertRows(QModelIndex(), 0, entries.count() - 1);
            m_list = entries;
            endInsertRows();
        }
        emit entriesAdded(0, entries);
        emit countChanged();

    } else {
        if (!entries.isEmpty()) {
            beginInsertRows(QModelIndex(), m_list.count(), m_list.count() + entries.count() - 1);
            qSort(entries.begin(), entries.end(), [](NewLogEntry *left, NewLogEntry *right){
                return left->timestamp() > right->timestamp();
            });
            m_list.append(entries);
            endInsertRows();
        }
        emit entriesAdded(m_list.count() - entries.count(), entries);
        emit countChanged();
    }

}

void NewLogsModel::newLogEntryReceived(const QVariantMap &map)
{
    QString source = map.value("source").toString();
    QDateTime timestamp = QDateTime::fromMSecsSinceEpoch(map.value("timestamp").toULongLong());
    QVariantMap values = map.value("values").toMap();


    if (m_sources.contains(source) && m_sampleRate == SampleRateAny) {
        qCritical() << "New entry!" << m_sources << source << m_sampleRate;
        NewLogEntry *entry = new NewLogEntry(source, timestamp, values, this);
        if (m_sortOrder == Qt::DescendingOrder) {
            beginInsertRows(QModelIndex(), 0, 0);
            m_list.prepend(entry);
            endInsertRows();
            emit entriesAdded(0, {entry});
        } else {
            beginInsertRows(QModelIndex(), m_list.count(), m_list.count());
            m_list.append(entry);
            endInsertRows();
            emit entriesAdded(m_list.count() - 1, {entry});
        }
        emit countChanged();
    }
}

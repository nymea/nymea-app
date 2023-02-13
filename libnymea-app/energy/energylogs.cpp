#include "energylogs.h"

#include <QMetaEnum>
#include <QJsonDocument>

#include "logging.h"
NYMEA_LOGGING_CATEGORY(dcEnergyLogs, "EnergyLogs")


EnergyLogEntry::EnergyLogEntry(QObject *parent): QObject(parent)
{
}

EnergyLogEntry::EnergyLogEntry(const QDateTime &timestamp, QObject *parent):
    QObject(parent),
    m_timestamp(timestamp)
{

}

QDateTime EnergyLogEntry::timestamp() const
{
    return m_timestamp;
}

EnergyLogs::EnergyLogs(QObject *parent) : QAbstractListModel(parent)
{
    // Workaround for older Qt versions (5.12 and older) which can't deal with the QList<EnergyLogEntry*> argument
    connect(this, &EnergyLogs::entriesAdded, this, [this](int index, const QList<EnergyLogEntry*> &entries){
        emit entriesAddedIdx(index, entries.count());
    });
}

EnergyLogs::~EnergyLogs()
{
    if (m_engine) {
        m_engine->jsonRpcClient()->unregisterNotificationHandler(this);
    }
}

Engine *EnergyLogs::engine() const
{
    return m_engine;
}

void EnergyLogs::setEngine(Engine *engine)
{
    if (m_engine != engine) {
        m_engine = engine;
        emit engineChanged();

        if (!m_engine) {
            return;
        }

        connect(engine, &Engine::destroyed, this, [=](){
            if (engine == m_engine) {
                m_engine = nullptr;
                emit engineChanged();
            }
        });

        if (m_engine->jsonRpcClient()->experiences().value("Energy").toString() >= "1.0") {
            m_engine->jsonRpcClient()->registerNotificationHandler(this, "Energy", "notificationReceivedInternal");

//            if (m_ready && !m_loadingInhibited) {
//                fetchLogs();
//            }
        }
    }
}

EnergyLogs::SampleRate EnergyLogs::sampleRate() const
{
    return m_sampleRate;
}

void EnergyLogs::setSampleRate(SampleRate sampleRate)
{
    if (m_sampleRate != sampleRate) {
        m_sampleRate = sampleRate;
        emit sampleRateChanged();
        clear();
    }
}

QDateTime EnergyLogs::startTime() const
{
    return m_startTime;
}

void EnergyLogs::setStartTime(const QDateTime &startTime)
{
    if (m_startTime != startTime) {
        m_startTime = startTime;
        emit startTimeChanged();
    }
}

QDateTime EnergyLogs::endTime() const
{
    return m_endTime;
}

void EnergyLogs::setEndTime(const QDateTime &endTime)
{
    if (m_endTime != endTime) {
        m_endTime = endTime;
        emit endTimeChanged();
    }
}

bool EnergyLogs::live() const
{
    return m_live;
}

void EnergyLogs::setLive(bool live)
{
    if (m_live != live) {
        m_live = live;
        emit liveChanged();
    }
}

bool EnergyLogs::fetchingData() const
{
    return m_fetchingData;
}

bool EnergyLogs::loadingInhibited() const
{
    return m_loadingInhibited;
}

void EnergyLogs::setLoadingInhibited(bool loadingInhibited)
{
    if (m_loadingInhibited != loadingInhibited) {
        m_loadingInhibited = loadingInhibited;
        emit loadingInhibitedChanged();

//        if (!m_loadingInhibited) {
//            fetchLogs();
//        }
    }
}

void EnergyLogs::classBegin()
{

}

void EnergyLogs::componentComplete()
{
    m_ready = true;
//    fetchLogs();
}

int EnergyLogs::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return m_list.count();
}

QVariant EnergyLogs::data(const QModelIndex &index, int role) const
{
    Q_UNUSED(index)
    Q_UNUSED(role)
    return QVariant();
}

double EnergyLogs::minValue() const
{
    return m_minValue;
}

double EnergyLogs::maxValue() const
{
    return m_maxValue;
}

EnergyLogEntry *EnergyLogs::get(int index) const
{
    if (index < 0 || index >= m_list.count()) {
        return nullptr;
    }
    return m_list.at(index);
}

int EnergyLogs::indexOf(const QDateTime &timestamp)
{
    if (m_list.isEmpty()) {
        return -1;
    }
    QDateTime first = m_list.first()->timestamp();

    int index = qRound(1.0 * first.secsTo(timestamp) / (m_sampleRate * 60));
    if (index < 0 || index >= m_list.count()) {
        qCDebug(dcEnergyLogs()) << "finding:" << timestamp << index << first.toString() << "NOT FOUND" << m_list.last()->timestamp() << m_list.count();
        return -1;
    }
    qCDebug(dcEnergyLogs()) << "finding:" << timestamp << index << first.toString() << m_list.at(index)->timestamp();


    // Normally, if the DB is in a consistent state, we can rely that the above finds the correct entry.
    // However, if the user changes the timezone, during the lifetime, or other woes may appear like NTP
    // changing time which may cause inconsistent entries like passing the same time twice, we could end up
    // off by one. In order to compensate for that, we'll see if the next or previous entries may be closer
    // In theory we could even be off by some more samples in very rare circumstances, but unlikely enough
    // to not bother with that at this point.
    QDateTime found = m_list.at(index)->timestamp();
    QDateTime previous = index > 0 ? m_list.at(index-1)->timestamp() : found;
    QDateTime next = index < m_list.count() - 1 ? m_list.at(index+1)->timestamp() : found;

    int diffToFound = qAbs(timestamp.secsTo(found));
    int diffToPrevious = qAbs(timestamp.secsTo(previous));
    int diffToNext = qAbs(timestamp.secsTo(next));
    if (diffToPrevious < diffToFound && diffToPrevious < diffToNext) {
//        qWarning() << "Correcting to previous" << index << m_list.count() << found << previous << diffToPrevious << diffToFound;
        return index - 1;
    }
    if (diffToNext < diffToFound) {
//        qWarning() << "Correcting to next" << index << m_list.count() << found << next << diffToNext << diffToFound;
        return index + 1;
    }
    return index;
}

EnergyLogEntry *EnergyLogs::find(const QDateTime &timestamp)
{
    int index = indexOf(timestamp);
    if (index < 0) {
        return nullptr;
    }
    return m_list.at(index);
}

QList<EnergyLogEntry *> EnergyLogs::entries() const
{
    return m_list;
}

void EnergyLogs::appendEntry(EnergyLogEntry *entry, double minValue, double maxValue)
{
    entry->setParent(this);
    int index = m_list.count();
    beginInsertRows(QModelIndex(), index, index);
    m_list.append(entry);
    endInsertRows();
    emit countChanged();
    emit entryAdded(index, entry);
    emit entriesAdded(index, {entry});
    if (minValue < m_minValue) {
        m_minValue = minValue;
        emit minValueChanged();
    }
    if (maxValue > m_maxValue) {
        m_maxValue = maxValue;
        emit maxValueChanged();
    }
}

void EnergyLogs::appendEntries(const QList<EnergyLogEntry *> &entries)
{
    int index = m_list.count();
    beginInsertRows(QModelIndex(), index, index + entries.count());
    for (int i = 0; i < entries.count(); i++) {
        EnergyLogEntry* entry = entries.at(i);
        entry->setParent(this);
        m_list.append(entry);
        emit entryAdded(index + i, entry);
    }
    endInsertRows();
    emit entriesAdded(index, entries);
    emit countChanged();
}

QVariantMap EnergyLogs::fetchParams() const
{
    return QVariantMap();
}

void EnergyLogs::getLogsResponse(int commandId, const QVariantMap &params)
{
    Q_UNUSED(commandId)

    double minValue = 0, maxValue = 0;
    qCDebug(dcEnergyLogs()) << "Logs response:" << qUtf8Printable(QJsonDocument::fromVariant(params).toJson());
    QList<EnergyLogEntry*> entries = unpackEntries(params, &minValue, &maxValue);
    qCDebug(dcEnergyLogs()) << "Energy logs received" << entries.count();

    if (!entries.isEmpty()) {
        if (m_list.isEmpty()) {
//            qCDebug(dcEnergyLogs()) << "Energy logs received" << qUtf8Printable(QJsonDocument::fromVariant(params).toJson());
            beginInsertRows(QModelIndex(), 0, entries.count());
            m_list.append(entries);
            endInsertRows();
            emit entriesAdded(0, entries);
            m_minValue = minValue;
            emit minValueChanged();
            m_maxValue = maxValue;
            emit maxValueChanged();

        } else if (entries.first()->timestamp() < m_list.first()->timestamp()) {

            if (entries.last()->timestamp().addSecs(m_sampleRate * 60) == m_list.first()->timestamp()) {
                beginInsertRows(QModelIndex(), 0, entries.count());
                m_list = entries + m_list;
                endInsertRows();
                emit entriesAdded(0, entries);
                if (minValue < m_minValue) {
                    m_minValue = minValue;
                    emit minValueChanged();
                }
                if (maxValue > m_maxValue) {
                    m_maxValue = maxValue;
                    emit maxValueChanged();
                }
            } else {
                // End of fetched entries does not line up with start of existing entries. Discarding existing entries
                qCDebug(dcEnergyLogs()) << "End of fetched entrie does not line up with start of existing entries. Discarding existing entries" << entries.last()->timestamp().addSecs(m_sampleRate * 60).toString() << " - " << m_list.first()->timestamp().toString();
                clear();

                // If the mismatch is in the visible area, we'll discard everything and fetch again
                // Else if the mismatch is outside the visible area, we'll just discard the old data and work with what we received
                if (entries.first()->timestamp() <= m_startTime && entries.last()->timestamp() >= m_endTime) {
                    beginInsertRows(QModelIndex(), 0, entries.count());
                    m_list.append(entries);
                    endInsertRows();
                    emit entriesAdded(0, entries);
                    m_minValue = minValue;
                    emit minValueChanged();
                    m_maxValue = maxValue;
                    emit maxValueChanged();
                } else {
                    qDeleteAll(entries);
                    fetchLogs();
                }
            }

        } else if (entries.first()->timestamp().addSecs(-m_sampleRate * 60) == m_list.last()->timestamp()) {
            int index = m_list.count();
            beginInsertRows(QModelIndex(), m_list.count(), m_list.count() + entries.count());
            m_list.append(entries);
            endInsertRows();
            emit entriesAdded(index, entries);
            if (minValue < m_minValue) {
                m_minValue = minValue;
                emit minValueChanged();
            }
            if (maxValue > m_maxValue) {
                m_maxValue = maxValue;
                emit maxValueChanged();
            }
        } else {
            // Start of fetched entries does not line up with end of existing entries. Discarding existing entries
            clear();
            beginInsertRows(QModelIndex(), 0, entries.count());
            m_list.append(entries);
            endInsertRows();
            emit entriesAdded(0, entries);
            m_minValue = minValue;
            emit minValueChanged();
            m_maxValue = maxValue;
            emit maxValueChanged();
        }

    } else {
        qCDebug(dcEnergyLogs()) << "Received empty log entries set.";
    }

    m_fetchingData = false;

    if (m_fetchAgain) {
        qCDebug(dcEnergyLogs()) << "Fetching again...";
        m_fetchAgain = false;
        fetchLogs();
    } else {
        emit fetchingDataChanged();
    }
}

void EnergyLogs::notificationReceivedInternal(const QVariantMap &data)
{

    if (!m_live) {
        return;
    }

    if (!data.value("notification").toString().contains("Log")) {
        return;
    }

    notificationReceived(data);
}

void EnergyLogs::clear()
{
    int count = m_list.count();
    beginResetModel();
    qDeleteAll(m_list);
    m_list.clear();
    endResetModel();
    emit countChanged();
    emit entriesRemoved(0, count);
    m_minValue = 0;
    emit minValueChanged();
    m_maxValue = 0;
    emit maxValueChanged();
}

void EnergyLogs::fetchLogs()
{
    if (m_loadingInhibited || !m_ready || !m_engine || m_engine->jsonRpcClient()->experiences().value("Energy").toString() < "1.0") {
        return;
    }

    if (m_fetchingData) {
        qCDebug(dcEnergyLogs()) << "Already busy.. queing up call";
        m_fetchAgain = true;
        return;
    }

    QVariantMap params = fetchParams();
    QMetaEnum metaEnum = QMetaEnum::fromType<SampleRate>();
    params.insert("sampleRate", metaEnum.valueToKey(m_sampleRate));

    if (!m_startTime.isNull() && !m_endTime.isNull()) {
        QDateTime startTime;
        QDateTime endTime;

        QDateTime oldestExisting = m_list.count() > 0 ? m_list.first()->timestamp() : QDateTime();
        QDateTime newestExisting = m_list.count() > 0 ? m_list.last()->timestamp() : QDateTime();
        qCDebug(dcEnergyLogs()) << "request timeframe: " << m_startTime.toString() << " - " << m_endTime.toString();
        qCDebug(dcEnergyLogs()) << "existing timeframe:" << oldestExisting.toString() << "- " << newestExisting.toString();

        if (oldestExisting.isNull() || newestExisting.isNull()) {
            startTime = m_startTime;
            endTime = m_endTime;
        } else {

            if (m_startTime < oldestExisting) {
                startTime = m_startTime;
                endTime = qMin(m_endTime, oldestExisting.addSecs(-m_sampleRate * 60));
            } else if (newestExisting < m_endTime) {
                startTime = qMax(m_startTime, newestExisting.addSecs(m_sampleRate * 60));
                endTime = m_endTime;
            } else {
                // Nothing to do...
                return;
            }
        }

        params.insert("from", startTime.toSecsSinceEpoch());
        params.insert("to", endTime.toSecsSinceEpoch());
        qCDebug(dcEnergyLogs()) << "Fetching from" << startTime.toString() << "to" << endTime.toString() << "with sample rate" << m_sampleRate;
    }

    m_fetchingData = true;
    fetchingDataChanged();

    qCDebug(dcEnergyLogs()) << "Fetching energy logs:" << qUtf8Printable(QJsonDocument::fromVariant(params).toJson());
    m_engine->jsonRpcClient()->sendCommand("Energy.Get" + logsName(), params, this, "getLogsResponse");
}


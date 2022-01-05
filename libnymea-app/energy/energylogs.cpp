#include "energylogs.h"

#include <QMetaEnum>

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
        if (m_engine->jsonRpcClient()->experiences().value("Energy").toString() >= "1.0") {
            m_engine->jsonRpcClient()->registerNotificationHandler(this, "Energy", "notificationReceivedInternal");

            connect(engine, &Engine::destroyed, this, [=](){
                if (engine == m_engine) {
                    m_engine = nullptr;
                    emit engineChanged();
                }
            });

            if (m_ready && !m_loadingInhibited) {
                fetchLogs();
            }
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

        fetchLogs();
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

        if (!m_loadingInhibited) {
            fetchLogs();
        }
    }
}

void EnergyLogs::classBegin()
{

}

void EnergyLogs::componentComplete()
{
    m_ready = true;
    fetchLogs();
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

EnergyLogEntry *EnergyLogs::get(int index) const
{
    if (index < 0 || index >= m_list.count()) {
        return nullptr;
    }
    return m_list.at(index);
}

void EnergyLogs::appendEntry(EnergyLogEntry *entry)
{
    entry->setParent(this);
    beginInsertRows(QModelIndex(), m_list.count(), m_list.count());
    m_list.append(entry);
    endInsertRows();
    emit countChanged();
    emit entryAdded(entry);
    emit entriesAdded({entry});
}

void EnergyLogs::appendEntries(const QList<EnergyLogEntry *> &entries)
{
    beginInsertRows(QModelIndex(), m_list.count(), m_list.count() + entries.count());
    foreach (EnergyLogEntry* entry, entries) {
        entry->setParent(this);
        m_list.append(entry);
        emit entryAdded(entry);
    }
    endInsertRows();
    emit entriesAdded(entries);
    emit countChanged();
}

QVariantMap EnergyLogs::fetchParams() const
{
    return QVariantMap();
}

void EnergyLogs::getLogsResponse(int commandId, const QVariantMap &params)
{
    Q_UNUSED(commandId)
    if (!m_list.isEmpty()) {
        beginResetModel();
        qDeleteAll(m_list);
        m_list.clear();
        endResetModel();
    }
    qCDebug(dcEnergyLogs()) << "Energy logs received";
//    qCDebug(dcEnergyLogs()) << "Energy logs:" << params;
    logEntriesReceived(params);

    m_fetchingData = false;
    emit fetchingDataChanged();
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

void EnergyLogs::fetchLogs()
{
    if (m_loadingInhibited || !m_ready || !m_engine || m_engine->jsonRpcClient()->experiences().value("Energy").toString() < "1.0") {
        return;
    }

    if (!m_list.isEmpty()) {
        beginResetModel();
        qDeleteAll(m_list);
        m_list.clear();
        endResetModel();
    }

    m_fetchingData = true;
    fetchingDataChanged();

    QVariantMap params = fetchParams();
    QMetaEnum metaEnum = QMetaEnum::fromType<SampleRate>();
    params.insert("sampleRate", metaEnum.valueToKey(m_sampleRate));
    if (!m_startTime.isNull()) {
        params.insert("from", m_startTime.toSecsSinceEpoch());
    }
    if (!m_endTime.isNull()) {
        params.insert("to", m_endTime.toSecsSinceEpoch());
    }
    qCDebug(dcEnergyLogs()) << "Fetching energy logs" << params;
    m_engine->jsonRpcClient()->sendCommand("Energy.Get" + logsName(), params, this, "getLogsResponse");
}


#include "thingpowerlogs.h"

#include <QMetaEnum>

#include <QLoggingCategory>
Q_DECLARE_LOGGING_CATEGORY(dcEnergyLogs)

ThingPowerLogEntry::ThingPowerLogEntry(QObject *parent):
    EnergyLogEntry(parent)
{
}

ThingPowerLogEntry::ThingPowerLogEntry(const QDateTime &timestamp, const QUuid &thingId, double currentPower, double totalConsumption, double totalProduction, QObject *parent):
    EnergyLogEntry(timestamp, parent),
    m_thingId(thingId),
    m_currentPower(currentPower),
    m_totalConsumption(totalConsumption),
    m_totalProduction(totalProduction)
{

}

QUuid ThingPowerLogEntry::thingId() const
{
    return m_thingId;
}

double ThingPowerLogEntry::currentPower() const
{
    return m_currentPower;
}

double ThingPowerLogEntry::totalConsumption() const
{
    return m_totalConsumption;
}

double ThingPowerLogEntry::totalProduction() const
{
    return m_totalProduction;
}

ThingPowerLogs::ThingPowerLogs(QObject *parent) : EnergyLogs(parent)
{
}

QUuid ThingPowerLogs::thingId() const
{
    return m_thingId;
}

void ThingPowerLogs::setThingId(const QUuid &thingId)
{
    if (m_thingId != thingId) {
        m_thingId = thingId;
        emit thingIdChanged();
        if (m_loader) {
            m_loader->addThingId(thingId);
        }
    }
}

ThingPowerLogsLoader *ThingPowerLogs::loader() const
{
    return m_loader;
}

void ThingPowerLogs::setLoader(ThingPowerLogsLoader *loader)
{
    if (m_loader != loader) {
        m_loader = loader;
        emit loaderChanged();

        loader->addThingId(m_thingId);
        connect(loader, &ThingPowerLogsLoader::fetched, this, [=](int commandId, const QVariantMap &params){
            qCDebug(dcEnergyLogs()) << "Loader fetched data.";
            getLogsResponse(commandId, params);
        });
    }
}

ThingPowerLogEntry *ThingPowerLogs::liveEntry()
{
    return m_liveEntry;
}

void ThingPowerLogs::addEntries(const QList<ThingPowerLogEntry *> &entries)
{
    QList<EnergyLogEntry*> energyLogEntries;
    foreach (ThingPowerLogEntry* entry, entries) {
        energyLogEntries.append(entry);
    }
    appendEntries(energyLogEntries);
}

ThingPowerLogEntry *ThingPowerLogs::unpack(const QVariantMap &map)
{
    QDateTime timestamp = QDateTime::fromSecsSinceEpoch(map.value("timestamp").toLongLong());
    QUuid thingId = map.value("thingId").toUuid();
    double currentPower = map.value("currentPower").toDouble();
    double totalConsumption = map.value("totalConsumption").toDouble();
    double totalProduction = map.value("totalProduction").toDouble();
    return new ThingPowerLogEntry(timestamp, thingId, currentPower, totalConsumption, totalProduction, this);
}

QString ThingPowerLogs::logsName() const
{
    return "ThingPowerLogs";
}

QVariantMap ThingPowerLogs::fetchParams() const
{
    QVariantMap ret;
    ret.insert("thingIds", QVariantList{m_thingId});
    ret.insert("includeCurrent", true);
    return ret;
}

QList<EnergyLogEntry *> ThingPowerLogs::unpackEntries(const QVariantMap &params, double *minValue, double *maxValue)
{
    foreach (const QVariant &variant, params.value("currentEntries").toList()) {
        QVariantMap map = variant.toMap();
        if (map.value("thingId").toUuid() != m_thingId) {
            continue;
        }
        if (m_liveEntry) {
            m_liveEntry->deleteLater();
        }
        m_liveEntry = unpack(map);
        emit liveEntryChanged(m_liveEntry);
        break;
    }

    QList<EnergyLogEntry*> ret;
    foreach (const QVariant &variant, params.value("thingPowerLogEntries").toList()) {
        QVariantMap map = variant.toMap();
        if (map.value("thingId").toUuid() != m_thingId) {
            continue;
        }
        QDateTime timestamp = QDateTime::fromSecsSinceEpoch(map.value("timestamp").toLongLong());
        QUuid thingId = map.value("thingId").toUuid();
        double currentPower = map.value("currentPower").toDouble();
        double totalConsumption = map.value("totalConsumption").toDouble();
        double totalProduction = map.value("totalProduction").toDouble();
        ThingPowerLogEntry *entry = new ThingPowerLogEntry(timestamp, thingId, currentPower, totalConsumption, totalProduction, this);
//        qWarning() << "Adding entry:" << entry->thingId() << entry->timestamp().toString() << entry->totalConsumption();

        *minValue = qMin(*minValue, currentPower);
        *maxValue = qMax(*maxValue, currentPower);

        ret.append(entry);
    }

    return ret;
}

void ThingPowerLogs::notificationReceived(const QVariantMap &data)
{
    QString notification = data.value("notification").toString();
    QVariantMap params = data.value("params").toMap();

    QMetaEnum sampleRateEnum = QMetaEnum::fromType<EnergyLogs::SampleRate>();
    SampleRate sampleRate = static_cast<SampleRate>(sampleRateEnum.keyToValue(data.value("params").toMap().value("sampleRate").toByteArray()));
    QVariantMap entryMap = params.value("thingPowerLogEntry").toMap();
    QUuid thingId = entryMap.value("thingId").toUuid();

    if (m_thingId != thingId) {
        // Not watching this thing...
        return;
    }

    if (sampleRate != this->sampleRate()) {
        return;
    }

    // We'll use 1 Min samples in any case for the live value
    if (sampleRate == EnergyLogs::SampleRate1Min) {
        ThingPowerLogEntry *liveEntry = unpack(params.value("thingPowerLogEntry").toMap());
        if (m_liveEntry) {
            m_liveEntry->deleteLater();
        }
        m_liveEntry = liveEntry;
        emit liveEntryChanged(liveEntry);
    }

    if (notification == "Energy.ThingPowerLogEntryAdded") {
        QVariantMap map = params.value("thingPowerLogEntry").toMap();
        QDateTime timestamp = QDateTime::fromSecsSinceEpoch(map.value("timestamp").toLongLong());
        QUuid thingId = map.value("thingId").toUuid();
        double currentPower = map.value("currentPower").toDouble();
        double totalConsumption = map.value("totalConsumption").toDouble();
        double totalProduction = map.value("totalProduction").toDouble();
        ThingPowerLogEntry *entry = new ThingPowerLogEntry(timestamp, thingId, currentPower, totalConsumption, totalProduction, this);
        appendEntry(entry, currentPower, currentPower);
    }
}


ThingPowerLogsLoader::ThingPowerLogsLoader(QObject *parent):
    QObject(parent)
{

}

Engine *ThingPowerLogsLoader::engine() const
{
    return m_engine;
}

void ThingPowerLogsLoader::setEngine(Engine *engine)
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
    }
}

EnergyLogs::SampleRate ThingPowerLogsLoader::sampleRate() const
{
    return m_sampleRate;
}

void ThingPowerLogsLoader::setSampleRate(EnergyLogs::SampleRate sampleRate)
{
    if (m_sampleRate != sampleRate) {
        m_sampleRate = sampleRate;
        emit sampleRateChanged();

        m_lastStartTime = QDateTime();
        m_lastEndTime = QDateTime();
    }
}

QDateTime ThingPowerLogsLoader::startTime() const
{
    return m_startTime;
}

void ThingPowerLogsLoader::setStartTime(const QDateTime &startTime)
{
    if (m_startTime != startTime) {
        m_startTime = startTime;
        emit startTimeChanged();
    }
}

QDateTime ThingPowerLogsLoader::endTime() const
{
    return m_endTime;
}

void ThingPowerLogsLoader::setEndTime(const QDateTime &endTime)
{
    if (m_endTime != endTime) {
        m_endTime = endTime;
        emit endTimeChanged();
    }
}

bool ThingPowerLogsLoader::fetchingData() const
{
    return m_fetchingData;
}

void ThingPowerLogsLoader::addThingId(const QUuid &thingId)
{
    if (!m_thingIds.contains(thingId)) {
        m_thingIds.append(thingId);
    }
}

void ThingPowerLogsLoader::fetchLogs()
{
    if (!m_engine || m_engine->jsonRpcClient()->experiences().value("Energy").toString() < "1.0") {
        return;
    }

    if (m_fetchingData) {
        qCDebug(dcEnergyLogs()) << "Already busy.. queing up call";
        m_fetchAgain = true;
        return;
    }

    QVariantMap params;
    QVariantList thingIds;
    foreach (const QUuid &thingId, m_thingIds) {
        thingIds.append(thingId);
    }
    params.insert("thingIds", thingIds);
    params.insert("includeCurrent", true);

    QMetaEnum metaEnum = QMetaEnum::fromType<EnergyLogs::SampleRate>();
    params.insert("sampleRate", metaEnum.valueToKey(m_sampleRate));

    if (!m_startTime.isNull() && !m_endTime.isNull()) {
        QDateTime startTime;
        QDateTime endTime;
        if (m_lastStartTime.isNull() || m_lastEndTime.isNull()) {
            startTime = m_startTime;
            endTime = m_endTime;
            m_lastStartTime = m_startTime;
            m_lastEndTime = m_endTime;
        } else {
            if (m_startTime < m_lastStartTime) {
                startTime = m_startTime;
                endTime = m_lastStartTime;
                m_lastStartTime = m_startTime;
            } else if (m_lastEndTime < m_endTime) {
                startTime = m_lastEndTime;
                endTime = m_endTime;
                m_lastEndTime = m_endTime;
            } else {
                // Nothing to do...
                m_fetchingData = false;
                emit fetchingDataChanged();
                return;
            }

        }

        params.insert("from", startTime.toSecsSinceEpoch());
        params.insert("to", endTime.addSecs(-1).toSecsSinceEpoch());
        qCDebug(dcEnergyLogs()) << "Fetching from" << startTime.toString() << "to" << endTime.toString() << "with sample rate" << m_sampleRate;
    }

    m_fetchingData = true;
    fetchingDataChanged();

    m_engine->jsonRpcClient()->sendCommand("Energy.GetThingPowerLogs", params, this, "getLogsResponse");
}

void ThingPowerLogsLoader::getLogsResponse(int commandId, const QVariantMap &params)
{
    qCDebug(dcEnergyLogs()) << "Logs loader response!";
    emit fetched(commandId, params);

    m_fetchingData = false;

    if (m_fetchAgain) {
        m_fetchAgain = false;
        fetchLogs();
    } else {
        emit fetchingDataChanged();
    }
}

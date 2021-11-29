#include "thingpowerlogs.h"

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
    m_cacheTimer.setInterval(2000);
    connect(&m_cacheTimer, &QTimer::timeout, this, [=](){
        if (m_cachedEntries.count() > 0) {
            addEntries(m_cachedEntries);
            m_cachedEntries.clear();
        }
    });
}

QList<QUuid> ThingPowerLogs::thingIds() const
{
    return m_thingIds;
}

void ThingPowerLogs::setThingIds(const QList<QUuid> &thingIds)
{
    if (m_thingIds != thingIds) {
        m_thingIds = thingIds;
        emit thingIdsChanged();
    }
}

double ThingPowerLogs::minValue() const
{
    return m_minValue;
}

double ThingPowerLogs::maxValue() const
{
    return m_maxValue;
}

EnergyLogEntry *ThingPowerLogs::find(const QUuid &thingId, const QDateTime &timestamp)
{
    // TODO: Can we do a binary search even if they key we're looking for is not unique (but still sorted)?
    // For now, 365 * consumers items is the max we'll have here which seems on the edge for doing a stupid linear search...
//    qWarning() << "Finding item for" << thingId.toString() << timestamp.toString();
    for (int i = rowCount() - 1; i >= 0; i--) {
        ThingPowerLogEntry *entry = static_cast<ThingPowerLogEntry*>(get(i));
        if (entry->thingId() != thingId) {
            continue;
        }
//        qWarning() << "comparing" << entry->timestamp().toString();
        if (timestamp == entry->timestamp()) {
            return entry;
        }
        if (timestamp > entry->timestamp()) {
            return nullptr; // Giving up, entry is not here
        }
    }
    return nullptr;
}

void ThingPowerLogs::addEntry(ThingPowerLogEntry *entry)
{
    appendEntry(entry);
}

void ThingPowerLogs::addEntries(const QList<ThingPowerLogEntry *> &entries)
{
    QList<EnergyLogEntry*> energyLogEntries;
    foreach (ThingPowerLogEntry* entry, entries) {
        energyLogEntries.append(entry);
    }
    appendEntries(energyLogEntries);
}

QString ThingPowerLogs::logsName() const
{
    return "ThingPowerLogs";
}

QVariantMap ThingPowerLogs::fetchParams() const
{
    QVariantList thingIdsStrings;
    foreach (const QUuid &id, m_thingIds) {
        thingIdsStrings.append(id.toString());
    }
    QVariantMap ret;
    ret.insert("thingIds", thingIdsStrings);
    return ret;
}

void ThingPowerLogs::logEntriesReceived(const QVariantMap &params)
{
    // Grouping them so when the UI gets entriesAdded, the whole set for this timstamp will be available at once
    QList<ThingPowerLogEntry*> groupForTimestamp;
    foreach (const QVariant &variant, params.value("thingPowerLogEntries").toList()) {
        QVariantMap map = variant.toMap();
        QDateTime timestamp = QDateTime::fromSecsSinceEpoch(map.value("timestamp").toLongLong());
        QUuid thingId = map.value("thingId").toUuid();
        double currentPower = map.value("currentPower").toDouble();
        double totalConsumption = map.value("totalConsumption").toDouble();
        double totalProduction = map.value("totalProduction").toDouble();
        ThingPowerLogEntry *entry = new ThingPowerLogEntry(timestamp, thingId, currentPower, totalConsumption, totalProduction, this);
//        qWarning() << "Adding entry:" << entry->thingId() << entry->timestamp().toString() << entry->totalConsumption();

        if (groupForTimestamp.isEmpty()) {
            groupForTimestamp.append(entry);
        } else if (groupForTimestamp.first()->timestamp() == timestamp) {
            groupForTimestamp.append(entry);
        } else {
            // Finalize previous group and start a new one
            addEntries(groupForTimestamp);
            groupForTimestamp.clear();
            groupForTimestamp.append(entry);
        }
    }

    if (!groupForTimestamp.isEmpty()) {
        addEntries(groupForTimestamp);
    }
}

void ThingPowerLogs::notificationReceived(const QVariantMap &data)
{
    QString notification = data.value("notification").toString();
    QVariantMap params = data.value("params").toMap();
    if (notification == "Energy.ThingPowerLogEntryAdded") {
        QVariantMap map = params.value("thingPowerLogEntry").toMap();
        QDateTime timestamp = QDateTime::fromSecsSinceEpoch(map.value("timestamp").toLongLong());
        QUuid thingId = map.value("thingId").toUuid();
        if (!m_thingIds.isEmpty() && !m_thingIds.contains(thingId)) {
            return;
        }
        double currentPower = map.value("currentPower").toDouble();
        double totalConsumption = map.value("totalConsumption").toDouble();
        double totalProduction = map.value("totalProduction").toDouble();
        ThingPowerLogEntry *entry = new ThingPowerLogEntry(timestamp, thingId, currentPower, totalConsumption, totalProduction, this);
        if (m_cachedEntries.isEmpty()) {
            m_cachedEntries.append(entry);
        } else if (entry->timestamp() == m_cachedEntries.first()->timestamp()) {
            m_cachedEntries.append(entry);
        } else {
            addEntries(m_cachedEntries);
            m_cachedEntries.clear();
            m_cachedEntries.append(entry);
        }
        m_cacheTimer.start();
    }
}


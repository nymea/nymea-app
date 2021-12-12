#include "powerbalancelogs.h"

#include <QMetaEnum>

PowerBalanceLogEntry::PowerBalanceLogEntry(QObject *parent): EnergyLogEntry(parent)
{

}

PowerBalanceLogEntry::PowerBalanceLogEntry(const QDateTime &timestamp, double consumption, double production, double acquisition, double storage, double totalConsumption, double totalProduction, double totalAcquisition, double totalReturn, QObject *parent):
    EnergyLogEntry(timestamp, parent),
    m_consumption(consumption),
    m_production(production),
    m_acquisition(acquisition),
    m_storage(storage),
    m_totalConsumption(totalConsumption),
    m_totalProduction(totalProduction),
    m_totalAcquisition(totalAcquisition),
    m_totalReturn(totalReturn)
{

}

double PowerBalanceLogEntry::consumption() const
{
    return m_consumption;
}

double PowerBalanceLogEntry::production() const
{
    return m_production;
}

double PowerBalanceLogEntry::acquisition() const
{
    return m_acquisition;
}

double PowerBalanceLogEntry::storage() const
{
    return m_storage;
}

double PowerBalanceLogEntry::totalConsumption() const
{
    return m_totalConsumption;
}

double PowerBalanceLogEntry::totalProduction() const
{
    return m_totalProduction;
}

double PowerBalanceLogEntry::totalAcquisition() const
{
    return m_totalAcquisition;
}

double PowerBalanceLogEntry::totalReturn() const
{
    return m_totalReturn;
}

PowerBalanceLogs::PowerBalanceLogs(QObject *parent) : EnergyLogs(parent)
{

}

double PowerBalanceLogs::minValue() const
{
    return m_minValue;
}

double PowerBalanceLogs::maxValue() const
{
    return m_maxValue;
}

QString PowerBalanceLogs::logsName() const
{
    return "PowerBalanceLogs";
}

void PowerBalanceLogs::addEntry(PowerBalanceLogEntry *entry)
{
    if (entry->consumption() < m_minValue) {
        m_minValue = entry->consumption();
        emit minValueChanged();
    }
    if (entry->consumption() > m_maxValue) {
        m_maxValue = entry->consumption();
        emit maxValueChanged();
    }

    if (entry->production() < m_minValue) {
        m_minValue = entry->production();
        emit minValueChanged();
    }
    if (entry->production() > m_maxValue) {
        m_maxValue = entry->production();
        emit maxValueChanged();
    }
    if (entry->acquisition() < m_minValue) {
        m_minValue = entry->acquisition();
        emit minValueChanged();
    }
    if (entry->acquisition() > m_maxValue) {
        m_maxValue = entry->acquisition();
        emit maxValueChanged();
    }
    if (entry->storage() < m_minValue) {
        m_minValue = entry->storage();
        emit minValueChanged();
    }
    if (entry->storage() > m_maxValue) {
        m_maxValue = entry->storage();
        emit maxValueChanged();
    }

    appendEntry(entry);
}

EnergyLogEntry *PowerBalanceLogs::find(const QDateTime &timestamp) const
{
    qWarning() << "Finding log entry for timestamp:" << timestamp;
    int oldest = 0;
    int newest = rowCount() - 1;
    EnergyLogEntry *entry = nullptr;
    int step = 0;
    while (oldest <= newest && step < rowCount()) {
        EnergyLogEntry *oldestEntry = get(oldest);
        EnergyLogEntry *newestEntry = get(newest);
        int middle = (newest - oldest) / 2 + oldest;
        EnergyLogEntry *middleEntry = get(middle);
        qWarning() << "Oldest:" << oldestEntry->timestamp().toString() << "Middle:" << middleEntry->timestamp().toString() << "Newest:" << newestEntry->timestamp().toString() << ":" << (newest - oldest);
        if (timestamp <= oldestEntry->timestamp()) {
            return oldestEntry;
        }
        if (timestamp >= newestEntry->timestamp()) {
            return newestEntry;
        }

        if (timestamp == middleEntry->timestamp()) {
            return middleEntry;
        }

        if (timestamp < middleEntry->timestamp()) {
            newest = middle;
        } else {
            oldest = middle;
        }

        if ((newest - oldest) <= 1) {
            return newestEntry;
        }
        step++;
    }
    return entry;
}

void PowerBalanceLogs::logEntriesReceived(const QVariantMap &params)
{
    foreach (const QVariant &variant, params.value("powerBalanceLogEntries").toList()) {
        QVariantMap map = variant.toMap();
        QDateTime timestamp = QDateTime::fromSecsSinceEpoch(map.value("timestamp").toLongLong());
        double consumption = map.value("consumption").toDouble();
        double production = map.value("production").toDouble();
        double acquisition = map.value("acquisition").toDouble();
        double storage = map.value("storage").toDouble();
        double totalConsumption = map.value("totalConsumption").toDouble();
        double totalProduction = map.value("totalProduction").toDouble();
        double totalAcquisition = map.value("totalAcquisition").toDouble();
        double totalReturn = map.value("totalReturn").toDouble();
        PowerBalanceLogEntry *entry = new PowerBalanceLogEntry(timestamp, consumption, production, acquisition, storage, totalConsumption, totalProduction, totalAcquisition, totalReturn, this);
//        qCritical() << "Adding entry:" << entry->timestamp() << entry->totalConsumption();

        addEntry(entry);
    }
}

void PowerBalanceLogs::notificationReceived(const QVariantMap &data)
{
    QString notification = data.value("notification").toString();
    QVariantMap params = data.value("params").toMap();

    QMetaEnum sampleRateEnum = QMetaEnum::fromType<EnergyLogs::SampleRate>();
    SampleRate sampleRate = static_cast<SampleRate>(sampleRateEnum.keyToValue(data.value("params").toMap().value("sampleRate").toByteArray()));

    if (sampleRate != this->sampleRate()) {
        return;
    }

    if (notification == "Energy.PowerBalanceLogEntryAdded") {
        QVariantMap map = params.value("powerBalanceLogEntry").toMap();
        QDateTime timestamp = QDateTime::fromSecsSinceEpoch(map.value("timestamp").toLongLong());
        double consumption = map.value("consumption").toDouble();
        double production = map.value("production").toDouble();
        double acquisition = map.value("acquisition").toDouble();
        double storage = map.value("storage").toDouble();
        double totalConsumption = map.value("totalConsumption").toDouble();
        double totalProduction = map.value("totalProduction").toDouble();
        double totalAcquisition = map.value("totalAcquisition").toDouble();
        double totalReturn = map.value("totalReturn").toDouble();
        PowerBalanceLogEntry *entry = new PowerBalanceLogEntry(timestamp, consumption, production, acquisition, storage, totalConsumption, totalProduction, totalAcquisition, totalReturn, this);
        addEntry(entry);
    }
}

PowerBalanceLogs *PowerBalanceLogsProxy::powerBalanceLogs() const
{
    return m_powerBalanceLogs;
}

void PowerBalanceLogsProxy::setPowerBalanceLogs(PowerBalanceLogs *powerBalanceLogs)
{
    if (m_powerBalanceLogs != powerBalanceLogs) {
        m_powerBalanceLogs = powerBalanceLogs;
        setSourceModel(powerBalanceLogs);
        emit powerBalanceLogsChanged();
    }
}

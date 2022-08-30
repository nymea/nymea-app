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

QString PowerBalanceLogs::logsName() const
{
    return "PowerBalanceLogs";
}

QList<EnergyLogEntry *> PowerBalanceLogs::unpackEntries(const QVariantMap &params, double *minValue, double *maxValue)
{
    QList<EnergyLogEntry*> ret;
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

        *minValue = qMin(qMin(qMin(qMin(*minValue, consumption), production), acquisition), storage);
        *maxValue = qMax(qMax(qMax(qMax(*maxValue, consumption), production), acquisition), storage);

        ret.append(entry);
    }
    return ret;
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
        double minValue = qMin(qMin(qMin(consumption, production), acquisition), storage);
        double maxValue = qMax(qMax(qMax(consumption, production), acquisition), storage);
        appendEntry(entry, minValue, maxValue);
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

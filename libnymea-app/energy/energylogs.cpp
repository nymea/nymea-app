#include "energylogs.h"
#include "powerbalancelogs.h"

#include <QMetaEnum>

#include "logging.h"
NYMEA_LOGGING_CATEGORY(dcEnergyLogs, "EnergyLogs")


EnergyLogs::EnergyLogs(QObject *parent) : QObject(parent)
{
    m_powerBalanceLogs = new PowerBalanceLogs(this);
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
        qCDebug(dcEnergyLogs()) << "************* getting energylogs" << m_engine->jsonRpcClient()->experiences();
        if (m_engine->jsonRpcClient()->experiences().value("Energy").toString() >= "1.0") {

            QVariantMap params;
            QMetaEnum metaEnum = QMetaEnum::fromType<SampleRate>();
            params.insert("sampleRate", metaEnum.valueToKey(m_sampleRate));
            m_engine->jsonRpcClient()->registerNotificationHandler(this, "Energy", "notificationReceived");
            m_engine->jsonRpcClient()->sendCommand("Energy.GetPowerBalanceLogs", params, this, "powerBalanceLogsReceived");
//            m_engine->jsonRpcClient()->sendCommand("Energy.GetThingPowerLogs", params, this, "thingPowerLogsReceived");

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
    }
}

bool EnergyLogs::fetchPowerBalance() const
{
    return m_fetchPowerBalance;
}

void EnergyLogs::setFetchPowerBalance(bool fetchPowerBalance)
{
    if (m_fetchPowerBalance != fetchPowerBalance) {
        m_fetchPowerBalance = fetchPowerBalance;
        emit fetchPowerBalanceChanged();
    }
}

QList<QUuid> EnergyLogs::thingIds() const
{
    return m_thingIds;
}

void EnergyLogs::setThingIds(const QList<QUuid> &thingIds)
{
    if (m_thingIds != thingIds) {
        m_thingIds = thingIds;
        emit thingIdsChanged();
    }
}

PowerBalanceLogs *EnergyLogs::powerBalanceLogs() const
{
    return m_powerBalanceLogs;
}

void EnergyLogs::powerBalanceLogsReceived(int commandId, const QVariantMap &params)
{
    Q_UNUSED(commandId)
    foreach (const QVariant &variant, params.value("powerBalanceLogEntries").toList()) {
        QVariantMap map = variant.toMap();
        QDateTime timestamp = QDateTime::fromSecsSinceEpoch(map.value("timestamp").toLongLong());
        double consumption = map.value("consumption").toDouble();
        double production = map.value("production").toDouble();
        double acquisition = map.value("acquisition").toDouble();
        double storage = map.value("storage").toDouble();
        PowerBalanceLogEntry *entry = new PowerBalanceLogEntry(timestamp, consumption, production, acquisition, storage, this);
        m_powerBalanceLogs->addEntry(entry);
    }
}

void EnergyLogs::thingPowerLogsReceived(int commandId, const QVariantMap &params)
{
    Q_UNUSED(commandId)
    qCDebug(dcEnergyLogs) << "got energy logs";
}

void EnergyLogs::notificationReceived(const QVariantMap &data)
{
    QString notification = data.value("notification").toString();
    QVariantMap params = data.value("params").toMap();

    if (notification == "Energy.PowerBalanceLogEntryAdded") {
        QVariantMap map = data.value("powerBalanceLogEntry").toMap();
        QDateTime timestamp = QDateTime::fromSecsSinceEpoch(map.value("timestamp").toLongLong());
        double consumption = map.value("consumption").toDouble();
        double production = map.value("production").toDouble();
        double acquisition = map.value("acquisition").toDouble();
        double storage = map.value("storage").toDouble();
        PowerBalanceLogEntry *entry = new PowerBalanceLogEntry(timestamp, consumption, production, acquisition, storage, this);
        m_powerBalanceLogs->addEntry(entry);
    }
}

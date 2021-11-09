#include "energymanager.h"

#include "engine.h"

#include "logging.h"

NYMEA_LOGGING_CATEGORY(dcEnergyExperience, "EnergyExperience")

EnergyManager::EnergyManager(QObject *parent) : QObject(parent)
{

}

EnergyManager::~EnergyManager()
{
    if (m_engine) {
        m_engine->jsonRpcClient()->unregisterNotificationHandler(this);
    }
}

Engine *EnergyManager::engine() const
{
    return m_engine;
}

void EnergyManager::setEngine(Engine *engine)
{
    if (m_engine != engine) {
        if (m_engine) {
            m_engine->jsonRpcClient()->unregisterNotificationHandler(this);
        }

        m_engine = engine;
        emit engineChanged();

        if (m_engine) {
            m_engine->jsonRpcClient()->registerNotificationHandler(this, "Energy", "notificationReceived");
            m_engine->jsonRpcClient()->sendCommand("Energy.GetRootMeter", QVariantMap(), this, "getRootMeterResponse");
            m_engine->jsonRpcClient()->sendCommand("Energy.GetPowerBalance", QVariantMap(), this, "getPowerBalanceResponse");
        }
    }
}

QUuid EnergyManager::rootMeterId() const
{
    return m_rootMeterId;
}

int EnergyManager::setRootMeterId(const QUuid &rootMeterId)
{
    if (!m_engine) {
        return -1;
    }
    QVariantMap params;
    params.insert("rootMeterThingId", rootMeterId);
    return m_engine->jsonRpcClient()->sendCommand("Energy.SetRootMeter", params);
}

double EnergyManager::currentPowerConsumption() const
{
    return m_currentPowerConsumption;
}

double EnergyManager::currentPowerProduction() const
{
    return m_currentPowerProduction;
}

double EnergyManager::currentPowerAcquisition() const
{
    return m_currentPowerAcquisition;
}

void EnergyManager::notificationReceived(const QVariantMap &data)
{
    qCDebug(dcEnergyExperience()) << "Energy notification received" << data;
    QString notification = data.value("notification").toString();
    QVariantMap params = data.value("params").toMap();
    if (notification == "Energy.RootMeterChanged") {
        m_rootMeterId = params.value("rootMeterThingId").toUuid();
        emit rootMeterIdChanged();
    }
    if (notification == "Energy.PowerBalanceChanged") {
        m_currentPowerConsumption = params.value("currentPowerConsumption").toDouble();
        m_currentPowerProduction = params.value("currentPowerProduction").toDouble();
        m_currentPowerAcquisition = params.value("currentPowerAcquisition").toDouble();
        emit powerBalanceChanged();
    }
}

void EnergyManager::getRootMeterResponse(int commandId, const QVariantMap &params)
{
    Q_UNUSED(commandId)
    qCDebug(dcEnergyExperience) << "RootMeter response:" << params;
    m_rootMeterId = params.value("rootMeterThingId").toUuid();
    emit rootMeterIdChanged();
}

void EnergyManager::getPowerBalanceResponse(int commandId, const QVariantMap &params)
{
    Q_UNUSED(commandId)
    qCDebug(dcEnergyExperience()) << "Power balance response:" << params;
    m_currentPowerConsumption = params.value("currentPowerConsumption").toDouble();
    m_currentPowerProduction = params.value("currentPowerProduction").toDouble();
    m_currentPowerAcquisition = params.value("currentPowerAcquisition").toDouble();
    emit powerBalanceChanged();
}


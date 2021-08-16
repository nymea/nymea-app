#ifndef ENERGYMANAGER_H
#define ENERGYMANAGER_H

#include <QObject>
#include <QUuid>

#include "engine.h"

class EnergyManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(Engine* engine READ engine WRITE setEngine NOTIFY engineChanged)
    Q_PROPERTY(QUuid rootMeterId READ rootMeterId NOTIFY rootMeterIdChanged)

    Q_PROPERTY(double currentPowerConsumption READ currentPowerConsumption NOTIFY powerBalanceChanged)
    Q_PROPERTY(double currentPowerProduction READ currentPowerProduction NOTIFY powerBalanceChanged)
    Q_PROPERTY(double currentPowerAcquisition READ currentPowerAcquisition NOTIFY powerBalanceChanged)
    Q_PROPERTY(double currentPowerStorage READ currentPowerStorage NOTIFY powerBalanceChanged)
    Q_PROPERTY(double totalConsumption READ totalConsumption NOTIFY powerBalanceChanged)
    Q_PROPERTY(double totalProduction READ totalProduction NOTIFY powerBalanceChanged)
    Q_PROPERTY(double totalAcquisition READ totalAcquisition NOTIFY powerBalanceChanged)
    Q_PROPERTY(double totalReturn READ totalReturn NOTIFY powerBalanceChanged)

public:
    explicit EnergyManager(QObject *parent = nullptr);
    ~EnergyManager();

    Engine* engine() const;
    void setEngine(Engine *engine);

    QUuid rootMeterId() const;
    Q_INVOKABLE int setRootMeterId(const QUuid &rootMeterId);

    double currentPowerConsumption() const;
    double currentPowerProduction() const;
    double currentPowerAcquisition() const;
    double currentPowerStorage() const;
    double totalConsumption() const;
    double totalProduction() const;
    double totalAcquisition() const;
    double totalReturn() const;

signals:
    void engineChanged();
    void rootMeterIdChanged();
    void powerBalanceChanged();

private slots:
    void notificationReceived(const QVariantMap &data);
    void getRootMeterResponse(int commandId, const QVariantMap &params);
    void getPowerBalanceResponse(int commandId, const QVariantMap &params);

private:
    Engine *m_engine = nullptr;
    QUuid m_rootMeterId;

    double m_currentPowerConsumption = 0;
    double m_currentPowerProduction = 0;
    double m_currentPowerAcquisition = 0;
    double m_currentPowerStorage = 0;
    double m_totalConsumption = 0;
    double m_totalProduction = 0;
    double m_totalAcquisition = 0;
    double m_totalReturn = 0;
};

#endif // ENERGYMANAGER_H

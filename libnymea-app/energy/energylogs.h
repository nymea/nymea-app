#ifndef ENERGYLOGS_H
#define ENERGYLOGS_H

#include "engine.h"

#include <QObject>
#include <QUuid>

class PowerBalanceLogs;

class EnergyLogs : public QObject
{
    Q_OBJECT
    Q_PROPERTY(Engine *engine READ engine WRITE setEngine NOTIFY engineChanged)
    Q_PROPERTY(SampleRate sampleRate READ sampleRate WRITE setSampleRate NOTIFY sampleRateChanged)
    Q_PROPERTY(bool fetchPowerBalance READ fetchPowerBalance WRITE setFetchPowerBalance NOTIFY fetchPowerBalanceChanged)
    Q_PROPERTY(QList<QUuid> thingIds READ thingIds WRITE setThingIds NOTIFY thingIdsChanged)

    Q_PROPERTY(PowerBalanceLogs *powerBalanceLogs READ powerBalanceLogs CONSTANT)
public:
    enum SampleRate {
        SampleRate1Min = 1,
        SampleRate15Mins = 15,
        SampleRate1Hour = 60,
        SampleRate3Hours = 180,
        SampleRate1Day = 1440,
        SampleRate1Week = 10080,
        SampleRate1Month = 43200,
        SampleRate1Year = 525600
    };
    Q_ENUM(SampleRate)

    explicit EnergyLogs(QObject *parent = nullptr);

    Engine *engine() const;
    void setEngine(Engine *engine);

    SampleRate sampleRate() const;
    void setSampleRate(SampleRate sampleRate);

    bool fetchPowerBalance() const;
    void setFetchPowerBalance(bool fetchPowerBalance);

    QList<QUuid> thingIds() const;
    void setThingIds(const QList<QUuid> &thingIds);

    PowerBalanceLogs *powerBalanceLogs() const;

signals:
    void engineChanged();
    void sampleRateChanged();
    void fetchPowerBalanceChanged();
    void thingIdsChanged();

private slots:
    void powerBalanceLogsReceived(int commandId, const QVariantMap &params);
    void thingPowerLogsReceived(int commandId, const QVariantMap &params);
    void notificationReceived(const QVariantMap &data);

private:
    Engine *m_engine = nullptr;
    SampleRate m_sampleRate = SampleRate15Mins;
    bool m_fetchPowerBalance = true;
    QList<QUuid> m_thingIds;

    PowerBalanceLogs *m_powerBalanceLogs = nullptr;
};

#endif // ENERGYLOGS_H

#ifndef POWERBALANCELOGS_H
#define POWERBALANCELOGS_H

#include <QObject>
#include <QAbstractListModel>
#include <QDateTime>
#include <QSortFilterProxyModel>

#include "energylogs.h"

class PowerBalanceLogEntry: public EnergyLogEntry
{
    Q_OBJECT
    Q_PROPERTY(double consumption READ consumption CONSTANT)
    Q_PROPERTY(double production READ production CONSTANT)
    Q_PROPERTY(double acquisition READ acquisition CONSTANT)
    Q_PROPERTY(double storage READ storage CONSTANT)
    Q_PROPERTY(double totalConsumption READ totalConsumption CONSTANT)
    Q_PROPERTY(double totalProduction READ totalProduction CONSTANT)
    Q_PROPERTY(double totalAcquisition READ totalAcquisition CONSTANT)
    Q_PROPERTY(double totalReturn READ totalReturn CONSTANT)
public:
    PowerBalanceLogEntry(QObject *parent = nullptr);
    PowerBalanceLogEntry(const QDateTime &timestamp, double consumption, double production, double acquisition, double storage, double totalConsumption, double totalProduction, double totalAcquisition, double totalReturn, QObject *parent);

    double consumption() const;
    double production() const;
    double acquisition() const;
    double storage() const;
    double totalConsumption() const;
    double totalProduction() const;
    double totalAcquisition() const;
    double totalReturn() const;
private:
    QDateTime m_timestamp;
    double m_consumption = 0;
    double m_production = 0;
    double m_acquisition = 0;
    double m_storage = 0;
    double m_totalConsumption = 0;
    double m_totalProduction = 0;
    double m_totalAcquisition = 0;
    double m_totalReturn = 0;
};

class PowerBalanceLogs : public EnergyLogs
{
    Q_OBJECT
public:
    explicit PowerBalanceLogs(QObject *parent = nullptr);

protected:
    QString logsName() const override;
    QList<EnergyLogEntry*> unpackEntries(const QVariantMap &params, double *minValue, double *maxValue) override;
    void notificationReceived(const QVariantMap &data) override;
};


class PowerBalanceLogsProxy: public QSortFilterProxyModel
{
    Q_OBJECT
    Q_PROPERTY(PowerBalanceLogs* powerBalanceLogs READ powerBalanceLogs WRITE setPowerBalanceLogs NOTIFY powerBalanceLogsChanged)
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)


public:
    PowerBalanceLogsProxy(QObject *parent);

    PowerBalanceLogs *powerBalanceLogs() const;
    void setPowerBalanceLogs(PowerBalanceLogs *powerBalanceLogs);

signals:
    void countChanged();
    void powerBalanceLogsChanged();

private:
    PowerBalanceLogs *m_powerBalanceLogs = nullptr;
};

#endif // POWERBALANCELOGS_H

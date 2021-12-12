#ifndef THINGPOWERLOGS_H
#define THINGPOWERLOGS_H

#include <QObject>
#include <QAbstractListModel>

#include "energylogs.h"

class ThingPowerLogEntry: public EnergyLogEntry
{
    Q_OBJECT
    Q_PROPERTY(QUuid thingId READ thingId CONSTANT)
    Q_PROPERTY(double currentPower READ currentPower CONSTANT)
    Q_PROPERTY(double totalConsumption READ totalConsumption CONSTANT)
    Q_PROPERTY(double totalProduction READ totalProduction CONSTANT)
public:
    ThingPowerLogEntry(QObject *parent = nullptr);
    ThingPowerLogEntry(const QDateTime &timestamp, const QUuid &thingId, double currentPower, double totalConsumption, double totalProduction, QObject *parent = nullptr);

    QUuid thingId() const;
    double currentPower() const;
    double totalConsumption() const;
    double totalProduction() const;

private:
    QUuid m_thingId;
    double m_currentPower = 0;
    double m_totalConsumption = 0;
    double m_totalProduction = 0;
};

class ThingPowerLogs : public EnergyLogs
{
    Q_OBJECT
    Q_PROPERTY(QList<QUuid> thingIds READ thingIds WRITE setThingIds NOTIFY thingIdsChanged)
    Q_PROPERTY(double minValue READ minValue NOTIFY minValueChanged)
    Q_PROPERTY(double maxValue READ maxValue NOTIFY maxValueChanged)
public:
    explicit ThingPowerLogs(QObject *parent = nullptr);

    QList<QUuid> thingIds() const;
    void setThingIds(const QList<QUuid> &thingIds);

    double minValue() const;
    double maxValue() const;

    Q_INVOKABLE ThingPowerLogEntry *find(const QUuid &thingId, const QDateTime &timestamp);

    Q_INVOKABLE ThingPowerLogEntry *liveEntry(const QUuid &thingId);

signals:
    void thingIdsChanged();

    void minValueChanged();
    void maxValueChanged();

    void liveEntryChanged(ThingPowerLogEntry *entry);

protected:
    QString logsName() const override;
    QVariantMap fetchParams() const override;
    void logEntriesReceived(const QVariantMap &params) override;
    void notificationReceived(const QVariantMap &data) override;

private:
    void addEntry(ThingPowerLogEntry *entry);
    void addEntries(const QList<ThingPowerLogEntry *> &entries);

    ThingPowerLogEntry *unpack(const QVariantMap &map);

    QList<QUuid> m_thingIds;
    double m_minValue = 0;
    double m_maxValue = 0;

    QList<ThingPowerLogEntry*> m_cachedEntries;
    QTimer m_cacheTimer;

    QHash<QUuid, ThingPowerLogEntry*> m_liveEntries;
};

#endif // THINGPOWERLOGS_H

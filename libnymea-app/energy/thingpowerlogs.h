// SPDX-License-Identifier: LGPL-3.0-or-later

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
* Copyright (C) 2013 - 2024, nymea GmbH
* Copyright (C) 2024 - 2025, chargebyte austria GmbH
*
* This file is part of libnymea-app.
*
* libnymea-app is free software: you can redistribute it and/or
* modify it under the terms of the GNU Lesser General Public License
* as published by the Free Software Foundation, either version 3
* of the License, or (at your option) any later version.
*
* libnymea-app is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
* GNU Lesser General Public License for more details.
*
* You should have received a copy of the GNU Lesser General Public License
* along with libnymea-app. If not, see <https://www.gnu.org/licenses/>.
*
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

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

class ThingPowerLogsLoader;

class ThingPowerLogs : public EnergyLogs
{
    Q_OBJECT
    Q_PROPERTY(QUuid thingId READ thingId WRITE setThingId NOTIFY thingIdChanged)
    Q_PROPERTY(ThingPowerLogsLoader* loader READ loader WRITE setLoader NOTIFY loaderChanged)
public:
    explicit ThingPowerLogs(QObject *parent = nullptr);

    QUuid thingId() const;
    void setThingId(const QUuid &thingId);

    ThingPowerLogsLoader *loader() const;
    void setLoader(ThingPowerLogsLoader *loader);

    Q_INVOKABLE ThingPowerLogEntry *liveEntry();

signals:
    void thingIdChanged();
    void loaderChanged();
    void liveEntryChanged(ThingPowerLogEntry *liveEntry);

protected:
    QString logsName() const override;
    QVariantMap fetchParams() const override;
    QList<EnergyLogEntry*> unpackEntries(const QVariantMap &params, double *minValue, double *maxValue) override;
    void notificationReceived(const QVariantMap &data) override;

private:
    void addEntries(const QList<ThingPowerLogEntry *> &entries);

    ThingPowerLogEntry *unpack(const QVariantMap &map);

    QUuid m_thingId;
    ThingPowerLogEntry* m_liveEntry = nullptr;
    ThingPowerLogsLoader* m_loader = nullptr;
};

class ThingPowerLogsLoader: public QObject
{
    Q_OBJECT
    Q_PROPERTY(Engine *engine READ engine WRITE setEngine NOTIFY engineChanged)
    Q_PROPERTY(EnergyLogs::SampleRate sampleRate READ sampleRate WRITE setSampleRate NOTIFY sampleRateChanged)
    Q_PROPERTY(QDateTime startTime READ startTime WRITE setStartTime NOTIFY startTimeChanged)
    Q_PROPERTY(QDateTime endTime READ endTime WRITE setEndTime NOTIFY endTimeChanged)
    Q_PROPERTY(bool fetchingData READ fetchingData NOTIFY fetchingDataChanged)

public:
    ThingPowerLogsLoader(QObject *parent = nullptr);

    Engine *engine() const;
    void setEngine(Engine *engine);

    EnergyLogs::SampleRate sampleRate() const;
    void setSampleRate(EnergyLogs::SampleRate sampleRate);

    QDateTime startTime() const;
    void setStartTime(const QDateTime &startTime);

    QDateTime endTime() const;
    void setEndTime(const QDateTime &endTime);

    bool fetchingData() const;

    void addThingId(const QUuid &thingId);

public slots:
    void fetchLogs();

signals:
    void engineChanged();
    void sampleRateChanged();
    void startTimeChanged();
    void endTimeChanged();
    void fetchingDataChanged();
    void fetched(int commandId, const QVariantMap &params);

private slots:
    void getLogsResponse(int commandId, const QVariantMap &params);

private:
    Engine *m_engine = nullptr;
    EnergyLogs::SampleRate m_sampleRate = EnergyLogs::SampleRate15Mins;
    QDateTime m_startTime;
    QDateTime m_endTime;
    QList<QUuid> m_thingIds;
    bool m_fetchingData = false;
    bool m_fetchAgain = false;
    QDateTime m_lastStartTime;
    QDateTime m_lastEndTime;

};

#endif // THINGPOWERLOGS_H

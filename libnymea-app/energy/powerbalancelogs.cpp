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

#include "powerbalancelogs.h"

#include <QMap>
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
    QMap<qint64, QVariantMap> deduplicatedEntries;
    foreach (const QVariant &variant, params.value("powerBalanceLogEntries").toList()) {
        QVariantMap map = variant.toMap();
        // Keep the last row for a timestamp if the backend returned duplicates.
        deduplicatedEntries.insert(map.value("timestamp").toLongLong(), map);
    }

    for (auto it = deduplicatedEntries.constBegin(); it != deduplicatedEntries.constEnd(); ++it) {
        const QVariantMap &map = it.value();
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

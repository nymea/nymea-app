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

#ifndef REPEATINGOPTION_H
#define REPEATINGOPTION_H

#include <QObject>
#include <QVariantList>

class RepeatingOption: public QObject
{
    Q_OBJECT
    Q_PROPERTY(RepeatingMode repeatingMode READ repeatingMode WRITE setRepeatingMode NOTIFY repeatingModeChanged)
    Q_PROPERTY(QVariantList weekDays READ weekDays WRITE setWeekDays NOTIFY weekDaysChanged)
    Q_PROPERTY(QVariantList monthDays READ monthDays WRITE setMonthDays NOTIFY monthDaysChanged)

public:
    enum RepeatingMode {
        RepeatingModeNone,
        RepeatingModeHourly,
        RepeatingModeDaily,
        RepeatingModeWeekly,
        RepeatingModeMonthly,
        RepeatingModeYearly
    };
    Q_ENUM(RepeatingMode)

    explicit RepeatingOption(QObject *parent = nullptr);

    RepeatingMode repeatingMode() const;
    void setRepeatingMode(RepeatingMode repeatingMode);

    QVariantList weekDays() const;
    void setWeekDays(const QVariantList &weekDays);

    QVariantList monthDays() const;
    void setMonthDays(const QVariantList &monthDays);

signals:
    void repeatingModeChanged();
    void weekDaysChanged();
    void monthDaysChanged();

private:
    RepeatingMode m_repeatingMode = RepeatingModeDaily;
    QVariantList m_weekDays;
    QVariantList m_monthDays;
};


#endif // REPEATINGOPTION_H

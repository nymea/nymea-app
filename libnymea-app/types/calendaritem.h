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

#ifndef CALENDARITEM_H
#define CALENDARITEM_H

#include <QObject>
#include <QDateTime>

#include "repeatingoption.h"

class CalendarItem : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int duration READ duration WRITE setDuration NOTIFY durationChanged)
    Q_PROPERTY(QDateTime dateTime READ dateTime WRITE setDateTime NOTIFY dateTimeChanged)
    Q_PROPERTY(QTime startTime READ startTime WRITE setStartTime NOTIFY startTimeChanged)
    Q_PROPERTY(RepeatingOption* repeatingOption READ repeatingOption CONSTANT)

public:
    explicit CalendarItem(QObject *parent = nullptr);

    int duration() const;
    void setDuration(int duration);

    QDateTime dateTime() const;
    void setDateTime(const QDateTime &dateTime);

    QTime startTime() const;
    void setStartTime(const QTime &startTime);

    RepeatingOption* repeatingOption() const;

    CalendarItem* clone() const;
    bool operator==(CalendarItem* other) const;

signals:
    void durationChanged();
    void dateTimeChanged();
    void startTimeChanged();

private:
    int m_duration = 0;
    QDateTime m_dateTime;
    QTime m_startTime;
    RepeatingOption* m_repeatingOption = nullptr;
};

#endif // CALENDARITEM_H

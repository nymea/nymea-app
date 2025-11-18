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

#include "calendaritemtemplate.h"


CalendarItemTemplate::CalendarItemTemplate(int duration, const QDateTime &dateTime, const QTime &startTime, RepeatingOption *repeatingOption, bool editable, QObject *parent):
    QObject(parent),
    m_duration(duration),
    m_dateTime(dateTime),
    m_startTime(startTime),
    m_repeatingOption(repeatingOption),
    m_editable(editable)
{
    m_repeatingOption->setParent(this);
}

int CalendarItemTemplate::duration() const
{
    return m_duration;
}

QDateTime CalendarItemTemplate::dateTime() const
{
    return m_dateTime;
}

QTime CalendarItemTemplate::startTime() const
{
    return m_startTime;
}

RepeatingOption *CalendarItemTemplate::repeatingOption()
{
    return m_repeatingOption;
}

bool CalendarItemTemplate::editable() const
{
    return m_editable;
}

CalendarItem *CalendarItemTemplate::createCalendarItem() const
{
    CalendarItem *ret = new CalendarItem();
    ret->setDateTime(m_dateTime);
    ret->setDuration(m_duration);
    ret->setStartTime(m_startTime);
    ret->repeatingOption()->setWeekDays(m_repeatingOption->weekDays());
    ret->repeatingOption()->setMonthDays(m_repeatingOption->monthDays());
    ret->repeatingOption()->setRepeatingMode(m_repeatingOption->repeatingMode());
    return ret;
}

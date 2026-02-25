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

#include "timeeventitemtemplate.h"

TimeEventItemTemplate::TimeEventItemTemplate(const QDateTime &dateTime, const QTime &time, RepeatingOption *repeatingOption, bool editable, QObject *parent):
    QObject(parent),
    m_dateTime(dateTime),
    m_time(time),
    m_repeatingOption(repeatingOption),
    m_editable(editable)
{
    m_repeatingOption->setParent(this);
}

QDateTime TimeEventItemTemplate::dateTime() const
{
    return m_dateTime;
}

QTime TimeEventItemTemplate::time() const
{
    return m_time;
}

RepeatingOption *TimeEventItemTemplate::repeatingOption() const
{
    return m_repeatingOption;
}

bool TimeEventItemTemplate::editable() const
{
    return m_editable;
}

TimeEventItem *TimeEventItemTemplate::createTimeEventItem() const
{
    TimeEventItem *item = new TimeEventItem();
    item->setDateTime(m_dateTime);
    item->setTime(m_time);
    item->repeatingOption()->setWeekDays(m_repeatingOption->weekDays());
    item->repeatingOption()->setMonthDays(m_repeatingOption->monthDays());
    item->repeatingOption()->setRepeatingMode(m_repeatingOption->repeatingMode());
    return item;
}

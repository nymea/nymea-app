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

#include "timeeventitem.h"

#include "repeatingoption.h"

#include <QDebug>

TimeEventItem::TimeEventItem(QObject *parent):
    QObject(parent),
    m_repeatingOption(new RepeatingOption(this))
{
}

QDateTime TimeEventItem::dateTime() const
{
    return m_dateTime;
}

void TimeEventItem::setDateTime(const QDateTime &dateTime)
{
    if (m_dateTime != dateTime) {
        m_dateTime = dateTime;
        emit dateTimeChanged();
    }
}

QTime TimeEventItem::time() const
{
    return m_time;
}

void TimeEventItem::setTime(const QTime &time)
{
    if (m_time != time) {
        m_time = time;
        emit timeChanged();
    }
}

RepeatingOption *TimeEventItem::repeatingOption() const
{
    return m_repeatingOption;
}

TimeEventItem *TimeEventItem::clone() const
{
    TimeEventItem* ret = new TimeEventItem();
    ret->m_dateTime = this->m_dateTime;
    ret->m_time = this->m_time;
    ret->m_repeatingOption = this->m_repeatingOption;
    return ret;
}

#define COMPARE(a, b) if (a != b) { qDebug() << a << "!=" << b; return false; }
#define COMPARE_PTR(a, b) if (!a->operator==(b)) { qDebug() << a << "!=" << b; return false; }
bool TimeEventItem::operator==(TimeEventItem *other) const
{
    COMPARE(m_time, other->time());
    COMPARE(m_dateTime, other->dateTime());
    COMPARE(m_repeatingOption, other->repeatingOption());
    return true;
}

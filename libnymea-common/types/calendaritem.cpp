/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
* Copyright 2013 - 2020, nymea GmbH
* Contact: contact@nymea.io
*
* This file is part of nymea.
* This project including source code and documentation is protected by
* copyright law, and remains the property of nymea GmbH. All rights, including
* reproduction, publication, editing and translation, are reserved. The use of
* this project is subject to the terms of a license agreement to be concluded
* with nymea GmbH in accordance with the terms of use of nymea GmbH, available
* under https://nymea.io/license
*
* GNU General Public License Usage
* Alternatively, this project may be redistributed and/or modified under the
* terms of the GNU General Public License as published by the Free Software
* Foundation, GNU version 3. This project is distributed in the hope that it
* will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty
* of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
* Public License for more details.
*
* You should have received a copy of the GNU General Public License along with
* this project. If not, see <https://www.gnu.org/licenses/>.
*
* For any further details and any questions please contact us under
* contact@nymea.io or see our FAQ/Licensing Information on
* https://nymea.io/license/faq
*
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#include "calendaritem.h"

#include "repeatingoption.h"
#include <QDebug>

CalendarItem::CalendarItem(QObject *parent) : QObject(parent)
{
    m_repeatingOption = new RepeatingOption(this);
}

int CalendarItem::duration() const
{
    return m_duration;
}

void CalendarItem::setDuration(int duration)
{
    if (m_duration != duration) {
        m_duration = duration;
        emit durationChanged();
    }
}

QDateTime CalendarItem::dateTime() const
{
    return m_dateTime;
}

void CalendarItem::setDateTime(const QDateTime &dateTime)
{
    if (m_dateTime != dateTime) {
        m_dateTime = dateTime;
        emit dateTimeChanged();
    }
}

QTime CalendarItem::startTime() const
{
    return m_startTime;
}

void CalendarItem::setStartTime(const QTime &startTime)
{
    if (m_startTime != startTime) {
        m_startTime = startTime;
        emit startTimeChanged();
    }
}

RepeatingOption *CalendarItem::repeatingOption() const
{
    return m_repeatingOption;
}

CalendarItem *CalendarItem::clone() const
{
    CalendarItem* ret = new CalendarItem();
    ret->m_dateTime = this->m_dateTime;
    ret->m_duration = this->m_duration;
    ret->m_repeatingOption = this->m_repeatingOption;
    ret->m_startTime = this->m_startTime;
    return ret;
}

#define COMPARE(a, b) if (a != b) { qDebug() << a << "!=" << b; return false; }
#define COMPARE_PTR(a, b) if (!a->operator==(b)) { qDebug() << a << "!=" << b; return false; }
bool CalendarItem::operator ==(CalendarItem *other) const
{
    COMPARE(m_dateTime, other->dateTime());
    COMPARE(m_startTime, other->startTime());
    COMPARE(m_duration, other->duration());
    COMPARE(m_repeatingOption, other->repeatingOption());
    return true;
}

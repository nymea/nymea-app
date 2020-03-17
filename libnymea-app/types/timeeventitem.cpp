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

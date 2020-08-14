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

#include "logentry.h"

#include <QDateTime>

LogEntry::LogEntry(const QDateTime &timestamp, const QVariant &value, const QUuid &thingId, const QUuid &typeId, LoggingSource source, LoggingEventType loggingEventType, QObject *parent):
    QObject(parent),
    m_value(value),
    m_timeStamp(timestamp),
    m_thingId(thingId),
    m_typeId(typeId),
    m_source(source),
    m_loggingEventType(loggingEventType)
{

}

QVariant LogEntry::value() const
{
    return m_value;
}

QDateTime LogEntry::timestamp() const
{
    return m_timeStamp;
}

QUuid LogEntry::thingId() const
{
    return m_thingId;
}

QUuid LogEntry::typeId() const
{
    return m_typeId;
}

LogEntry::LoggingSource LogEntry::source() const
{
    return m_source;
}

LogEntry::LoggingEventType LogEntry::loggingEventType() const
{
    return m_loggingEventType;
}

QString LogEntry::timeString() const
{
    return m_timeStamp.time().toString("hh:mm");
}

QString LogEntry::dayString() const
{
    switch (m_timeStamp.date().dayOfWeek()) {
    case 1:
        return "Mo";
    case 2:
        return "Tu";
    case 3:
        return "We";
    case 4:
        return "Th";
    case 5:
        return "Fr";
    case 6:
        return "Sa";
    case 7:
        return "Su";
    }
    return "--";
}

QString LogEntry::dateString() const
{
    return m_timeStamp.date().toString("dd.MM.");
}

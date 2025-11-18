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

#include "logentry.h"

#include <QDateTime>

LogEntry::LogEntry(const QDateTime &timestamp, const QVariant &value, const QUuid &thingId, const QUuid &typeId, LoggingSource source, LoggingEventType loggingEventType, const QString &errorCode, QObject *parent):
    QObject(parent),
    m_value(value),
    m_timeStamp(timestamp),
    m_thingId(thingId),
    m_typeId(typeId),
    m_source(source),
    m_loggingEventType(loggingEventType),
    m_errorCode(errorCode)
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

QString LogEntry::errorCode() const
{
    return m_errorCode;
}

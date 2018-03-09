#include "logentry.h"

#include <QDateTime>

LogEntry::LogEntry(const QDateTime &timestamp, const QVariant &value, const QString &deviceId, const QString &typeId, LoggingSource source, LoggingEventType loggingEventType, QObject *parent):
    QObject(parent),
    m_value(value),
    m_timeStamp(timestamp),
    m_deviceId(deviceId),
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

QString LogEntry::deviceId() const
{
    return m_deviceId;
}

QString LogEntry::typeId() const
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

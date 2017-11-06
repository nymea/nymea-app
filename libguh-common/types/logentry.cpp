#include "logentry.h"

#include <QDateTime>

LogEntry::LogEntry(const QDateTime &timestamp, const QVariant &value, QObject *parent):
    QObject(parent),
    m_value(value),
    m_timeStamp(timestamp)
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

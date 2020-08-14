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

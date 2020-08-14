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

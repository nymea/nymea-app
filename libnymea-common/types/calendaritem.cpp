#include "calendaritem.h"

#include "repeatingoption.h"

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

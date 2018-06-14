#include "timedescriptor.h"

#include "timeeventitems.h"
#include "calendaritems.h"

TimeDescriptor::TimeDescriptor(QObject *parent) : QObject(parent)
{
    m_timeEventItems = new TimeEventItems(this);
    m_calendarItems = new CalendarItems(this);
}

TimeEventItems *TimeDescriptor::timeEventItems() const
{
    return m_timeEventItems;
}

CalendarItems *TimeDescriptor::calendarItems() const
{
    return m_calendarItems;
}

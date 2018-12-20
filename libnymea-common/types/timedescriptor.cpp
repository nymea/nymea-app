#include "timedescriptor.h"

#include "timeeventitems.h"
#include "calendaritems.h"

#include <QDebug>

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

#define COMPARE(a, b) if (a != b) { qDebug() << a << "!=" << b; return false; }
#define COMPARE_PTR(a, b) if (!a->operator==(b)) { qDebug() << a << "!=" << b; return false; }
bool TimeDescriptor::operator==(TimeDescriptor *other) const
{
    COMPARE_PTR(m_timeEventItems, other->timeEventItems());
    COMPARE_PTR(m_calendarItems, other->calendarItems());
    return true;
}

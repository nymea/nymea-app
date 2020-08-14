#include "timedescriptortemplate.h"

#include "calendaritemtemplate.h"
#include "timeeventitemtemplate.h"

TimeDescriptorTemplate::TimeDescriptorTemplate(QObject *parent):
    QObject(parent)
{
    m_calendarItemTemplates = new CalendarItemTemplates(this);
    m_timeEventItemTemplates = new TimeEventItemTemplates(this);
}

CalendarItemTemplates *TimeDescriptorTemplate::calendarItemTemplates() const
{
    return m_calendarItemTemplates;
}

TimeEventItemTemplates *TimeDescriptorTemplate::timeEventItemTemplates() const
{
    return m_timeEventItemTemplates;
}

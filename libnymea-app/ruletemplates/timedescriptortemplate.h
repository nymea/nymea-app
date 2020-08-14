#ifndef TIMEDESCRIPTORTEMPLATE_H
#define TIMEDESCRIPTORTEMPLATE_H

#include <QObject>

class CalendarItemTemplates;
class TimeEventItemTemplates;

class TimeDescriptorTemplate : public QObject
{
    Q_OBJECT
    Q_PROPERTY(CalendarItemTemplates* calendarItemTemplates READ calendarItemTemplates CONSTANT)
    Q_PROPERTY(TimeEventItemTemplates* timeEventItemTemplates READ timeEventItemTemplates CONSTANT)

public:
    explicit TimeDescriptorTemplate(QObject *parent = nullptr);

    CalendarItemTemplates* calendarItemTemplates() const;
    TimeEventItemTemplates* timeEventItemTemplates() const;

private:
    CalendarItemTemplates *m_calendarItemTemplates = nullptr;
    TimeEventItemTemplates *m_timeEventItemTemplates = nullptr;
};

#endif // TIMEDESCRIPTORTEMPLATE_H

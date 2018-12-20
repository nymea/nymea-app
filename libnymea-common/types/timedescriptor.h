#ifndef TIMEDESCRIPTOR_H
#define TIMEDESCRIPTOR_H

#include <QObject>

#include <QAbstractListModel>

class TimeEventItems;
class CalendarItems;

class TimeDescriptor : public QObject
{
    Q_OBJECT
    Q_PROPERTY(TimeEventItems* timeEventItems READ timeEventItems CONSTANT)
    Q_PROPERTY(CalendarItems* calendarItems READ calendarItems CONSTANT)
public:
    explicit TimeDescriptor(QObject *parent = nullptr);

    TimeEventItems* timeEventItems() const;
    CalendarItems* calendarItems() const;

    bool operator==(TimeDescriptor* other) const;
signals:

public slots:

private:
    TimeEventItems* m_timeEventItems = nullptr;
    CalendarItems* m_calendarItems = nullptr;
};

#endif // TIMEDESCRIPTOR_H

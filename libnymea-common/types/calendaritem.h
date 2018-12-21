#ifndef CALENDARITEM_H
#define CALENDARITEM_H

#include <QObject>
#include <QDateTime>

class RepeatingOption;

class CalendarItem : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int duration READ duration WRITE setDuration NOTIFY durationChanged)
    Q_PROPERTY(QDateTime dateTime READ dateTime WRITE setDateTime NOTIFY dateTimeChanged)
    Q_PROPERTY(QTime startTime READ startTime WRITE setStartTime NOTIFY startTimeChanged)
    Q_PROPERTY(RepeatingOption* repeatingOption READ repeatingOption CONSTANT)

public:
    explicit CalendarItem(QObject *parent = nullptr);

    int duration() const;
    void setDuration(int duration);

    QDateTime dateTime() const;
    void setDateTime(const QDateTime &dateTime);

    QTime startTime() const;
    void setStartTime(const QTime &startTime);

    RepeatingOption* repeatingOption() const;

    CalendarItem* clone() const;
    bool operator==(CalendarItem* other) const;

signals:
    void durationChanged();
    void dateTimeChanged();
    void startTimeChanged();

private:
    int m_duration = 0;
    QDateTime m_dateTime;
    QTime m_startTime;
    RepeatingOption* m_repeatingOption = nullptr;
};

#endif // CALENDARITEM_H

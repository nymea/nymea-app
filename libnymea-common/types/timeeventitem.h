#ifndef TIMEEVENTITEM_H
#define TIMEEVENTITEM_H

#include <QObject>
#include <QDateTime>
#include <QTime>

class RepeatingOption;

class TimeEventItem : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QDateTime dateTime READ dateTime WRITE setDateTime NOTIFY dateTimeChanged)
    Q_PROPERTY(QTime time READ time WRITE setTime NOTIFY timeChanged)
    Q_PROPERTY(RepeatingOption* repeatingOption READ repeatingOption CONSTANT)

public:
    explicit TimeEventItem(QObject *parent = nullptr);

    QDateTime dateTime() const;
    void setDateTime(const QDateTime &dateTime);

    QTime time() const;
    void setTime(const QTime &time);

    RepeatingOption* repeatingOption() const;

    TimeEventItem* clone() const;

signals:
    void dateTimeChanged();
    void timeChanged();

private:
    QDateTime m_dateTime;
    QTime m_time;
    RepeatingOption *m_repeatingOption = nullptr;

};

#endif // TIMEEVENTITEM_H

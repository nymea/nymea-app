#include "timeeventitem.h"

TimeEventItem::TimeEventItem(QObject *parent) : QObject(parent)
{

}

QDateTime TimeEventItem::dateTime() const
{
    return m_dateTime;
}

void TimeEventItem::setDateTime(const QDateTime &dateTime)
{
    if (m_dateTime != dateTime) {
        m_dateTime = dateTime;
        emit dateTimeChanged();
    }
}

QTime TimeEventItem::time() const
{
    return m_time;
}

void TimeEventItem::setTime(const QTime &time)
{
    if (m_time != time) {
        m_time = time;
        emit timeChanged();
    }
}

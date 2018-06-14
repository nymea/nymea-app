#include "timeeventitem.h"

#include "repeatingoption.h"

TimeEventItem::TimeEventItem(QObject *parent):
    QObject(parent),
    m_repeatingOption(new RepeatingOption(this))
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

RepeatingOption *TimeEventItem::repeatingOption() const
{
    return m_repeatingOption;
}

TimeEventItem *TimeEventItem::clone() const
{
    TimeEventItem* ret = new TimeEventItem();
    ret->m_dateTime = this->m_dateTime;
    ret->m_time = this->m_time;
    ret->m_repeatingOption = this->m_repeatingOption;
    return ret;
}

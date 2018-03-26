#ifndef TIMEEVENTITEM_H
#define TIMEEVENTITEM_H

#include <QObject>
#include <QDateTime>
#include <QTime>

class TimeEventItem : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QDateTime dateTime READ dateTime WRITE setDateTime NOTIFY dateTimeChanged)
    Q_PROPERTY(QTime time READ time WRITE setTime NOTIFY timeChanged)

public:
    explicit TimeEventItem(QObject *parent = nullptr);

    QDateTime dateTime() const;
    void setDateTime(const QDateTime &dateTime);

    QTime time() const;
    void setTime(const QTime &time);

signals:
    void dateTimeChanged();
    void timeChanged();

private:
    QDateTime m_dateTime;
    QTime m_time;

};

#endif // TIMEEVENTITEM_H

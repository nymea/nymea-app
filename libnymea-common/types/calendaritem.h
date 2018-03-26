#ifndef CALENDARITEM_H
#define CALENDARITEM_H

#include <QObject>

class CalendarItem : public QObject
{
    Q_OBJECT
public:
    explicit CalendarItem(QObject *parent = nullptr);

signals:

public slots:
};

#endif // CALENDARITEM_H
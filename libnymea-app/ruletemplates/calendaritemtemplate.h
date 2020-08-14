#ifndef CALENDARITEMTEMPLATE_H
#define CALENDARITEMTEMPLATE_H

#include "types/repeatingoption.h"
#include "types/calendaritem.h"

#include <QObject>
#include <QAbstractListModel>
#include <QDateTime>

class CalendarItemTemplate : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int duration READ duration CONSTANT)
    Q_PROPERTY(QDateTime dateTime READ dateTime CONSTANT)
    Q_PROPERTY(QTime startTime READ startTime CONSTANT)
    Q_PROPERTY(RepeatingOption* repeatingOption READ repeatingOption CONSTANT)
    Q_PROPERTY(bool editable READ editable CONSTANT)
public:
    explicit CalendarItemTemplate(int duration, const QDateTime &dateTime, const QTime &startTime, RepeatingOption *repeatingOption, bool editable, QObject *parent = nullptr);

    int duration() const;
    QDateTime dateTime() const;
    QTime startTime() const;
    RepeatingOption* repeatingOption();
    bool editable() const;

    Q_INVOKABLE CalendarItem *createCalendarItem() const;

private:
    int m_duration = 0;
    QDateTime m_dateTime;
    QTime m_startTime;
    RepeatingOption *m_repeatingOption = nullptr;
    bool m_editable = true;
};

class CalendarItemTemplates: public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ rowCount CONSTANT)

public:
    CalendarItemTemplates(QObject *parent = nullptr): QAbstractListModel(parent) {}
    int rowCount(const QModelIndex &parent = QModelIndex()) const override { Q_UNUSED(parent); return m_list.count(); }
    QVariant data(const QModelIndex &index, int role) const override { Q_UNUSED(index); Q_UNUSED(role); return QVariant(); }

    Q_INVOKABLE CalendarItemTemplate* get(int index) const {
        if (index < 0 || index >= m_list.count()) {
            return nullptr;
        }
        return m_list.at(index);
    }

    void addCalendarItemTemplate(CalendarItemTemplate *calendarItemTemplate) {
        calendarItemTemplate->setParent(this);
        beginInsertRows(QModelIndex(), m_list.count(), m_list.count());
        m_list.append(calendarItemTemplate);
        endInsertRows();
    }
private:
    QList<CalendarItemTemplate*> m_list;
};

#endif // CALENDARITEMTEMPLATE_H

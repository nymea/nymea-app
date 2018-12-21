#ifndef CALENDARITEMS_H
#define CALENDARITEMS_H

#include <QAbstractListModel>

class CalendarItem;

class CalendarItems : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)
public:
    explicit CalendarItems(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role) const override;

    Q_INVOKABLE void addCalendarItem(CalendarItem* calendarItem);
    Q_INVOKABLE void removeCalendarItem(int index);

    Q_INVOKABLE CalendarItem* createNewCalendarItem() const;
    Q_INVOKABLE CalendarItem* get(int index) const;

    bool operator==(CalendarItems *other) const;

signals:
    void countChanged();

private:
    QList<CalendarItem*> m_list;
};

#endif // CALENDARITEMS_H

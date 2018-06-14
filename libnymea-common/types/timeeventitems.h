#ifndef TIMEEVENTITEMS_H
#define TIMEEVENTITEMS_H

#include <QAbstractListModel>

class TimeEventItem;

class TimeEventItems: public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)
public:
    TimeEventItems(QObject *parent);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role) const override;

    Q_INVOKABLE void addTimeEventItem(TimeEventItem *timeEventItem);
    Q_INVOKABLE void removeTimeEventItem(int index);

    Q_INVOKABLE TimeEventItem* get(int index) const;
    Q_INVOKABLE TimeEventItem* createNewTimeEventItem() const;


signals:
    void countChanged();

private:
    QList<TimeEventItem*> m_list;
};

#endif // TIMEEVENTITEMS_H

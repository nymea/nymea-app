#include "timeeventitems.h"

#include "timeeventitem.h"

TimeEventItems::TimeEventItems(QObject *parent):
    QAbstractListModel(parent)
{

}

int TimeEventItems::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return m_list.count();
}

QVariant TimeEventItems::data(const QModelIndex &index, int role) const
{
    Q_UNUSED(index)
    Q_UNUSED(role)
    return QVariant();
}

void TimeEventItems::addTimeEventItem(TimeEventItem *timeEventItem)
{
    timeEventItem->setParent(this);
    beginInsertRows(QModelIndex(), m_list.count(), m_list.count());
    m_list.append(timeEventItem);
    endInsertRows();
    emit countChanged();
}

void TimeEventItems::removeTimeEventItem(int index)
{
    if (index < 0 || index > m_list.count()) {
        return;
    }
    beginRemoveRows(QModelIndex(), index, index);
    m_list.takeAt(index)->deleteLater();
    endRemoveRows();
    emit countChanged();
}

TimeEventItem *TimeEventItems::get(int index) const
{
    if (index < 0 || index > m_list.count()) {
        return nullptr;
    }
    return m_list.at(index);
}

TimeEventItem *TimeEventItems::createNewTimeEventItem() const
{
    return new TimeEventItem();
}

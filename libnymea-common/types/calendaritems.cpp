#include "calendaritems.h"
#include "calendaritem.h"

CalendarItems::CalendarItems(QObject *parent) : QAbstractListModel(parent)
{

}

int CalendarItems::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return m_list.count();
}

QVariant CalendarItems::data(const QModelIndex &index, int role) const
{
    Q_UNUSED(index)
    Q_UNUSED(role)
    return QVariant();
}

void CalendarItems::addCalendarItem(CalendarItem *calendarItem)
{
    calendarItem->setParent(this);
    beginInsertRows(QModelIndex(), m_list.count(), m_list.count());
    m_list.append(calendarItem);
    endInsertRows();
    emit countChanged();
}

void CalendarItems::removeCalendarItem(int index)
{
    if (index < 0 || index > m_list.count()) {
        return;
    }
    beginRemoveRows(QModelIndex(), index, index);
    m_list.takeAt(index)->deleteLater();
    endRemoveRows();
}

CalendarItem *CalendarItems::createNewCalendarItem() const
{
    return new CalendarItem();
}

CalendarItem *CalendarItems::get(int index) const
{
    if (index < 0 || index > m_list.count()) {
        return nullptr;
    }
    return m_list.at(index);
}

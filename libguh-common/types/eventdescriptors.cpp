#include "eventdescriptors.h"
#include "eventdescriptor.h"

EventDescriptors::EventDescriptors(QObject *parent) :
    QAbstractListModel(parent)
{

}

int EventDescriptors::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return m_list.count();
}

QVariant EventDescriptors::data(const QModelIndex &index, int role) const
{
    return QVariant();
}

QHash<int, QByteArray> EventDescriptors::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles.insert(RoleName, "name");
    return roles;
}

EventDescriptor *EventDescriptors::get(int index) const
{
    return m_list.at(index);
}

void EventDescriptors::addEventDescriptor(EventDescriptor *eventDescriptor)
{
    eventDescriptor->setParent(this);
    beginInsertRows(QModelIndex(), m_list.count(), m_list.count());
    m_list.append(eventDescriptor);
    endInsertRows();
    emit countChanged();
}

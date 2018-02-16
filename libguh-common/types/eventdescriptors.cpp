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
    switch (role) {
    case RoleDeviceId:
        return m_list.at(index.row())->deviceId();
    case RoleEventTypeId:
        return m_list.at(index.row())->eventTypeId();
    }
    return QVariant();
}

QHash<int, QByteArray> EventDescriptors::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles.insert(RoleDeviceId, "deviceId");
    roles.insert(RoleEventTypeId, "eventId");
    return roles;
}

EventDescriptor *EventDescriptors::get(int index) const
{
    return m_list.at(index);
}

EventDescriptor *EventDescriptors::createNewEventDescriptor()
{
    return new EventDescriptor();
}

void EventDescriptors::addEventDescriptor(EventDescriptor *eventDescriptor)
{
    eventDescriptor->setParent(this);
    beginInsertRows(QModelIndex(), m_list.count(), m_list.count());
    m_list.append(eventDescriptor);
    endInsertRows();
    emit countChanged();
}

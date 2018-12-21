#include "eventdescriptors.h"
#include "eventdescriptor.h"

#include <QDebug>

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
    if (index >= 0 && index < m_list.count()) {
        return m_list.at(index);
    }
    return nullptr;
}

EventDescriptor *EventDescriptors::createNewEventDescriptor()
{
    return new EventDescriptor(this);
}

void EventDescriptors::addEventDescriptor(EventDescriptor *eventDescriptor)
{
    eventDescriptor->setParent(this);
    beginInsertRows(QModelIndex(), m_list.count(), m_list.count());
    m_list.append(eventDescriptor);
    endInsertRows();
    emit countChanged();
}

void EventDescriptors::removeEventDescriptor(int index)
{
    beginRemoveRows(QModelIndex(), index, index);
    m_list.takeAt(index)->deleteLater();
    endRemoveRows();
    emit countChanged();
}

bool EventDescriptors::operator==(EventDescriptors *other) const
{
    qDebug() << "EventDescriptors comparison";
    if (rowCount() != other->rowCount()) {
        qDebug() << "EventDescriptors count not matching";
        return false;
    }
    for (int i = 0; i < rowCount(); i++) {
        if (!get(i)->operator==(other->get(i))) {
            return false;
        }
    }
    return true;
}

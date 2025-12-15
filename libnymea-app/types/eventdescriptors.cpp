// SPDX-License-Identifier: LGPL-3.0-or-later

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
* Copyright (C) 2013 - 2024, nymea GmbH
* Copyright (C) 2024 - 2025, chargebyte austria GmbH
*
* This file is part of libnymea-app.
*
* libnymea-app is free software: you can redistribute it and/or
* modify it under the terms of the GNU Lesser General Public License
* as published by the Free Software Foundation, either version 3
* of the License, or (at your option) any later version.
*
* libnymea-app is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
* GNU Lesser General Public License for more details.
*
* You should have received a copy of the GNU Lesser General Public License
* along with libnymea-app. If not, see <https://www.gnu.org/licenses/>.
*
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

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
    return static_cast<int>(m_list.count());
}

QVariant EventDescriptors::data(const QModelIndex &index, int role) const
{
    switch (role) {
    case RoleThingId:
        return m_list.at(index.row())->thingId();
    case RoleEventTypeId:
        return m_list.at(index.row())->eventTypeId();
    }
    return QVariant();
}

QHash<int, QByteArray> EventDescriptors::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles.insert(RoleThingId, "thingId");
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
    beginInsertRows(QModelIndex(), static_cast<int>(m_list.count()), static_cast<int>(m_list.count()));
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

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *                                                                         *
 *  Copyright (C) 2017 Simon Stuerz <simon.stuerz@guh.io>                  *
 *                                                                         *
 *  This file is part of nymea:app                                         *
 *                                                                         *
 *  This library is free software; you can redistribute it and/or          *
 *  modify it under the terms of the GNU Lesser General Public             *
 *  License as published by the Free Software Foundation; either           *
 *  version 2.1 of the License, or (at your option) any later version.     *
 *                                                                         *
 *  This library is distributed in the hope that it will be useful,        *
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of         *
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU      *
 *  Lesser General Public License for more details.                        *
 *                                                                         *
 *  You should have received a copy of the GNU Lesser General Public       *
 *  License along with this library; If not, see                           *
 *  <http://www.gnu.org/licenses/>.                                        *
 *                                                                         *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#include "eventtypes.h"

#include <QDebug>

EventTypes::EventTypes(QObject *parent) :
    QAbstractListModel(parent)
{
}

QList<EventType *> EventTypes::eventTypes()
{
    return m_eventTypes;
}

EventType *EventTypes::get(int index) const
{
    return m_eventTypes.at(index);
}

EventType *EventTypes::getEventType(const QString &eventTypeId) const
{
    foreach (EventType *eventType, m_eventTypes) {
        if (eventType->id() == eventTypeId) {
            return eventType;
        }
    }
    return 0;
}

int EventTypes::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return m_eventTypes.count();
}

QVariant EventTypes::data(const QModelIndex &index, int role) const
{
    EventType *eventType = m_eventTypes.at(index.row());
    switch (role) {
    case RoleId:
        return eventType->id();
    case RoleName:
        return eventType->name();
    case RoleDisplayName:
        return eventType->displayName();
    }
    return QVariant();
}

void EventTypes::addEventType(EventType *eventType)
{
    eventType->setParent(this);
    beginInsertRows(QModelIndex(), m_eventTypes.count(), m_eventTypes.count());
    //qDebug() << "EventTypes: loaded eventType" << eventType->name();
    m_eventTypes.append(eventType);
    endInsertRows();
    emit countChanged();
}

void EventTypes::clearModel()
{
    beginResetModel();
    m_eventTypes.clear();
    endResetModel();
    emit countChanged();
}

EventType *EventTypes::findByName(const QString &name) const
{
    foreach (EventType *eventType, m_eventTypes) {
        if (eventType->name() == name) {
            return eventType;
        }
    }
    return nullptr;
}

QHash<int, QByteArray> EventTypes::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles.insert(RoleId, "id");
    roles.insert(RoleName, "name");
    roles.insert(RoleDisplayName, "displayName");
    return roles;
}


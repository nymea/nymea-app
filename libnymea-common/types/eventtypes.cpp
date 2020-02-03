/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
* Copyright 2013 - 2020, nymea GmbH
* Contact: contact@nymea.io
*
* This file is part of nymea.
* This project including source code and documentation is protected by
* copyright law, and remains the property of nymea GmbH. All rights, including
* reproduction, publication, editing and translation, are reserved. The use of
* this project is subject to the terms of a license agreement to be concluded
* with nymea GmbH in accordance with the terms of use of nymea GmbH, available
* under https://nymea.io/license
*
* GNU General Public License Usage
* Alternatively, this project may be redistributed and/or modified under the
* terms of the GNU General Public License as published by the Free Software
* Foundation, GNU version 3. This project is distributed in the hope that it
* will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty
* of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
* Public License for more details.
*
* You should have received a copy of the GNU General Public License along with
* this project. If not, see <https://www.gnu.org/licenses/>.
*
* For any further details and any questions please contact us under
* contact@nymea.io or see our FAQ/Licensing Information on
* https://nymea.io/license/faq
*
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

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

EventType *EventTypes::getEventType(const QUuid &eventTypeId) const
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


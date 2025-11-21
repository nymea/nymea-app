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

#include "things.h"
#include "engine.h"

#include <QDebug>

Things::Things(QObject *parent) :
    QAbstractListModel(parent)
{
}

QList<Thing *> Things::devices()
{
    return m_things;
}

Thing *Things::get(int index) const
{
    if (index < 0 || index >= m_things.count()) {
        return nullptr;
    }
    return m_things.at(index);
}

Thing *Things::getThing(const QUuid &thingId) const
{
    foreach (Thing *thing, m_things) {
        if (thing->id() == thingId) {
            return thing;
        }
    }
    return nullptr;
}

int Things::indexOf(Thing *thing) const
{
    return static_cast<int>(static_cast<int>(m_things.indexOf(thing)));
}

int Things::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return static_cast<int>(m_things.count());
}

QVariant Things::data(const QModelIndex &index, int role) const
{
    if (index.row() < 0 || index.row() >= m_things.count())
        return QVariant();

    Thing *thing = m_things.at(index.row());
    switch (role) {
    case RoleName:
        return thing->name();
    case RoleId:
        return thing->id().toString();
    case RoleThingClass:
        return thing->thingClassId().toString();
    case RoleParentId:
        return thing->parentId().toString();
    case RoleSetupStatus:
        return thing->setupStatus();
    case RoleSetupDisplayMessage:
        return thing->setupDisplayMessage();
    case RoleInterfaces:
        return thing->thingClass()->interfaces();
    case RoleBaseInterface:
        return thing->thingClass()->baseInterface();
    case RoleMainInterface:
        return thing->thingClass()->interfaces().count() > 0 ? thing->thingClass()->interfaces().first() : "";
    }
    return QVariant();
}

void Things::addThing(Thing *thing)
{
    addThings({thing});
}

void Things::addThings(const QList<Thing *> things)
{
    if (things.isEmpty()) {
        return;
    }
    const int insertStart = static_cast<int>(m_things.count());
    const int insertEnd = insertStart + static_cast<int>(things.count()) - 1;
    beginInsertRows(QModelIndex(), insertStart, insertEnd);
    m_things.append(things);

    foreach (Thing *thing, things) {
        thing->setParent(this);
        connect(thing, &Thing::nameChanged, this, [thing, this]() {
            int idx = static_cast<int>(m_things.indexOf(thing));
            if (idx < 0) return;
            emit dataChanged(index(idx), index(idx), {RoleName});
        });
        connect(thing, &Thing::setupStatusChanged, this, [thing, this]() {
            int idx = static_cast<int>(m_things.indexOf(thing));
            if (idx < 0) return;
            emit dataChanged(index(idx), index(idx), {RoleSetupStatus, RoleSetupDisplayMessage});
        });
        connect(thing->states(), &States::dataChanged, this, [thing, this]() {
            int idx = static_cast<int>(m_things.indexOf(thing));
            if (idx < 0) return;
            emit dataChanged(index(idx), index(idx));
        });
        emit thingAdded(thing);
    }
    endInsertRows();

    emit countChanged();
}

void Things::removeThing(Thing *thing)
{
    int index = static_cast<int>(m_things.indexOf(thing));
    beginRemoveRows(QModelIndex(), index, index);
    qDebug() << "Removed thing" << thing->name();
    m_things.takeAt(index)->deleteLater();
    endRemoveRows();
    emit countChanged();
    emit thingRemoved(thing);
}

void Things::clearModel()
{
    beginResetModel();
    qDeleteAll(m_things);
    m_things.clear();
    endResetModel();
    emit countChanged();
}

QHash<int, QByteArray> Things::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[RoleName] = "name";
    roles[RoleId] = "id";
    roles[RoleThingClass] = "thingClassId";
    roles[RoleParentId] = "parentId";
    roles[RoleSetupStatus] = "setupStatus";
    roles[RoleSetupDisplayMessage] = "setupDisplayMessage";
    roles[RoleInterfaces] = "interfaces";
    roles[RoleBaseInterface] = "baseInterface";
    roles[RoleMainInterface] = "mainInterface";
    return roles;
}

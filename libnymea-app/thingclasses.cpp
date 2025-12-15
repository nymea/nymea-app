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

#include "thingclasses.h"

#include <QDebug>

ThingClasses::ThingClasses(QObject *parent) :
    QAbstractListModel(parent)
{
}

QList<ThingClass *> ThingClasses::thingClasses()
{
    return m_thingClasses;
}

int ThingClasses::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return static_cast<int>(m_thingClasses.count());
}

QVariant ThingClasses::data(const QModelIndex &index, int role) const
{
    if (index.row() < 0 || index.row() >= m_thingClasses.count())
        return QVariant();

    ThingClass *thingClass = m_thingClasses.at(index.row());
    switch (role) {
    case RoleId:
        return thingClass->id().toString();
    case RoleName:
        return thingClass->name();
    case RoleDisplayName:
        return thingClass->displayName();
    case RolePluginId:
        return thingClass->pluginId().toString();
    case RoleVendorId:
        return thingClass->vendorId().toString();
    case RoleInterfaces:
        return thingClass->interfaces();
    case RoleBaseInterface:
        return thingClass->baseInterface();
    }
    return QVariant();
}

int ThingClasses::count() const
{
    return static_cast<int>(m_thingClasses.count());
}

ThingClass *ThingClasses::get(int index) const
{
    if (index < 0 || index >= m_thingClasses.count()) {
        return nullptr;
    }
    return m_thingClasses.at(index);
}

ThingClass *ThingClasses::getThingClass(QUuid thingClassId) const
{
    foreach (ThingClass *thingClass, m_thingClasses) {
        if (thingClass->id() == thingClassId) {
            return thingClass;
        }
    }
    return nullptr;
}

void ThingClasses::addThingClass(ThingClass *thingClass)
{
    thingClass->setParent(this);
    beginInsertRows(QModelIndex(), static_cast<int>(m_thingClasses.count()), static_cast<int>(m_thingClasses.count()));
    m_thingClasses.append(thingClass);
    endInsertRows();
    emit countChanged();
}

void ThingClasses::clearModel()
{
    beginResetModel();
    foreach (ThingClass *thingClass, m_thingClasses)
        thingClass->deleteLater();

    m_thingClasses.clear();
    endResetModel();
    emit countChanged();
}

QHash<int, QByteArray> ThingClasses::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[RoleId] = "id";
    roles[RoleName] = "name";
    roles[RoleDisplayName] = "displayName";
    roles[RolePluginId] = "pluginId";
    roles[RoleVendorId] = "vendorId";
    roles[RoleInterfaces] = "interfaces";
    roles[RoleBaseInterface] = "baseInterface";
    return roles;
}

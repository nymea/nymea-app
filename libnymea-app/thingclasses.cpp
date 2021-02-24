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
    return m_thingClasses.count();
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
    return m_thingClasses.count();
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

ThingClass *ThingClasses::getDeviceClass(QUuid thingClassId) const
{
    return getThingClass(thingClassId);
}

void ThingClasses::addThingClass(ThingClass *thingClass)
{
    thingClass->setParent(this);
    beginInsertRows(QModelIndex(), m_thingClasses.count(), m_thingClasses.count());
    m_thingClasses.append(thingClass);
    endInsertRows();
    emit countChanged();
}

void ThingClasses::clearModel()
{
    beginResetModel();
    qDeleteAll(m_thingClasses);
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

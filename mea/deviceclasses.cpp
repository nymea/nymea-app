/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *                                                                         *
 *  Copyright (C) 2017 Simon Stuerz <simon.stuerz@guh.io>                  *
 *                                                                         *
 *  This file is part of mea                                       *
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

#include "deviceclasses.h"

#include <QDebug>

DeviceClasses::DeviceClasses(QObject *parent) :
    QAbstractListModel(parent)
{
}

QList<DeviceClass *> DeviceClasses::deviceClasses()
{
    return m_deviceClasses;
}

int DeviceClasses::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return m_deviceClasses.count();
}

QVariant DeviceClasses::data(const QModelIndex &index, int role) const
{
    if (index.row() < 0 || index.row() >= m_deviceClasses.count())
        return QVariant();

    DeviceClass *deviceClass = m_deviceClasses.at(index.row());
    switch (role) {
    case RoleId:
        return deviceClass->id().toString();
    case RoleName:
        return deviceClass->name();
    case RoleDisplayName:
        return deviceClass->displayName();
    case RolePluginId:
        return deviceClass->pluginId().toString();
    case RoleVendorId:
        return deviceClass->vendorId().toString();
    }
    return QVariant();
}

int DeviceClasses::count() const
{
    return m_deviceClasses.count();
}

DeviceClass *DeviceClasses::get(int index) const
{
    return m_deviceClasses.at(index);
}

DeviceClass *DeviceClasses::getDeviceClass(QUuid deviceClassId) const
{
    foreach (DeviceClass *deviceClass, m_deviceClasses) {
        if (deviceClass->id() == deviceClassId) {
            return deviceClass;
        }
    }
    return 0;
}

void DeviceClasses::addDeviceClass(DeviceClass *deviceClass)
{
    beginInsertRows(QModelIndex(), m_deviceClasses.count(), m_deviceClasses.count());
    //qDebug() << "DeviceClasses: loaded deviceClass" << deviceClass->name();
    m_deviceClasses.append(deviceClass);
    endInsertRows();
}

void DeviceClasses::clearModel()
{
    beginResetModel();
    qDebug() << "Devices: delete all deviceClasses";
    qDeleteAll(m_deviceClasses);
    m_deviceClasses.clear();
    endResetModel();
}

QHash<int, QByteArray> DeviceClasses::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[RoleId] = "id";
    roles[RoleName] = "name";
    roles[RoleDisplayName] = "displayName";
    roles[RolePluginId] = "pluginId";
    roles[RoleVendorId] = "vendorId";
    return roles;
}

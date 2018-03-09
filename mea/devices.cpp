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

#include "devices.h"
#include "engine.h"

#include <QDebug>

Devices::Devices(QObject *parent) :
    QAbstractListModel(parent)
{
}

QList<Device *> Devices::devices()
{
    return m_devices;
}

int Devices::count() const
{
    return m_devices.count();
}

Device *Devices::get(int index) const
{
    return m_devices.at(index);
}

Device *Devices::getDevice(const QUuid &deviceId) const
{
    foreach (Device *device, m_devices) {
        if (device->id() == deviceId) {
            return device;
        }
    }
    return 0;
}

int Devices::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return m_devices.count();
}

QVariant Devices::data(const QModelIndex &index, int role) const
{
    if (index.row() < 0 || index.row() >= m_devices.count())
        return QVariant();

    Device *device = m_devices.at(index.row());
    switch (role) {
    case RoleName:
        return device->name();
    case RoleDeviceName:
        return device->deviceName();
    case RoleId:
        return device->id().toString();
    case RoleDeviceClass:
        return device->deviceClassId().toString();
    case RoleSetupComplete:
        return device->setupComplete();
    case RoleInterfaces: {
        DeviceClass *dc = Engine::instance()->deviceManager()->deviceClasses()->getDeviceClass(device->deviceClassId());
        if (dc) {
            return dc->interfaces();
        }
    }
    }
    return QVariant();

}

void Devices::addDevice(Device *device)
{
    beginInsertRows(QModelIndex(), m_devices.count(), m_devices.count());
//    qDebug() << "Devices: add device" << device->name();
    m_devices.append(device);
    endInsertRows();
}

void Devices::removeDevice(Device *device)
{
    int index = m_devices.indexOf(device);
    beginRemoveRows(QModelIndex(), index, index);
    qDebug() << "Devices: removed device" << device->name();
    m_devices.removeAt(index);
    endRemoveRows();
}

void Devices::clearModel()
{
    beginResetModel();
    qDebug() << "Devices: delete all devices";
    qDeleteAll(m_devices);
    m_devices.clear();
    endResetModel();
}

QHash<int, QByteArray> Devices::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[RoleName] = "name";
    roles[RoleDeviceName] = "deviceName";
    roles[RoleId] = "id";
    roles[RoleDeviceClass] = "deviceClassId";
    roles[RoleSetupComplete] = "setupComplete";
    roles[RoleBasicTag] = "basicTag";
    roles[RoleInterfaces] = "interfaces";
    return roles;
}

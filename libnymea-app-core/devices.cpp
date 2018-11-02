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

Device *Devices::get(int index) const
{
    if (index < 0 || index >= m_devices.count()) {
        return nullptr;
    }
    return m_devices.at(index);
}

Device *Devices::getDevice(const QUuid &deviceId) const
{
    foreach (Device *device, m_devices) {
        if (device->id() == deviceId) {
            return device;
        }
    }
    return nullptr;
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
    case RoleId:
        return device->id().toString();
    case RoleDeviceClass:
        return device->deviceClassId().toString();
    case RoleSetupComplete:
        return device->setupComplete();
    case RoleInterfaces: {
        return device->deviceClass()->interfaces();
    }
    case RoleBaseInterface: {
        QStringList interfaces = device->deviceClass()->interfaces();
        if (interfaces.contains("gateway")) {
            return "gateway";
        }
        if (interfaces.contains("shutter")) {
            return "shutter";
        }
        if (interfaces.contains("blind")) {
            return "blind";
        }
        if (interfaces.contains("garagegate")) {
            return "garagegate";
        }
        if (interfaces.contains("inputtrigger")) {
            return "inputtrigger";
        }
        if (interfaces.contains("awning")) {
            return "awning";
        }
        if (interfaces.contains("outputtrigger")) {
            return "outputtrigger";
        }
        if (interfaces.contains("light")) {
            return "light";
        }
        if (interfaces.contains("sensor")) {
            return "sensor";
        }
        if (interfaces.contains("weather")) {
            return "weather";
        }
        if (interfaces.contains("media")) {
            return "media";
        }
        if (interfaces.contains("button")) {
            return "button";
        }
        if (interfaces.contains("notifications")) {
            return "notifications";
        }
        if (interfaces.contains("smartmeter")) {
            return "smartmeter";
        }
        if (interfaces.contains("heating")) {
            return "heating";
        }
        if (interfaces.contains("evcharger")) {
            return "evcharger";
        }
        return "uncategorized";
    }

    }
    return QVariant();

}

void Devices::addDevice(Device *device)
{
    device->setParent(this);
    beginInsertRows(QModelIndex(), m_devices.count(), m_devices.count());
//    qDebug() << "Devices: add device" << device->name();
    m_devices.append(device);
    endInsertRows();
    connect(device, &Device::nameChanged, this, [device, this]() {
        int idx = m_devices.indexOf(device);
        if (idx < 0) return;
        emit dataChanged(index(idx), index(idx), {RoleName});
    });
    connect(device, &Device::setupCompleteChanged, this, [device, this]() {
        int idx = m_devices.indexOf(device);
        if (idx < 0) return;
        emit dataChanged(index(idx), index(idx), {RoleSetupComplete});
    });
    connect(device->states(), &States::dataChanged, this, [device, this]() {
        int idx = m_devices.indexOf(device);
        if (idx < 0) return;
        emit dataChanged(index(idx), index(idx));
    });
    emit countChanged();
}

void Devices::removeDevice(Device *device)
{
    int index = m_devices.indexOf(device);
    beginRemoveRows(QModelIndex(), index, index);
    qDebug() << "Devices: removed device" << device->name();
    m_devices.removeAt(index);
    endRemoveRows();
    emit countChanged();
}

void Devices::clearModel()
{
    beginResetModel();
    qDebug() << "Devices: delete all devices";
    qDeleteAll(m_devices);
    m_devices.clear();
    endResetModel();
    emit countChanged();
}

QHash<int, QByteArray> Devices::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[RoleName] = "name";
    roles[RoleId] = "id";
    roles[RoleDeviceClass] = "deviceClassId";
    roles[RoleSetupComplete] = "setupComplete";
    roles[RoleInterfaces] = "interfaces";
    roles[RoleBaseInterface] = "baseInterface";
    return roles;
}

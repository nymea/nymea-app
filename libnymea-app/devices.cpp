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
    case RoleParentDeviceId:
        return device->parentDeviceId().toString();
    case RoleSetupStatus:
        return device->setupStatus();
    case RoleSetupDisplayMessage:
        return device->setupDisplayMessage();
    case RoleInterfaces:
        return device->deviceClass()->interfaces();
    case RoleBaseInterface:
        return device->deviceClass()->baseInterface();
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
    connect(device, &Device::setupStatusChanged, this, [device, this]() {
        int idx = m_devices.indexOf(device);
        if (idx < 0) return;
        emit dataChanged(index(idx), index(idx), {RoleSetupStatus, RoleSetupDisplayMessage});
    });
    connect(device->states(), &States::dataChanged, this, [device, this]() {
        int idx = m_devices.indexOf(device);
        if (idx < 0) return;
        emit dataChanged(index(idx), index(idx));
    });
    emit countChanged();
    emit thingAdded(device);
}

void Devices::removeDevice(Device *device)
{
    int index = m_devices.indexOf(device);
    beginRemoveRows(QModelIndex(), index, index);
    qDebug() << "Devices: removed device" << device->name();
    m_devices.takeAt(index)->deleteLater();
    endRemoveRows();
    emit countChanged();
    emit thingRemoved(device);
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
    roles[RoleParentDeviceId] = "parentDeviceId";
    roles[RoleSetupStatus] = "setupStatus";
    roles[RoleSetupDisplayMessage] = "setupDisplayMessage";
    roles[RoleInterfaces] = "interfaces";
    roles[RoleBaseInterface] = "baseInterface";
    return roles;
}

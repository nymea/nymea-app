/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *                                                                         *
 *  Copyright (C) 2015 Simon Stuerz <stuerz.simon@gmail.com>               *
 *                                                                         *
 *  This file is part of nymea:app.                                       *
 *                                                                         *
 *  nymea:app is free software: you can redistribute it and/or modify     *
 *  it under the terms of the GNU General Public License as published by   *
 *  the Free Software Foundation, version 3 of the License.                *
 *                                                                         *
 *  nymea:app is distributed in the hope that it will be useful,          *
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of         *
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the           *
 *  GNU General Public License for more details.                           *
 *                                                                         *
 *  You should have received a copy of the GNU General Public License      *
 *  along with nymea:app. If not, see <http://www.gnu.org/licenses/>.     *
 *                                                                         *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#include "discoverymodel.h"

DiscoveryModel::DiscoveryModel(QObject *parent) :
    QAbstractListModel(parent)
{
}

int DiscoveryModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return m_devices.count();
}

QVariant DiscoveryModel::data(const QModelIndex &index, int role) const
{
    if (index.row() < 0 || index.row() >= m_devices.count())
        return QVariant();

    DiscoveryDevice *device = m_devices.at(index.row());
    switch (role) {
    case DeviceTypeRole:
        return device->deviceType();
    case UuidRole:
        return device->uuid();
    case NameRole:
        return device->name();
    case HostAddressRole:
        return device->hostAddress().toString();
    case BluetoothAddressRole:
        return device->bluetoothAddressString();
//    case WebSocketUrlRole:
//        return device.webSocketUrl();
//    case PortRole:
//        return device.port();
    case VersionRole:
        return device->version();
//    case NymeaRpcUrlRole:
//        return device.nymeaRpcUrl();
    }
    return QVariant();
}

void DiscoveryModel::addDevice(DiscoveryDevice *device)
{
    for (int i = 0; i < m_devices.count(); i++) {
        if (m_devices.at(i)->uuid() == device->uuid()) {
            qWarning() << "Device already added. Update existing device instead.";
            return;
        }
    }
    device->setParent(this);
    beginInsertRows(QModelIndex(), m_devices.count(), m_devices.count());
    m_devices.append(device);
    endInsertRows();
    emit countChanged();
}

DiscoveryDevice *DiscoveryModel::get(int index) const
{
    return m_devices.at(index);
}

DiscoveryDevice *DiscoveryModel::find(const QUuid &uuid)
{
    foreach (DiscoveryDevice *dev, m_devices) {
        if (dev->uuid() == uuid) {
            return dev;
        }
    }
    return nullptr;
}

DiscoveryDevice *DiscoveryModel::find(const QBluetoothAddress &bluetoothAddress)
{
    foreach (DiscoveryDevice *device, m_devices) {
        if (device->bluetoothAddress() == bluetoothAddress) {
            return device;
        }
    }

    return nullptr;
}

void DiscoveryModel::clearModel()
{
    beginResetModel();
    m_devices.clear();
    endResetModel();
    emit countChanged();
}

QHash<int, QByteArray> DiscoveryModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[DeviceTypeRole] = "deviceType";
    roles[UuidRole] = "uuid";
    roles[NameRole] = "name";
    roles[HostAddressRole] = "hostAddress";
    roles[BluetoothAddressRole] = "bluetoothAddress";
    roles[VersionRole] = "version";
    return roles;
}

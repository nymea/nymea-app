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

#include "networkdevices.h"
#include "networkdevice.h"

NetworkDevices::NetworkDevices(QObject *parent): QAbstractListModel(parent)
{

}

int NetworkDevices::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return static_cast<int>(m_list.count());
}

QVariant NetworkDevices::data(const QModelIndex &index, int role) const
{
    switch (role) {
    case RoleMacAddress:
        return m_list.at(index.row())->macAddress();
    case RoleInterface:
        return m_list.at(index.row())->interface();
    case RoleBitRate:
        return m_list.at(index.row())->bitRate();
    case RoleState:
        return m_list.at(index.row())->state();
    case RoleIpv4Addresses:
        return m_list.at(index.row())->ipv4Addresses();
    case RoleIpv6Addresses:
        return m_list.at(index.row())->ipv6Addresses();
    }
    return QVariant();
}

QHash<int, QByteArray> NetworkDevices::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles.insert(RoleMacAddress, "macAddress");
    roles.insert(RoleInterface, "interface");
    roles.insert(RoleBitRate, "bitRate");
    roles.insert(RoleState, "state");
    roles.insert(RoleIpv4Addresses, "ipv4Addresses");
    roles.insert(RoleIpv6Addresses, "ipv6Addresses");
    return roles;
}

void NetworkDevices::addNetworkDevice(NetworkDevice *networkDevice)
{
    networkDevice->setParent(this);
    beginInsertRows(QModelIndex(), static_cast<int>(m_list.count()), static_cast<int>(m_list.count()));
    m_list.append(networkDevice);
    connect(networkDevice, &NetworkDevice::bitRateChanged, this, [this, networkDevice](){
        emit dataChanged(index(static_cast<int>(m_list.indexOf(networkDevice))), index(static_cast<int>(m_list.indexOf(networkDevice))), {RoleBitRate});
        emit countChanged();
    });
    connect(networkDevice, &NetworkDevice::stateChanged, this, [this, networkDevice](){
        emit dataChanged(index(static_cast<int>(m_list.indexOf(networkDevice))), index(static_cast<int>(m_list.indexOf(networkDevice))), {RoleState});
        emit countChanged();
    });
    endInsertRows();
    emit countChanged();
}

void NetworkDevices::removeNetworkDevice(const QString &interface)
{
    int idx = -1;
    for (int i = 0; i < m_list.count(); i++) {
        if (m_list.at(i)->interface() == interface) {
            idx = i;
            break;
        }
    }
    if (idx < 0) {
        return;
    }

    beginRemoveRows(QModelIndex(), idx, idx);
    m_list.takeAt(idx)->deleteLater();
    endRemoveRows();
    emit countChanged();
}

NetworkDevice *NetworkDevices::get(int index) const
{
    if (index >= 0 && index < m_list.count()) {
        return m_list.at(index);
    }
    return nullptr;
}

NetworkDevice *NetworkDevices::getNetworkDevice(const QString &interface)
{
    foreach (NetworkDevice *p, m_list) {
        if (p->interface() == interface) {
            return p;
        }
    }
    return nullptr;
}

void NetworkDevices::clear()
{
    beginResetModel();
    qDeleteAll(m_list);
    m_list.clear();
    endResetModel();
    emit countChanged();
}

WiredNetworkDevices::WiredNetworkDevices(QObject *parent):
    NetworkDevices(parent)
{

}

QVariant WiredNetworkDevices::data(const QModelIndex &index, int role) const
{
    if (role == RolePluggedIn) {
        WiredNetworkDevice *dev = qobject_cast<WiredNetworkDevice*>(m_list.at(index.row()));
        return dev->pluggedIn();
    }
    return NetworkDevices::data(index, role);
}

void WiredNetworkDevices::addWiredNetworkDevice(WiredNetworkDevice *device)
{
    NetworkDevices::addNetworkDevice(device);
    connect(device, &WiredNetworkDevice::pluggedInChanged, [this, device](){
        emit dataChanged(index(static_cast<int>(m_list.indexOf(device))), index(static_cast<int>(m_list.indexOf(device))), {RolePluggedIn});
        emit countChanged();
    });
}

QHash<int, QByteArray> WiredNetworkDevices::roleNames() const
{
    QHash<int, QByteArray> roles = NetworkDevices::roleNames();
    roles.insert(RolePluggedIn, "pluggedIn");
    return roles;
}

WiredNetworkDevice *WiredNetworkDevices::getWiredNetworkDevice(const QString &interface)
{
    return dynamic_cast<WiredNetworkDevice*>(NetworkDevices::getNetworkDevice(interface));
}

WirelessNetworkDevices::WirelessNetworkDevices(QObject *parent):
    NetworkDevices (parent)
{

}

QVariant WirelessNetworkDevices::data(const QModelIndex &index, int role) const
{
    if (role == RoleWirelessMode) {
        WirelessNetworkDevice *dev = qobject_cast<WirelessNetworkDevice*>(m_list.at(index.row()));
        return dev->wirelessMode();
    }
    return NetworkDevices::data(index, role);
}


QHash<int, QByteArray> WirelessNetworkDevices::roleNames() const
{
    QHash<int, QByteArray> roles = NetworkDevices::roleNames();
    roles.insert(RoleWirelessMode, "wirelessMode");
    return roles;
}

WirelessNetworkDevice *WirelessNetworkDevices::getWirelessNetworkDevice(const QString &interface)
{
    return dynamic_cast<WirelessNetworkDevice*>(NetworkDevices::getNetworkDevice(interface));
}

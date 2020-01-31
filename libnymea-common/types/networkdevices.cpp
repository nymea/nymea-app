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

#include "networkdevices.h"
#include "networkdevice.h"

NetworkDevices::NetworkDevices(QObject *parent): QAbstractListModel(parent)
{

}

int NetworkDevices::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return m_list.count();
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
    return roles;
}

void NetworkDevices::addNetworkDevice(NetworkDevice *networkDevice)
{
    networkDevice->setParent(this);
    beginInsertRows(QModelIndex(), m_list.count(), m_list.count());
    m_list.append(networkDevice);
    connect(networkDevice, &NetworkDevice::bitRateChanged, this, [this, networkDevice](){
        emit dataChanged(index(m_list.indexOf(networkDevice)), index(m_list.indexOf(networkDevice)), {RoleBitRate});
        emit countChanged();
    });
    connect(networkDevice, &NetworkDevice::stateChanged, this, [this, networkDevice](){
        emit dataChanged(index(m_list.indexOf(networkDevice)), index(m_list.indexOf(networkDevice)), {RoleState});
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

void WiredNetworkDevices::addNetworkDevice(NetworkDevice *device)
{
    NetworkDevices::addNetworkDevice(device);
    WiredNetworkDevice *wiredDev = qobject_cast<WiredNetworkDevice*>(device);
    if (wiredDev) {
        connect(wiredDev, &WiredNetworkDevice::pluggedInChanged, [this, wiredDev](){
            emit dataChanged(index(m_list.indexOf(wiredDev)), index(m_list.indexOf(wiredDev)), {RolePluggedIn});
            emit countChanged();
        });
    }
}

QHash<int, QByteArray> WiredNetworkDevices::roleNames() const
{
    QHash<int, QByteArray> roles = NetworkDevices::roleNames();
    roles.insert(RolePluggedIn, "pluggedIn");
    return roles;
}

WirelessNetworkDevices::WirelessNetworkDevices(QObject *parent):
    NetworkDevices (parent)
{

}

#include <QDebug>

WirelessNetworkDevice *WirelessNetworkDevices::getWirelessNetworkDevice(const QString &interface)
{
    return dynamic_cast<WirelessNetworkDevice*>(NetworkDevices::getNetworkDevice(interface));
}

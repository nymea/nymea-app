/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *                                                                         *
 *  Copyright (C) 2015 Simon Stuerz <stuerz.simon@gmail.com>               *
 *                                                                         *
 *  This file is part of guh-ubuntu.                                       *
 *                                                                         *
 *  guh-ubuntu is free software: you can redistribute it and/or modify     *
 *  it under the terms of the GNU General Public License as published by   *
 *  the Free Software Foundation, version 3 of the License.                *
 *                                                                         *
 *  guh-ubuntu is distributed in the hope that it will be useful,          *
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of         *
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the           *
 *  GNU General Public License for more details.                           *
 *                                                                         *
 *  You should have received a copy of the GNU General Public License      *
 *  along with guh-ubuntu. If not, see <http://www.gnu.org/licenses/>.     *
 *                                                                         *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#include "upnpdiscoverymodel.h"

UpnpDiscoveryModel::UpnpDiscoveryModel(QObject *parent) :
    QAbstractListModel(parent)
{
}

QList<UpnpDevice> UpnpDiscoveryModel::devices()
{
    return m_devices;
}

int UpnpDiscoveryModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return m_devices.count();
}

QVariant UpnpDiscoveryModel::data(const QModelIndex &index, int role) const
{
    if (index.row() < 0 || index.row() >= m_devices.count())
        return QVariant();

    UpnpDevice device = m_devices.at(index.row());
    if (role == NameRole) {
        return device.friendlyName();
    } else if (role == HostAddressRole) {
        return device.hostAddress().toString();
    } else if (role == WebSocketUrlRole) {
        return device.webSocketUrl();
    } else if (role == PortRole) {
        return device.port();
    } else if (role == VersionRole) {
        return device.modelNumber();
    } else if (role == GuhRpcUrlRole) {
        return device.guhRpcUrl();
    }
    return QVariant();
}

void UpnpDiscoveryModel::addDevice(UpnpDevice device)
{
    beginInsertRows(QModelIndex(), m_devices.count(), m_devices.count());
    m_devices.append(device);
    endInsertRows();
    emit countChanged();
}

QString UpnpDiscoveryModel::get(int index, const QByteArray &role) const
{
    return data(this->index(index), roleNames().key(role)).toString();
}

bool UpnpDiscoveryModel::contains(const QString &uuid) const
{
    foreach (const UpnpDevice &dev, m_devices) {
        if (dev.uuid() == uuid) {
            return true;
        }
    }
    return false;
}

void UpnpDiscoveryModel::clearModel()
{
    beginResetModel();
    m_devices.clear();
    endResetModel();
    emit countChanged();
}

QHash<int, QByteArray> UpnpDiscoveryModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[NameRole] = "name";
    roles[HostAddressRole] = "hostAddress";
    roles[WebSocketUrlRole] = "webSocketUrl";
    roles[GuhRpcUrlRole] = "guhRpcUrl";
    roles[PortRole] = "port";
    roles[VersionRole] = "version";
    return roles;
}

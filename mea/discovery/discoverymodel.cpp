/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *                                                                         *
 *  Copyright (C) 2015 Simon Stuerz <stuerz.simon@gmail.com>               *
 *                                                                         *
 *  This file is part of mea.                                       *
 *                                                                         *
 *  mea is free software: you can redistribute it and/or modify     *
 *  it under the terms of the GNU General Public License as published by   *
 *  the Free Software Foundation, version 3 of the License.                *
 *                                                                         *
 *  mea is distributed in the hope that it will be useful,          *
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of         *
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the           *
 *  GNU General Public License for more details.                           *
 *                                                                         *
 *  You should have received a copy of the GNU General Public License      *
 *  along with mea. If not, see <http://www.gnu.org/licenses/>.     *
 *                                                                         *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#include "discoverymodel.h"

DiscoveryModel::DiscoveryModel(QObject *parent) :
    QAbstractListModel(parent)
{
}

QList<DiscoveryDevice> DiscoveryModel::devices()
{
    return m_devices;
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

    DiscoveryDevice device = m_devices.at(index.row());
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
    } else if (role == NymeaRpcUrlRole) {
        return device.nymeaRpcUrl();
    }
    return QVariant();
}

void DiscoveryModel::addDevice(const DiscoveryDevice &device)
{
    for (int i = 0; i < m_devices.count(); i++) {
        if (m_devices.at(i).uuid() == device.uuid()) {
            m_devices[i] = device;
            emit dataChanged(index(i), index(i));
            return;
        }
    }
    beginInsertRows(QModelIndex(), m_devices.count(), m_devices.count());
    m_devices.append(device);
    endInsertRows();
    emit countChanged();
}

QString DiscoveryModel::get(int index, const QByteArray &role) const
{
    return data(this->index(index), roleNames().key(role)).toString();
}

bool DiscoveryModel::contains(const QString &uuid) const
{
    foreach (const DiscoveryDevice &dev, m_devices) {
        if (dev.uuid() == uuid) {
            return true;
        }
    }
    return false;
}

DiscoveryDevice DiscoveryModel::find(const QHostAddress &address) const
{
    foreach (const DiscoveryDevice &dev, m_devices) {
        if (dev.hostAddress() == address) {
            return dev;
        }
    }
    return DiscoveryDevice();
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
    roles[NameRole] = "name";
    roles[HostAddressRole] = "hostAddress";
    roles[WebSocketUrlRole] = "webSocketUrl";
    roles[NymeaRpcUrlRole] = "nymeaRpcUrl";
    roles[PortRole] = "port";
    roles[VersionRole] = "version";
    return roles;
}

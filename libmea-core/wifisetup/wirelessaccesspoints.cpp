/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *                                                                         *
 *  Copyright (C) 2018 Simon Stuerz <simon.stuerz@guh.io>                  *
 *                                                                         *
 *  This file is part of mea                                               *
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

#include "wirelessaccesspoints.h"
#include <QDebug>

WirelessAccesspoints::WirelessAccesspoints(QObject *parent) : QAbstractListModel(parent)
{

}

QList<WirelessAccessPoint *> WirelessAccesspoints::wirelessAccessPoints()
{
    return m_wirelessAccessPoints;
}

void WirelessAccesspoints::setWirelessAccessPoints(QList<WirelessAccessPoint *> wirelessAccessPoints)
{
    beginResetModel();

    // Delete all
    qDeleteAll(m_wirelessAccessPoints);
    m_wirelessAccessPoints.clear();

    qSort(wirelessAccessPoints.begin(), wirelessAccessPoints.end(), signalStrengthLessThan);
    m_wirelessAccessPoints = wirelessAccessPoints;

    endResetModel();
    emit countChanged();
}

int WirelessAccesspoints::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return m_wirelessAccessPoints.count();
}

QVariant WirelessAccesspoints::data(const QModelIndex &index, int role) const
{
    if (index.row() < 0 || index.row() >= m_wirelessAccessPoints.count())
        return QVariant();

    WirelessAccessPoint *accessPoint = m_wirelessAccessPoints.at(index.row());
    if (role == WirelessAccesspointRoleSsid) {
        return accessPoint->ssid();
    } else if (role == WirelessAccesspointRoleMacAddress) {
        return accessPoint->macAddress();
    } else if (role == WirelessAccesspointRoleSignalStrength) {
        return accessPoint->signalStrength();
    } else if (role == WirelessAccesspointRoleProtected) {
        return accessPoint->isProtected();
    } else if (role == WirelessAccesspointRoleSelectedNetwork) {
        return accessPoint->selectedNetwork();
    }

    return QVariant();
}

int WirelessAccesspoints::count() const
{
    return m_wirelessAccessPoints.count();
}

WirelessAccessPoint *WirelessAccesspoints::get(const QString &ssid) const
{
    foreach (WirelessAccessPoint *accessPoint, m_wirelessAccessPoints) {
        if (accessPoint->ssid() == ssid)
            return accessPoint;
    }

    return Q_NULLPTR;
}

void WirelessAccesspoints::clearModel()
{
    beginResetModel();
    qDeleteAll(m_wirelessAccessPoints);
    m_wirelessAccessPoints.clear();
    endResetModel();
    emit countChanged();
}

void WirelessAccesspoints::setSelectedNetwork(const QString &ssid, const QString &macAdderss)
{
    beginResetModel();

    foreach (WirelessAccessPoint *accessPoint, m_wirelessAccessPoints) {
        if (accessPoint->ssid() == ssid && accessPoint->macAddress() == macAdderss) {
            qDebug() << "Set selected network:" << ssid << macAdderss;
            accessPoint->setSelectedNetwork(true);
        } else {
            accessPoint->setSelectedNetwork(false);
        }
    }

    // FIXME: find a better way to update network selected and resort the list
    QList<WirelessAccessPoint *> wirelessAccessPoints = m_wirelessAccessPoints;

    qSort(wirelessAccessPoints.begin(), wirelessAccessPoints.end(), signalStrengthLessThan);
    m_wirelessAccessPoints = wirelessAccessPoints;

    endResetModel();
    emit countChanged();
}

bool WirelessAccesspoints::signalStrengthLessThan(const WirelessAccessPoint *a, const WirelessAccessPoint *b)
{
    // Keep the selected network on top
    if (a->selectedNetwork())
        return true;

    return a->signalStrength() > b->signalStrength();
}

QHash<int, QByteArray> WirelessAccesspoints::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[WirelessAccesspointRoleSsid] = "ssid";
    roles[WirelessAccesspointRoleMacAddress] = "macAddress";
    roles[WirelessAccesspointRoleSignalStrength] = "signalStrength";
    roles[WirelessAccesspointRoleProtected] = "protected";
    roles[WirelessAccesspointRoleSelectedNetwork] = "selectedNetwork";
    return roles;
}



/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *                                                                         *
 *  Copyright (C) 2018 Simon Stuerz <simon.stuerz@guh.io>                  *
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

#include "wirelessaccesspointsproxy.h"

#include "wirelessaccesspoint.h"
#include "wirelessaccesspoints.h"

#include <QDebug>

WirelessAccessPointsProxy::WirelessAccessPointsProxy(QObject *parent) : QSortFilterProxyModel(parent)
{

}

WirelessAccessPoints *WirelessAccessPointsProxy::accessPoints() const
{
    return m_accessPoints;
}

void WirelessAccessPointsProxy::setAccessPoints(WirelessAccessPoints *accessPoints)
{
    m_accessPoints = accessPoints;
    emit accessPointsChanged();
    setSourceModel(m_accessPoints);
    sort(0);
    invalidate();
}

bool WirelessAccessPointsProxy::filterAcceptsRow(int source_row, const QModelIndex &source_parent) const
{
    Q_UNUSED(source_parent)

    // Filter out the current selected network
//    WirelessAccessPoint *accessPoint = m_accessPoints->get(source_row);

//    // Filter out selected network
//    if (accessPoint->selectedNetwork())
//        return false;

    return true;
}

bool WirelessAccessPointsProxy::lessThan(const QModelIndex &left, const QModelIndex &right) const
{
    WirelessAccessPoint *leftAccessPoint = m_accessPoints->get(left.row());
    WirelessAccessPoint *rightAccessPoint = m_accessPoints->get(right.row());

    if (leftAccessPoint->selectedNetwork())
        return true;

    return leftAccessPoint->signalStrength() > rightAccessPoint->signalStrength();
}

WirelessAccessPoint *WirelessAccessPointsProxy::get(int index) const
{
    return m_accessPoints->get(mapToSource(this->index(index, 0)).row());
}

void WirelessAccessPointsProxy::invokeSort()
{
    sort(0);
    invalidate();
}

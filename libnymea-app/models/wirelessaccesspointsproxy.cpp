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

#include "wirelessaccesspointsproxy.h"

#include "types/wirelessaccesspoint.h"
#include "types/wirelessaccesspoints.h"

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
    connect(accessPoints, &WirelessAccessPoints::countChanged, this, [this](){
        sort(0, Qt::DescendingOrder);
        invalidateFilter();
        emit countChanged();
    });

    setSortRole(WirelessAccessPoints::WirelessAccesspointRoleSignalStrength);
    sort(0, Qt::DescendingOrder);

    invalidateFilter();

    emit countChanged();
}

WirelessAccessPoint *WirelessAccessPointsProxy::get(int index) const
{
    return m_accessPoints->get(mapToSource(this->index(index, 0)).row());
}

bool WirelessAccessPointsProxy::showDuplicates() const
{
    return m_showDuplicates;
}

void WirelessAccessPointsProxy::setShowDuplicates(bool showDuplicates)
{
    m_showDuplicates = showDuplicates;
    emit showDuplicatesChanged();

    sort(0, Qt::DescendingOrder);
    invalidateFilter();

    emit countChanged();
}

bool WirelessAccessPointsProxy::filterAcceptsRow(int source_row, const QModelIndex &source_parent) const
{
    Q_UNUSED(source_parent)

    if (m_showDuplicates)
        return true;

    WirelessAccessPoint *accessPoint = m_accessPoints->get(source_row);
    // Check if this is the best signal strenght, otherwise filter out...
    foreach (WirelessAccessPoint *ap, m_accessPoints->wirelessAccessPoints()) {
        if (ap->ssid() == accessPoint->ssid() && ap->signalStrength() > accessPoint->signalStrength()) {
            return false;
        }
    }

    return true;
}

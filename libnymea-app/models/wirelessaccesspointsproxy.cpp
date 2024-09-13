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

// SPDX-License-Identifier: LGPL-3.0-or-later

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
* Copyright (C) 2024 - 2026, chargebyte austria GmbH
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


#include "networkinterfacesproxy.h"

NetworkInterfacesProxy::NetworkInterfacesProxy(QObject *parent):
    QSortFilterProxyModel(parent)
{
    connect(this, &QSortFilterProxyModel::rowsInserted, this, &NetworkInterfacesProxy::countChanged);
    connect(this, &QSortFilterProxyModel::rowsRemoved, this, &NetworkInterfacesProxy::countChanged);
    connect(this, &QSortFilterProxyModel::modelReset, this, &NetworkInterfacesProxy::countChanged);
    connect(this, &QSortFilterProxyModel::layoutChanged, this, &NetworkInterfacesProxy::countChanged);
}

NetworkInterfaces *NetworkInterfacesProxy::networkInterfaces() const
{
    return qobject_cast<NetworkInterfaces *>(sourceModel());
}

void NetworkInterfacesProxy::setNetworkInterfaces(NetworkInterfaces *networkInterfaces)
{
    if (sourceModel() == networkInterfaces) {
        return;
    }

    setSourceModel(networkInterfaces);
    emit networkInterfacesChanged();
    emit countChanged();
}

QStringList NetworkInterfacesProxy::hiddenKinds() const
{
    return m_hiddenKinds;
}

void NetworkInterfacesProxy::setHiddenKinds(const QStringList &hiddenKinds)
{
    if (m_hiddenKinds == hiddenKinds) {
        return;
    }

    m_hiddenKinds = hiddenKinds;
    emit hiddenKindsChanged();
    invalidateFilter();
    emit countChanged();
}

QVariantMap NetworkInterfacesProxy::get(int row) const
{
    NetworkInterfaces *interfaces = networkInterfaces();
    if (!interfaces) {
        return QVariantMap();
    }

    return interfaces->get(mapToSource(index(row, 0)).row());
}

bool NetworkInterfacesProxy::filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const
{
    const QString kind = sourceModel()->index(sourceRow, 0, sourceParent).data(NetworkInterfaces::RoleKind).toString();
    return !m_hiddenKinds.contains(kind);
}

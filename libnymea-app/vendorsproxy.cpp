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

#include "vendorsproxy.h"

#include <QDebug>

VendorsProxy::VendorsProxy(QObject *parent) : QSortFilterProxyModel(parent)
{
    setSortRole(Vendors::RoleDisplayName);
    setSortCaseSensitivity(Qt::CaseInsensitive);
}

Vendors *VendorsProxy::vendors()
{
    return m_vendors;
}

void VendorsProxy::setVendors(Vendors *vendors)
{
    if (m_vendors != vendors) {
        m_vendors = vendors;
        setSourceModel(vendors);
        emit vendorsChanged();
        connect(m_vendors, &Vendors::countChanged, this, &VendorsProxy::countChanged);
        sort(0);
    }
}

Vendor *VendorsProxy::get(int index) const
{
    return m_vendors->get(mapToSource(this->index(index, 0)).row());
}



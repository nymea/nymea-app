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



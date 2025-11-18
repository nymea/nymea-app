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

#ifndef VENDORSPROXY_H
#define VENDORSPROXY_H

#include <QObject>
#include <QSortFilterProxyModel>

#include "types/vendors.h"

class VendorsProxy : public QSortFilterProxyModel
{
    Q_OBJECT
    Q_PROPERTY(Vendors *vendors READ vendors WRITE setVendors NOTIFY vendorsChanged)
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)

public:
    explicit VendorsProxy(QObject *parent = nullptr);

    Vendors *vendors();
    void setVendors(Vendors *vendors);

    Q_INVOKABLE Vendor* get(int index) const;

signals:
    void vendorsChanged();
    void countChanged();

private:
    Vendors *m_vendors;

};

#endif // VENDORSPROXY_H

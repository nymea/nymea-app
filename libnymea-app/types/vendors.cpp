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

#include "vendors.h"

#include <QDebug>

Vendors::Vendors(QObject *parent) :
    QAbstractListModel(parent)
{
}

int Vendors::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return static_cast<int>(m_vendors.count());
}

QVariant Vendors::data(const QModelIndex &index, int role) const
{
    if (index.row() < 0 || index.row() >= m_vendors.count())
        return QVariant();

    Vendor *vendor = m_vendors.at(index.row());
    switch (role) {
    case RoleName:
        return vendor->name();
    case RoleDisplayName:
        return vendor->displayName();
    case RoleId:
        return vendor->id();
    }
    return QVariant();
}

void Vendors::addVendor(Vendor *vendor)
{
    vendor->setParent(this);
    beginInsertRows(QModelIndex(), static_cast<int>(m_vendors.count()), static_cast<int>(m_vendors.count()));
    //qDebug() << "Vendors: loaded vendor" << vendor->name();
    m_vendors.append(vendor);
    endInsertRows();
    emit countChanged();
}

void Vendors::clearModel()
{
    beginResetModel();
    qDeleteAll(m_vendors);
    m_vendors.clear();
    endResetModel();
    emit countChanged();
}

Vendor *Vendors::get(int index) const
{
    if (index < 0 || index >= m_vendors.count()) {
        return nullptr;
    }
    return m_vendors.at(index);
}

Vendor *Vendors::getVendor(const QUuid &vendorId) const
{
    foreach (Vendor *vendor, m_vendors) {
        if (vendor->id() == vendorId) {
            return vendor;
        }
    }
    return nullptr;
}

QHash<int, QByteArray> Vendors::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[RoleId] = "id";
    roles[RoleName] = "name";
    roles[RoleDisplayName] = "displayName";
    return roles;
}

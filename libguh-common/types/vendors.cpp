/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *                                                                         *
 *  Copyright (C) 2017 Simon Stuerz <simon.stuerz@guh.io>                  *
 *                                                                         *
 *  This file is part of guh-control                                       *
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

#include "vendors.h"

#include <QDebug>

Vendors::Vendors(QObject *parent) :
    QAbstractListModel(parent)
{
}

QList<Vendor *> Vendors::vendors()
{
    return m_vendors;
}

int Vendors::count() const
{
    return m_vendors.count();
}

Vendor *Vendors::getVendor(const QUuid &vendorId) const
{
    foreach (Vendor *vendor, m_vendors) {
        if (vendor->id() == vendorId) {
            return vendor;
        }
    }
    return 0;
}

int Vendors::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return m_vendors.count();
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
        return vendor->id().toString();
    }
    return QVariant();
}

void Vendors::addVendor(Vendor *vendor)
{
    beginInsertRows(QModelIndex(), m_vendors.count(), m_vendors.count());
    //qDebug() << "Vendors: loaded vendor" << vendor->name();
    m_vendors.append(vendor);
    endInsertRows();
}

void Vendors::clearModel()
{
    beginResetModel();
    qDebug() << "Vendors: delete all vendors";
    qDeleteAll(m_vendors);
    m_vendors.clear();
    endResetModel();
}

QHash<int, QByteArray> Vendors::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[RoleId] = "id";
    roles[RoleName] = "name";
    roles[RoleDisplayName] = "displayName";
    return roles;
}

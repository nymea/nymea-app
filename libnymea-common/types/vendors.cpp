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

#include "vendors.h"

#include <QDebug>

Vendors::Vendors(QObject *parent) :
    QAbstractListModel(parent)
{
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
        return vendor->id();
    }
    return QVariant();
}

void Vendors::addVendor(Vendor *vendor)
{
    vendor->setParent(this);
    beginInsertRows(QModelIndex(), m_vendors.count(), m_vendors.count());
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

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

#ifndef VENDORMODEL_H
#define VENDORMODEL_H

#include <QAbstractListModel>

#include "vendor.h"

class Vendors : public QAbstractListModel
{
    Q_OBJECT
public:
    enum Role {
        RoleId,
        RoleName,
        RoleDisplayName
    };

    explicit Vendors(QObject *parent = 0);

    QList<Vendor *> vendors();

    Q_INVOKABLE int count() const;
    Q_INVOKABLE Vendor *getVendor(const QUuid &vendorId) const;

    int rowCount(const QModelIndex & parent = QModelIndex()) const;
    QVariant data(const QModelIndex & index, int role = Qt::DisplayRole) const;

    void addVendor(Vendor *vendor);

    void clearModel();

protected:
    QHash<int, QByteArray> roleNames() const;

private:
    QList<Vendor *> m_vendors;

};

#endif // VENDORMODEL_H

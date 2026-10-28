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

#ifndef NETWORKINTERFACES_H
#define NETWORKINTERFACES_H

#include <QAbstractListModel>
#include <QVariantList>

class NetworkInterfaces : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)

public:
    enum Roles {
        RoleIndex = Qt::UserRole,
        RoleName,
        RoleKind,
        RoleMacAddress,
        RoleAdministrativeState,
        RoleOperationalState,
        RoleManagementStatus,
        RoleIpv4Addresses,
        RoleIpv6Addresses
    };
    Q_ENUM(Roles)

    explicit NetworkInterfaces(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

    Q_INVOKABLE QVariantMap get(int row) const;

    // Replaces the content with a complete snapshot, keeping rows of unchanged interfaces in place
    void applySnapshot(const QVariantList &interfaces);
    void clear();

signals:
    void countChanged();

private:
    QVariantMap normalize(const QVariantMap &entry) const;
    QString key(const QVariantMap &entry) const;

    QList<QVariantMap> m_interfaces;
};

#endif // NETWORKINTERFACES_H

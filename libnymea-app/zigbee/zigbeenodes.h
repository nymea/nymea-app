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

#ifndef ZIGBEENODES_H
#define ZIGBEENODES_H

#include <QObject>
#include <QAbstractListModel>

#include "zigbeenode.h"

class ZigbeeNodes : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)

public:
    enum Roles {
        RoleNetworkUuid,
        RoleIeeeAddress,
        RoleNetworkAddress,
        RoleType,
        RoleState,
        RoleManufacturer,
        RoleModel,
        RoleVersion,
        RoleRxOnWhenIdle,
        RoleReachable,
        RoleLqi,
        RoleLastSeen
    };
    Q_ENUM(Roles)

    explicit ZigbeeNodes(QObject *parent = nullptr);
    virtual ~ZigbeeNodes() override = default;

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

    void addNode(ZigbeeNode *node);
    void removeNode(const QString &ieeeAddress);

    void clear();

    Q_INVOKABLE virtual ZigbeeNode *get(int index) const;
    Q_INVOKABLE ZigbeeNode *getNode(const QString &ieeeAddress) const;
    Q_INVOKABLE ZigbeeNode *getNodeByNetworkAddress(quint16 networkAddress) const;

signals:
    void countChanged();
    void nodeAdded(ZigbeeNode *node);
    void nodeRemoved(const QString &ieeeAddress);

protected:
    QList<ZigbeeNode *> m_nodes;

};

Q_DECLARE_METATYPE(ZigbeeNodes*)

#endif // ZIGBEENODES_H

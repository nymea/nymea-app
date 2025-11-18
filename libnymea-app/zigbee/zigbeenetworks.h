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

#ifndef ZIGBEENETWORKS_H
#define ZIGBEENETWORKS_H

#include <QObject>
#include <QAbstractListModel>

#include "zigbeenetwork.h"

class ZigbeeNetworks : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)

public:
    enum Roles {
        RoleUuid,
        RoleSerialPort,
        RoleBaudRate,
        RoleMacAddress,
        RoleFirmwareVersion,
        RolePanId,
        RoleChannel,
        RoleChannelMask,
        RolePermitJoiningEnabled,
        RolePermitJoiningDuration,
        RolePermitJoiningRemaining,
        RoleBackend,
        RoleNetworkState
    };
    Q_ENUM(Roles)

    explicit ZigbeeNetworks(QObject *parent = nullptr);
    virtual ~ZigbeeNetworks() override = default;

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

    void addNetwork(ZigbeeNetwork *network);
    void removeNetwork(const QUuid &networkUuid);

    void clear();

    Q_INVOKABLE virtual ZigbeeNetwork *get(int index) const;
    Q_INVOKABLE ZigbeeNetwork *getNetwork(const QUuid &networkUuid) const;
    ZigbeeNetwork *findBySerialPort(const QString &serialPort) const;

signals:
    void countChanged();

protected:
    QList<ZigbeeNetwork *> m_networks;

};

#endif // ZIGBEENETWORKS_H

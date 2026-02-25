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

#ifndef NETWORKDEVICES_H
#define NETWORKDEVICES_H

#include <QAbstractListModel>

class NetworkDevice;
class WiredNetworkDevice;
class WirelessNetworkDevice;

class NetworkDevices: public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)
public:
    enum Roles {
        RoleMacAddress,
        RoleInterface,
        RoleBitRate,
        RoleState,
        RoleIpv4Addresses,
        RoleIpv6Addresses,
        RolePluggedIn
    };
    Q_ENUM(Roles)

    explicit NetworkDevices(QObject *parent = nullptr);
    virtual ~NetworkDevices() override = default;

    virtual int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    virtual QHash<int, QByteArray> roleNames() const override;

    virtual void addNetworkDevice(NetworkDevice *networkDevice);
    void removeNetworkDevice(const QString &interface);

    Q_INVOKABLE virtual NetworkDevice* get(int index) const;
    Q_INVOKABLE virtual NetworkDevice* getNetworkDevice(const QString &interface);

    void clear();

signals:
    void countChanged();

protected:
    QList<NetworkDevice*> m_list;
};

class WiredNetworkDevices: public NetworkDevices
{
    Q_OBJECT
public:
    enum Roles {
        RolePluggedIn = 1000
    };

    explicit WiredNetworkDevices(QObject *parent = nullptr);
    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

    void addWiredNetworkDevice(WiredNetworkDevice *device);

    Q_INVOKABLE WiredNetworkDevice* getWiredNetworkDevice(const QString &interface);

};

class WirelessNetworkDevices: public NetworkDevices
{
    Q_OBJECT
public:
    enum Roles {
        RoleWirelessMode = 1000
    };
    explicit WirelessNetworkDevices(QObject *parent = nullptr);

    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

    Q_INVOKABLE WirelessNetworkDevice* getWirelessNetworkDevice(const QString &interface);

};

#endif // NETWORKDEVICES_H

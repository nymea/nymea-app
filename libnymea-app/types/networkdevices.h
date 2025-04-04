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

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

#ifndef DEVICES_H
#define DEVICES_H

#include <QAbstractListModel>

#include "types/device.h"
#include "types/deviceclass.h"

class Devices : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)
public:
    enum Roles {
        RoleName,
        RoleId,
        RoleParentDeviceId,
        RoleDeviceClass,
        RoleSetupStatus,
        RoleInterfaces,
        RoleBaseInterface
    };
    Q_ENUM(Roles)

    explicit Devices(QObject *parent = nullptr);

    QList<Device *> devices();

    Q_INVOKABLE Device *get(int index) const;
    Q_INVOKABLE Device *getDevice(const QUuid &deviceId) const;

    int rowCount(const QModelIndex & parent = QModelIndex()) const;
    QVariant data(const QModelIndex & index, int role = RoleName) const;

    void addDevice(Device *device);
    void removeDevice(Device *device);

    void clearModel();

protected:
    QHash<int, QByteArray> roleNames() const;

signals:
    void countChanged();

private:
    QList<Device *> m_devices;

};

#endif // DEVICES_H

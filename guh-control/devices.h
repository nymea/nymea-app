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

#ifndef DEVICES_H
#define DEVICES_H

#include <QAbstractListModel>

#include "types/device.h"
#include "types/deviceclass.h"

class Devices : public QAbstractListModel
{
    Q_OBJECT
public:
    enum Roles {
        RoleName,
        RoleDeviceName,
        RoleId,
        RoleDeviceClass,
        RoleSetupComplete,
        RoleBasicTag,
        RoleInterfaces
    };
    Q_ENUM(Roles)

    explicit Devices(QObject *parent = 0);

    QList<Device *> devices();

    Q_INVOKABLE int count() const;
    Q_INVOKABLE Device *get(int index) const;
    Q_INVOKABLE Device *getDevice(const QUuid &deviceId) const;

    int rowCount(const QModelIndex & parent = QModelIndex()) const;
    QVariant data(const QModelIndex & index, int role = RoleName) const;

    void addDevice(Device *device);
    void removeDevice(Device *device);

    void clearModel();

    DeviceClass::BasicTags basicTags() const;

protected:
    QHash<int, QByteArray> roleNames() const;

private:
    QList<Device *> m_devices;

};

#endif // DEVICES_H

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *                                                                         *
 *  Copyright (C) 2017 Simon Stuerz <simon.stuerz@guh.io>                  *
 *                                                                         *
 *  This file is part of guh-control.                                      *
 *                                                                         *
 *  guh-control is free software: you can redistribute it and/or modify    *
 *  it under the terms of the GNU General Public License as published by   *
 *  the Free Software Foundation, version 3 of the License.                *
 *                                                                         *
 *  guh-control is distributed in the hope that it will be useful,         *
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of         *
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the           *
 *  GNU General Public License for more details.                           *
 *                                                                         *
 *  You should have received a copy of the GNU General Public License      *
 *  along with guh-control. If not, see <http://www.gnu.org/licenses/>.    *
 *                                                                         *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#ifndef DEVICEMANAGER_H
#define DEVICEMANAGER_H

#include <QObject>

#include "types/vendors.h"
#include "devices.h"
#include "deviceclasses.h"
#include "types/plugins.h"

class DeviceManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(Vendors *vendors READ vendors CONSTANT)
    Q_PROPERTY(Plugins *plugins READ plugins CONSTANT)
    Q_PROPERTY(Devices *devices READ devices CONSTANT)
    Q_PROPERTY(DeviceClasses *deviceClasses READ deviceClasses CONSTANT)

public:
    explicit DeviceManager(QObject *parent = 0);

    Vendors *vendors() const;
    Plugins *plugins() const;
    Devices *devices() const;
    DeviceClasses *deviceClasses() const;

private:
    Vendors *m_vendors;
    Plugins *m_plugins;
    Devices *m_devices;
    DeviceClasses *m_deviceClasses;

};

#endif // DEVICEMANAGER_H

// SPDX-License-Identifier: GPL-3.0-or-later

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
* Copyright (C) 2013 - 2024, nymea GmbH
* Copyright (C) 2024 - 2025, chargebyte austria GmbH
*
* This file is part of nymea-app.
*
* nymea-app is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* nymea-app is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with nymea-app. If not, see <https://www.gnu.org/licenses/>.
*
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#ifndef PLATFORMPERMISSIONSIOS_H
#define PLATFORMPERMISSIONSIOS_H

#include <QObject>

#include "../platformpermissions.h"

#if __OBJC__
@class CLLocationManager;
@class CBCentralManager;
#else
typedef void CLLocationManager;
typedef void CBCentralManager;
#endif

class PlatformPermissionsIOS : public PlatformPermissions
{
    Q_OBJECT
public:
    explicit PlatformPermissionsIOS(QObject *parent = nullptr);
    static PlatformPermissionsIOS *instance();

    PermissionStatus checkPermission(Permission permission) const override;
    void requestPermission(Permission permission) override;
    void openPermissionSettings() override;

private:
    void initObjC();
    void refreshNotificationsPermission();

    static PlatformPermissionsIOS *s_instance;

    PermissionStatus checkLocalNetworkPermission() const;
    PermissionStatus checkBluetoothPermission() const;
    PermissionStatus checkLocationPermission() const;
    PermissionStatus checkBackgroundLocationPermission() const;

    void requestLocalNetworkPermission();
    void requestNotificationPermission();
    void requestBluetoothPermission();
    void requestLocationPermission();
    void requestBackgroundLocationPermission();

    PermissionStatus m_notificationPermissions = PermissionStatusNotDetermined;


    CLLocationManager *m_locationManager = nullptr;
    CBCentralManager *m_bluetoothManager = nullptr;
};

#endif // PLATFORMPERMISSIONSIOS_H

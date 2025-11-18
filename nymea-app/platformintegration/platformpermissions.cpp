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

#include "platformpermissions.h"

#ifdef Q_OS_ANDROID
#include "android/platformpermissionsandroid.h"
#elif defined Q_OS_IOS
#include "ios/platformpermissionsios.h"
#endif

PlatformPermissions *PlatformPermissions::instance()
{
#ifdef Q_OS_ANDROID
    return new PlatformPermissionsAndroid();
#elif defined Q_OS_IOS
    return new PlatformPermissionsIOS();
#else
    return new PlatformPermissions();
#endif
}


PlatformPermissions::PlatformPermissions(QObject *parent)
    : QObject{parent}
{

}

QObject *PlatformPermissions::qmlProvider(QQmlEngine *engine, QJSEngine *scriptEngine)
{
    Q_UNUSED(engine)
    Q_UNUSED(scriptEngine)
    return instance();
}

PlatformPermissions::PermissionStatus PlatformPermissions::localNetworkPermission() const
{
    return checkPermission(PermissionLocalNetwork);
}

PlatformPermissions::PermissionStatus PlatformPermissions::bluetoothPermission() const
{
    return checkPermission(PermissionBluetooth);
}

PlatformPermissions::PermissionStatus PlatformPermissions::locationPermission() const
{
    return checkPermission(PermissionLocation);
}

PlatformPermissions::PermissionStatus PlatformPermissions::backgroundLocationPermission() const
{
    return checkPermission(PermissionBackgroundLocation);
}

PlatformPermissions::PermissionStatus PlatformPermissions::notificationsPermission() const
{
    return checkPermission(PermissionNotifications);
}

PlatformPermissions::PermissionStatus PlatformPermissions::checkPermission(Permission permission) const
{
    Q_UNUSED(permission)
    return PermissionStatusGranted;
}


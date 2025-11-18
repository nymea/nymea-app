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

#include "platformpermissionsios.h"

#include <QSettings>
#include <QApplication>

PlatformPermissionsIOS *PlatformPermissionsIOS::s_instance = nullptr;

PlatformPermissionsIOS::PlatformPermissionsIOS(QObject *parent)
    : PlatformPermissions{parent}
{
    s_instance = this;
    initObjC();

    connect(qApp, &QApplication::applicationStateChanged, this, [this](Qt::ApplicationState state){
        if (state == Qt::ApplicationActive) {
            refreshNotificationsPermission();
        }
    });
}

PlatformPermissionsIOS *PlatformPermissionsIOS::instance()
{
    return s_instance;
}

PlatformPermissions::PermissionStatus PlatformPermissionsIOS::checkPermission(Permission permission) const
{
    switch (permission) {
    case PermissionLocalNetwork:
        return checkLocalNetworkPermission();
    case PermissionNotifications:
        return m_notificationPermissions;
    case PermissionBackgroundLocation:
        return checkBackgroundLocationPermission();
    case PermissionLocation:
        return checkLocationPermission();
    case PermissionBluetooth:
        return checkBluetoothPermission();
    default:
        return  PermissionStatusGranted;
    }
}

void PlatformPermissionsIOS::requestPermission(Permission permission)
{
    switch (permission) {
    case PermissionLocalNetwork:
        requestLocalNetworkPermission();
        break;
    case PermissionNotifications:
        requestNotificationPermission();
        break;
    case PermissionBackgroundLocation:
        requestBackgroundLocationPermission();
        break;
    case PermissionLocation:
        requestLocationPermission();
        break;
    case PermissionBluetooth:
        requestBluetoothPermission();
        break;
    }
}

PlatformPermissions::PermissionStatus PlatformPermissionsIOS::checkLocalNetworkPermission() const
{
    QSettings settings;
    return settings.value("askedForLocalNetworkPermission", false).toBool() ? PermissionStatusGranted : PermissionStatusNotDetermined;
}

void PlatformPermissionsIOS::requestLocalNetworkPermission()
{
    QSettings settings;
    settings.setValue("askedForLocalNetworkPermission", true);
    emit localNetworkPermissionChanged();
}

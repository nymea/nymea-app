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
#include <QPermission>
#include <QBluetoothPermission>

#include "platformpermissionsiossettings.h"
#include "logging.h"
NYMEA_LOGGING_CATEGORY(dcPlatformPermissions, "PlatformPermissions")

PlatformPermissionsIOS *PlatformPermissionsIOS::s_instance = nullptr;

PlatformPermissionsIOS::PlatformPermissionsIOS(QObject *parent)
    : PlatformPermissions{parent}
{
    s_instance = this;
    initObjC();

    QSettings settings;
    const auto localNetworkPermissionState = PlatformPermissionsIOSSettings::localNetworkPermissionState(settings);
    m_localNetworkPermission = localNetworkPermissionState.status;
    m_localNetworkPermissionNeedsRevalidation = localNetworkPermissionState.needsNativeRevalidation;

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
        return PermissionStatusGranted;
    }
}

void PlatformPermissionsIOS::requestPermission(Permission platformPermission)
{
    switch (platformPermission) {
    case PermissionNone:
        break;
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
    return m_localNetworkPermission;
}

void PlatformPermissionsIOS::requestLocalNetworkPermission()
{
    if (m_localNetworkPermission == PermissionStatusGranted && !m_localNetworkPermissionNeedsRevalidation) {
        qCDebug(dcPlatformPermissions()) << "Local network permission already granted.";
        return;
    }

    qCDebug(dcPlatformPermissions()) << "Requesting local network permission...";
    requestLocalNetworkPermissionNative();
}

void PlatformPermissionsIOS::setLocalNetworkPermissionStatus(PermissionStatus status)
{
    const bool changed = m_localNetworkPermission != status;
    if (!changed && !m_localNetworkPermissionNeedsRevalidation) {
        return;
    }

    m_localNetworkPermission = status;
    m_localNetworkPermissionNeedsRevalidation = false;
    QSettings settings;
    PlatformPermissionsIOSSettings::setLocalNetworkPermissionStatus(settings, status);
    if (changed) {
        emit localNetworkPermissionChanged();
    }
}

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

#include "platformpermissionsandroid.h"

#include <QDebug>
#include <QApplication>
#include <QBluetoothPermission>
#include <QLocationPermission>
#include <QPermission>
#include <QOperatingSystemVersion>
#include <QFuture>
#include <QtCore/private/qandroidextras_p.h>

#include "logging.h"
NYMEA_LOGGING_CATEGORY(dcPlatformPermissions, "PlatformPermissions")

PlatformPermissionsAndroid * PlatformPermissionsAndroid::s_instance = nullptr;

#define FLAG_ACTIVITY_NEW_TASK 0x10000000

PlatformPermissionsAndroid::PlatformPermissionsAndroid(QObject *parent)
    : PlatformPermissions{parent}
{
    s_instance = this;
    // If the user switches to the settings app and changes permission settings there, we won't get notified
    // in any way, so let's just refresh when we become active
    connect(qApp, &QApplication::applicationStateChanged, this, [this](Qt::ApplicationState state){
        if (state == Qt::ApplicationActive) {
            emit bluetoothPermissionChanged();
            emit locationPermissionChanged();
            emit backgroundLocationPermissionChanged();
            emit notificationsPermissionChanged();
        }
    });

}

PlatformPermissions::PermissionStatus PlatformPermissionsAndroid::checkPermission(Permission platformPermission) const
{
    PermissionStatus status = PermissionStatusGranted;
    qCDebug(dcPlatformPermissions()) << "Checking permission" << platformPermission;

    switch (platformPermission) {
    case PlatformPermissions::PermissionBluetooth: {
        QBluetoothPermission permission;
        // Only request scan/connect access; advertising isn't needed and isn't declared in the manifest.
        permission.setCommunicationModes(QBluetoothPermission::Access);

        const auto permissionStatus = qApp->checkPermission(permission);

        switch (permissionStatus) {
        case Qt::PermissionStatus::Granted:
            qCDebug(dcPlatformPermissions()) << "Bluetooth permission already granted.";
            status = PermissionStatusGranted;
            break;
        case Qt::PermissionStatus::Denied:
            qCDebug(dcPlatformPermissions()) << "Bluetooth permission denied.";
            status = PermissionStatusDenied;
            break;
        case Qt::PermissionStatus::Undetermined:
            qCDebug(dcPlatformPermissions()) << "Bluetooth permission not yet requested. Requesting...";
            qApp->requestPermission(permission, [](const QPermission &perm){
                if (perm.status() == Qt::PermissionStatus::Granted)
                    qCDebug(dcPlatformPermissions()) << "Bluetooth permission granted after request.";
                else
                    qCDebug(dcPlatformPermissions()) << "Bluetooth permission denied after request.";
            });
            status = PermissionStatusNotDetermined;
            break;
        }

        // Some Android/Qt stacks still gate BLE scans on location permission; ensure it is present alongside bluetooth.
        if (status != PermissionStatusDenied) {
            QLocationPermission locationPermission;
            locationPermission.setAccuracy(QLocationPermission::Precise);
            const auto locationStatus = qApp->checkPermission(locationPermission);
            switch (locationStatus) {
            case Qt::PermissionStatus::Granted:
                break;
            case Qt::PermissionStatus::Denied:
                qCWarning(dcPlatformPermissions()) << "Location permission denied but required for bluetooth scanning.";
                status = PermissionStatusDenied;
                break;
            case Qt::PermissionStatus::Undetermined:
                qCDebug(dcPlatformPermissions()) << "Location permission not yet requested but required for bluetooth scanning.";
                status = PermissionStatusNotDetermined;
                break;
            }
        }
        break;
    }
    case PlatformPermissions::PermissionLocalNetwork: {
        if (QOperatingSystemVersion::current() < QOperatingSystemVersion(QOperatingSystemVersion::Android, 13)) {
            status = PermissionStatusGranted;
            break;
        }

        const auto permissionResult = QtAndroidPrivate::checkPermission("android.permission.NEARBY_WIFI_DEVICES").result();
        switch (permissionResult) {
        case QtAndroidPrivate::Authorized:
            qCDebug(dcPlatformPermissions()) << "Local network permission already granted.";
            status = PermissionStatusGranted;
            break;
        case QtAndroidPrivate::Denied:
            qCDebug(dcPlatformPermissions()) << "Local network permission denied.";
            status = PermissionStatusDenied;
            break;
        case QtAndroidPrivate::Undetermined:
            qCDebug(dcPlatformPermissions()) << "Local network permission not yet requested.";
            status = PermissionStatusNotDetermined;
            break;
        }
        break;
    }
    case PlatformPermissions::PermissionLocation: {
        QLocationPermission permission;
        permission.setAccuracy(QLocationPermission::Precise);

        const auto permissionStatus = qApp->checkPermission(permission);

        switch (permissionStatus) {
        case Qt::PermissionStatus::Granted:
            qCDebug(dcPlatformPermissions()) << "Location permission already granted.";
            status = PermissionStatusGranted;
            break;
        case Qt::PermissionStatus::Denied:
            qCDebug(dcPlatformPermissions()) << "Location permission denied.";
            status = PermissionStatusDenied;
            break;
        case Qt::PermissionStatus::Undetermined:
            qCDebug(dcPlatformPermissions()) << "Location permission not yet requested.";
            status = PermissionStatusNotDetermined;
            break;
        }
        break;
    }
    case PlatformPermissions::PermissionBackgroundLocation: {
        if (QOperatingSystemVersion::current() < QOperatingSystemVersion(QOperatingSystemVersion::Android, 10)) {
            // No dedicated background permission; use foreground status instead.
            return checkPermission(PermissionLocation);
        }

        const auto permissionResult = QtAndroidPrivate::checkPermission("android.permission.ACCESS_BACKGROUND_LOCATION").result();
        switch (permissionResult) {
        case QtAndroidPrivate::Authorized:
            qCDebug(dcPlatformPermissions()) << "Background location permission already granted.";
            status = PermissionStatusGranted;
            break;
        case QtAndroidPrivate::Denied:
            qCDebug(dcPlatformPermissions()) << "Background location permission denied.";
            status = PermissionStatusDenied;
            break;
        case QtAndroidPrivate::Undetermined:
            qCDebug(dcPlatformPermissions()) << "Background location permission not yet requested.";
            status = PermissionStatusNotDetermined;
            break;
        }
        break;
    }
    case PlatformPermissions::PermissionNotifications: {
        if (QOperatingSystemVersion::current() < QOperatingSystemVersion(QOperatingSystemVersion::Android, 13)) {
            status = PermissionStatusGranted;
            break;
        }

        auto futureResult = QtAndroidPrivate::checkPermission("android.permission.POST_NOTIFICATIONS");
        QtAndroidPrivate::PermissionResult result = futureResult.result();
        switch (result) {
        case QtAndroidPrivate::Authorized:
            qCDebug(dcPlatformPermissions()) << "Notifications permission already granted.";
            status = PermissionStatusGranted;
            break;
        case QtAndroidPrivate::Denied:
            qCDebug(dcPlatformPermissions()) << "Notifications permission denied.";
            status = PermissionStatusDenied;
            break;
        case QtAndroidPrivate::Undetermined:
            qCDebug(dcPlatformPermissions()) << "Notifications permission not yet requested. Requesting...";
            status = PermissionStatusNotDetermined;
            break;
        }
        break;
    }
    default:
        qCWarning(dcPlatformPermissions()) << "Requested status of platform permission" << platformPermission << "but is not implemented yet.";
        break;
    }
    return status;
}

void PlatformPermissionsAndroid::requestPermission(PlatformPermissions::Permission platformPermission)
{
    switch (platformPermission) {
    case PlatformPermissions::PermissionBluetooth: {
        qCDebug(dcPlatformPermissions()) << "Requesting bluetooth permission";
        {
            QBluetoothPermission permission;
            permission.setCommunicationModes(QBluetoothPermission::Access);
            qApp->requestPermission(permission, [platformPermission](const QPermission &permission) {
                if (permission.status() == Qt::PermissionStatus::Denied) {
                    qCWarning(dcPlatformPermissions()) << "Bluetooth permission denied.";
                    s_instance->m_requestedButDeniedPermissions.append(platformPermission);
                }

                if (permission.status() == Qt::PermissionStatus::Granted)
                    qCDebug(dcPlatformPermissions()) << "Bluetooth permission granted.";

                emit s_instance->bluetoothPermissionChanged();
            });
        }

        QLocationPermission locationPermission;
        locationPermission.setAccuracy(QLocationPermission::Precise);
        const auto locationStatus = qApp->checkPermission(locationPermission);
        if (locationStatus != Qt::PermissionStatus::Granted) {
            qCDebug(dcPlatformPermissions()) << "Requesting location permission needed for bluetooth scanning on this Android version.";
            qApp->requestPermission(locationPermission, [platformPermission](const QPermission &permission) {
                if (permission.status() == Qt::PermissionStatus::Denied) {
                    qCWarning(dcPlatformPermissions()) << "Location permission denied.";
                    s_instance->m_requestedButDeniedPermissions.append(platformPermission);
                }

                if (permission.status() == Qt::PermissionStatus::Granted)
                    qCDebug(dcPlatformPermissions()) << "Location permission granted.";

                emit s_instance->locationPermissionChanged();
                emit s_instance->bluetoothPermissionChanged();
            });
        }
        break;
    }
    case PlatformPermissions::PermissionLocation: {
        QLocationPermission locationPermission;
        locationPermission.setAccuracy(QLocationPermission::Precise);
        qApp->requestPermission(locationPermission, [platformPermission](const QPermission &permission) {
            if (permission.status() == Qt::PermissionStatus::Denied) {
                qCWarning(dcPlatformPermissions()) << "Location permission denied.";
                s_instance->m_requestedButDeniedPermissions.append(platformPermission);
            }

            if (permission.status() == Qt::PermissionStatus::Granted)
                qCDebug(dcPlatformPermissions()) << "Location permission granted.";

            emit s_instance->locationPermissionChanged();
        });
        break;
    }
    case PlatformPermissions::PermissionBackgroundLocation: {
        if (QOperatingSystemVersion::current() < QOperatingSystemVersion(QOperatingSystemVersion::Android, 10)) {
            emit s_instance->backgroundLocationPermissionChanged();
            break;
        }

        auto permissionRequest = QtAndroidPrivate::requestPermission("android.permission.ACCESS_BACKGROUND_LOCATION");
        permissionRequest.then(qApp, [platformPermission](QtAndroidPrivate::PermissionResult result) {
            switch(result) {
            case QtAndroidPrivate::Undetermined:
                qWarning() << "Permission for background location undetermined!";
                s_instance->m_requestedButDeniedPermissions.append(platformPermission);
                break;
            case QtAndroidPrivate::Authorized:
                qDebug() << "Permission for background location authorized";
                break;
            case QtAndroidPrivate::Denied:
                qWarning() << "Permission for background location denied!";
                s_instance->m_requestedButDeniedPermissions.append(platformPermission);
                break;
            }
            emit s_instance->backgroundLocationPermissionChanged();
        });
        break;
    }
    case PlatformPermissions::PermissionLocalNetwork: {
        auto permissionRequest = QtAndroidPrivate::requestPermission("android.permission.NEARBY_WIFI_DEVICES");
        permissionRequest.then(qApp, [platformPermission](QtAndroidPrivate::PermissionResult result) {
            switch(result) {
            case QtAndroidPrivate::Undetermined:
                qWarning() << "Permission for local network undetermined!";
                s_instance->m_requestedButDeniedPermissions.append(platformPermission);
                break;
            case QtAndroidPrivate::Authorized:
                qDebug() << "Permission for local network authorized";
                break;
            case QtAndroidPrivate::Denied:
                qWarning() << "Permission for local network denied!";
                s_instance->m_requestedButDeniedPermissions.append(platformPermission);
                break;
            }
            emit s_instance->localNetworkPermissionChanged();
        });
        break;
    }
    case PlatformPermissions::PermissionNotifications: {
        if (QOperatingSystemVersion::current() < QOperatingSystemVersion(QOperatingSystemVersion::Android, 13)) {
            qCDebug(dcPlatformPermissions()) << "Notifications permission implicitly granted on Android < 13.";
            emit s_instance->notificationsPermissionChanged();
            break;
        }

        auto permissionRequest = QtAndroidPrivate::requestPermission("android.permission.POST_NOTIFICATIONS");
        permissionRequest.then(qApp, [platformPermission](QtAndroidPrivate::PermissionResult result) {
            switch(result) {
            case QtAndroidPrivate::Undetermined:
                qWarning() << "Permission for posting notifications undetermined!";
                s_instance->m_requestedButDeniedPermissions.append(platformPermission);
                break;
            case QtAndroidPrivate::Authorized:
                qDebug() << "Permission for posting notifications authorized";
                break;
            case QtAndroidPrivate::Denied:
                qWarning() << "Permission for posting notifications denied!";
                s_instance->m_requestedButDeniedPermissions.append(platformPermission);
                break;
            }
            emit s_instance->notificationsPermissionChanged();
        });
        break;
    }
    default:
        qCWarning(dcPlatformPermissions()) << "Requested platform permission" << platformPermission << "but is not implemented yet.";
        break;
    }
}

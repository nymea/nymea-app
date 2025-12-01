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

        // Status prüfen
        auto status = qApp->checkPermission(permission);

        switch (status) {
        case Qt::PermissionStatus::Granted:
            qCDebug(dcPlatformPermissions()) << "Bluetooth permission already granted.";
            break;
        case Qt::PermissionStatus::Denied:
            qCDebug(dcPlatformPermissions()) << "Bluetooth permission denied.";
            break;
        case Qt::PermissionStatus::Undetermined:
            qCDebug(dcPlatformPermissions()) << "Bluetooth permission not yet requested. Requesting...";
            qApp->requestPermission(permission, [](const QPermission &perm){
                if (perm.status() == Qt::PermissionStatus::Granted)
                    qCDebug(dcPlatformPermissions()) << "Bluetooth permission granted after request.";
                else
                    qCDebug(dcPlatformPermissions()) << "Bluetooth permission denied after request.";
            });
            break;
        }
        break;
    }
    case PlatformPermissions::PermissionLocalNetwork: {
        QLocationPermission permission;
        permission.setAccuracy(QLocationPermission::Precise);

        // Status prüfen
        auto status = qApp->checkPermission(permission);

        switch (status) {
        case Qt::PermissionStatus::Granted:
            qCDebug(dcPlatformPermissions()) << "Location permission already granted.";
            break;
        case Qt::PermissionStatus::Denied:
            qCDebug(dcPlatformPermissions()) << "Location permission denied.";
            break;
        case Qt::PermissionStatus::Undetermined:
            qCDebug(dcPlatformPermissions()) << "Location permission not yet requested. Requesting...";
            qApp->requestPermission(permission, [](const QPermission &perm){
                if (perm.status() == Qt::PermissionStatus::Granted)
                    qCDebug(dcPlatformPermissions()) << "Location permission granted after request.";
                else
                    qCDebug(dcPlatformPermissions()) << "Location permission denied after request.";
            });
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
    case PlatformPermissions::PermissionBluetooth:
        qCDebug(dcPlatformPermissions()) << "Requesting bluetooth permission";
        qApp->requestPermission(QLocationPermission{}, [platformPermission](const QPermission &permission) {
            if (permission.status() == Qt::PermissionStatus::Denied) {
                qCWarning(dcPlatformPermissions()) << "Bluetooth permission denied.";
                s_instance->m_requestedButDeniedPermissions.append(platformPermission);
            }

            if (permission.status() == Qt::PermissionStatus::Granted)
                qCDebug(dcPlatformPermissions()) << "Bluetooth permission granted.";

            emit s_instance->bluetoothPermissionChanged();
        });
        break;
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
    case PlatformPermissions::PermissionLocalNetwork: {
        QFuture permission_request = QtAndroidPrivate::requestPermission("android.permission.POST_NOTIFICATIONS");
        switch(permission_request.result()) {
        case QtAndroidPrivate::Undetermined:
            qWarning() << "Permission for posting notifications undetermined!";
            break;
        case QtAndroidPrivate::Authorized:
            qDebug() << "Permission for posting notifications authorized";
            break;
        case QtAndroidPrivate::Denied:
            qWarning() << "Permission for posting notifications denied!";
            break;
        }

        break;
    }
    case PlatformPermissions::PermissionNotifications: {
        if (QOperatingSystemVersion::current() < QOperatingSystemVersion(QOperatingSystemVersion::Android, 13)) {
            qCDebug(dcPlatformPermissions()) << "Notifications permission implicitly granted on Android < 13.";
            emit s_instance->notificationsPermissionChanged();
            break;
        }

        QFuture permission_request = QtAndroidPrivate::requestPermission("android.permission.POST_NOTIFICATIONS");
        auto result = permission_request.result();
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
        break;
    }
    default:
        qCWarning(dcPlatformPermissions()) << "Requested platform permission" << platformPermission << "but is not implemented yet.";
        break;
    }

    emit s_instance->locationPermissionChanged();
    emit s_instance->backgroundLocationPermissionChanged();
    emit s_instance->notificationsPermissionChanged();

    // if (permissionMap().contains(permission)) {
    //     qCDebug(dcPlatformPermissions()) << "Requesting permissions:" << permissionMap().value(permission);



    //     qApp->requestPermission(QCameraPermission{}, [](const QPermission &permission) {


    //         if (permission.status() == Qt::PermissionStatus::Granted)
    //             takePhoto();
    //     });

    //     // QtAndroid::requestPermissions({permissionMap().value(permission)}, &permissionResultCallback);
    // }
}

// void PlatformPermissionsAndroid::openPermissionSettings()
// {
//     qCDebug(dcPlatformPermissions()) << "Opening permission dialog.";
//     QJniObject packageName = QtAndroid::androidContext().callObjectMethod("getPackageName", "()Ljava/lang/String;");
//     QString packageUri = "package:" + packageName.toString();
//     QJniObject uri = QJniObject::callStaticObjectMethod("android/net/Uri", "parse", "(Ljava/lang/String;)Landroid/net/Uri;", QJniObject::fromString(packageUri).object());
//     QAndroidIntent intent = QAndroidIntent("android.settings.APPLICATION_DETAILS_SETTINGS");
//     intent.handle().callObjectMethod("setData", "(Landroid/net/Uri;)Landroid/content/Intent;", uri.object());
//     intent.handle().callObjectMethod("addFlags", "(I)Landroid/content/Intent;", FLAG_ACTIVITY_NEW_TASK);
//     QtAndroid::androidContext().callMethod<void>("startActivity", "(Landroid/content/Intent;)V", intent.handle().object());
// }

// QHash<PlatformPermissions::Permission, QStringList> PlatformPermissionsAndroid::permissionMap() const
// {
//     QOperatingSystemVersion osVersion = QOperatingSystemVersion::current();
//     if (osVersion.majorVersion() <= 9) {
//         return {
//             {PlatformPermissions::PermissionBluetooth, {"android.permission.ACCESS_COARSE_LOCATION", "android.permission.ACCESS_FINE_LOCATION"}},
//             {PlatformPermissions::PermissionLocation, {"android.permission.ACCESS_FINE_LOCATION"}},
//             {PlatformPermissions::PermissionBackgroundLocation, {"android.permission.ACCESS_FINE_LOCATION"}}
//         };
//     }
//     if (osVersion.majorVersion() <= 10) {
//         return {
//             {PlatformPermissions::PermissionBluetooth, {"android.permission.ACCESS_COARSE_LOCATION", "android.permission.ACCESS_FINE_LOCATION"}},
//             {PlatformPermissions::PermissionLocation, {"android.permission.ACCESS_FINE_LOCATION"}},
//             {PlatformPermissions::PermissionBackgroundLocation, {"android.permission.ACCESS_FINE_LOCATION", "android.permission.ACCESS_BACKGROUND_LOCATION"}}
//         };
//     }
//     if (osVersion.majorVersion() <= 12) {
//         return {
//             // TODO: Once QtBluetooth does not request the COARSE_LOCATION and FINE_LOCATION for Bluetooth any more, remove it from here. The new Bluetooth permissions would be enough.
//             {PlatformPermissions::PermissionBluetooth, {"android.permission.BLUETOOTH_SCAN", "android.permission.BLUETOOTH_CONNECT", "android.permission.BLUETOOTH_ADVERTISE", "android.permission.ACCESS_COARSE_LOCATION", "android.permission.ACCESS_FINE_LOCATION"}},
//             {PlatformPermissions::PermissionLocation, {"android.permission.ACCESS_FINE_LOCATION"}},
//             {PlatformPermissions::PermissionBackgroundLocation, {"android.permission.ACCESS_FINE_LOCATION", "android.permission.ACCESS_BACKGROUND_LOCATION"}}
//         };
//     }
//     return {
//         // TODO: Once QtBluetooth does not request the COARSE_LOCATION and FINE_LOCATION for Bluetooth any more, remove it from here. The new Bluetooth permissions would be enough.
//         {PlatformPermissions::PermissionBluetooth, {"android.permission.BLUETOOTH_SCAN", "android.permission.BLUETOOTH_CONNECT", "android.permission.BLUETOOTH_ADVERTISE", "android.permission.ACCESS_COARSE_LOCATION", "android.permission.ACCESS_FINE_LOCATION"}},
//         {PlatformPermissions::PermissionLocation, {"android.permission.ACCESS_FINE_LOCATION"}},
//         {PlatformPermissions::PermissionBackgroundLocation, {"android.permission.ACCESS_FINE_LOCATION", "android.permission.ACCESS_BACKGROUND_LOCATION"}},
//         {PlatformPermissions::PermissionNotifications, {"android.permission.POST_NOTIFICATIONS"}}
//     };
// }

// PlatformPermissions::PermissionStatus PlatformPermissionsAndroid::checkPermission(Permission permission) const
// {
//     PermissionStatus status = PermissionStatusGranted;
//     QStringList androidPermissions = permissionMap().value(permission);
//     qCDebug(dcPlatformPermissions()) << "Checking permission" << permission << "(" << androidPermissions << ")";
//     foreach (const QString androidPermission, androidPermissions) {
//         if (QtAndroid::shouldShowRequestPermissionRationale(androidPermission) || m_requestedButDeniedPermissions.contains(androidPermission)) {
//             qCDebug(dcPlatformPermissions()) << "Permission:" << androidPermission << "denied";
//             status = PermissionStatusDenied;
//         }
//         if (QtAndroid::checkPermission(androidPermission) == QtAndroid::PermissionResult::Denied) {
//             qDebug(dcPlatformPermissions()) << "Permission:" << androidPermission << "not determined";
//             if (status != PermissionStatusDenied) {
//                 status = PermissionStatusNotDetermined;
//             }
//         } else {
//             qDebug(dcPlatformPermissions()) << "Permission:" << androidPermission << "granted";
//         }
//     }
//     qCDebug(dcPlatformPermissions()) << "Permission status for:" << permission << ":" << status;
//     return status;
// }

// void PlatformPermissionsAndroid::permissionResultCallback(const QtAndroid::PermissionResultMap &results)
// {
//     foreach (const QString &androidPermission, results.keys()) {
//         qCDebug(dcPlatformPermissions()) << "Permission result callback:" << androidPermission << (results.value(androidPermission) == QtAndroid::PermissionResult::Granted ? "Granted" : "Denied");
//         if (results.value(androidPermission) == QtAndroid::PermissionResult::Denied) {
//             s_instance->m_requestedButDeniedPermissions.append(androidPermission);
//         }
//     }
//     emit s_instance->bluetoothPermissionChanged();
//     emit s_instance->locationPermissionChanged();
//     emit s_instance->backgroundLocationPermissionChanged();
//     emit s_instance->notificationsPermissionChanged();
// }

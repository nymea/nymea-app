#include "platformpermissionsandroid.h"

#include <QApplication>
#include <QDebug>
#include <QJniObject>
#include <QNativeInterface>
#include <QOperatingSystemVersion>

#include "logging.h"
NYMEA_LOGGING_CATEGORY(dcPlatformPermissions, "PlatformPermissions")

#define FLAG_ACTIVITY_NEW_TASK 0x10000000

PlatformPermissionsAndroid::PlatformPermissionsAndroid(QObject *parent)
    : PlatformPermissions{parent}
{
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

void PlatformPermissionsAndroid::requestPermission(PlatformPermissions::Permission permission)
{
    if (permissionMap().contains(permission)) {
        const QStringList androidPermissions = permissionMap().value(permission);
        qCDebug(dcPlatformPermissions()) << "Requesting permissions:" << androidPermissions;
        QNativeInterface::QAndroidApplication::requestPermissions(androidPermissions, [this](const QHash<QString, QNativeInterface::QAndroidApplication::PermissionResult> &results) {
            for (auto it = results.constBegin(); it != results.constEnd(); ++it) {
                qCDebug(dcPlatformPermissions()) << "Permission result callback:" << it.key() << (it.value() == QNativeInterface::QAndroidApplication::PermissionResult::Granted ? "Granted" : "Denied");
                if (it.value() == QNativeInterface::QAndroidApplication::PermissionResult::Denied) {
                    m_requestedButDeniedPermissions.append(it.key());
                }
            }
            emit bluetoothPermissionChanged();
            emit locationPermissionChanged();
            emit backgroundLocationPermissionChanged();
            emit notificationsPermissionChanged();
        });
    }
}

void PlatformPermissionsAndroid::openPermissionSettings()
{
    qCDebug(dcPlatformPermissions()) << "Opening permission dialog.";
    QJniObject packageName = QNativeInterface::QAndroidApplication::context().callObjectMethod("getPackageName", "()Ljava/lang/String;");
    QString packageUri = "package:" + packageName.toString();
    QJniObject uri = QJniObject::callStaticObjectMethod("android/net/Uri", "parse", "(Ljava/lang/String;)Landroid/net/Uri;", QJniObject::fromString(packageUri).object());
    QJniObject intent("android/content/Intent", "(Ljava/lang/String;)V", QJniObject::fromString("android.settings.APPLICATION_DETAILS_SETTINGS").object<jstring>());
    intent.callObjectMethod("setData", "(Landroid/net/Uri;)Landroid/content/Intent;", uri.object());
    intent.callObjectMethod("addFlags", "(I)Landroid/content/Intent;", FLAG_ACTIVITY_NEW_TASK);
    QNativeInterface::QAndroidApplication::context().callMethod<void>("startActivity", "(Landroid/content/Intent;)V", intent.object());
}

QHash<PlatformPermissions::Permission, QStringList> PlatformPermissionsAndroid::permissionMap() const
{
    QOperatingSystemVersion osVersion = QOperatingSystemVersion::current();
    if (osVersion.majorVersion() <= 9) {
        return {
            {PlatformPermissions::PermissionBluetooth, {"android.permission.ACCESS_COARSE_LOCATION", "android.permission.ACCESS_FINE_LOCATION"}},
            {PlatformPermissions::PermissionLocation, {"android.permission.ACCESS_FINE_LOCATION"}},
            {PlatformPermissions::PermissionBackgroundLocation, {"android.permission.ACCESS_FINE_LOCATION"}}
        };
    }
    if (osVersion.majorVersion() <= 10) {
        return {
            {PlatformPermissions::PermissionBluetooth, {"android.permission.ACCESS_COARSE_LOCATION", "android.permission.ACCESS_FINE_LOCATION"}},
            {PlatformPermissions::PermissionLocation, {"android.permission.ACCESS_FINE_LOCATION"}},
            {PlatformPermissions::PermissionBackgroundLocation, {"android.permission.ACCESS_FINE_LOCATION", "android.permission.ACCESS_BACKGROUND_LOCATION"}}
        };
    }
    if (osVersion.majorVersion() <= 12) {
        return {
            // TODO: Once QtBluetooth does not request the COARSE_LOCATION and FINE_LOCATION for Bluetooth any more, remove it from here. The new Bluetooth permissions would be enough.
            {PlatformPermissions::PermissionBluetooth, {"android.permission.BLUETOOTH_SCAN", "android.permission.BLUETOOTH_CONNECT", "android.permission.BLUETOOTH_ADVERTISE", "android.permission.ACCESS_COARSE_LOCATION", "android.permission.ACCESS_FINE_LOCATION"}},
            {PlatformPermissions::PermissionLocation, {"android.permission.ACCESS_FINE_LOCATION"}},
            {PlatformPermissions::PermissionBackgroundLocation, {"android.permission.ACCESS_FINE_LOCATION", "android.permission.ACCESS_BACKGROUND_LOCATION"}}
        };
    }
    return {
        // TODO: Once QtBluetooth does not request the COARSE_LOCATION and FINE_LOCATION for Bluetooth any more, remove it from here. The new Bluetooth permissions would be enough.
        {PlatformPermissions::PermissionBluetooth, {"android.permission.BLUETOOTH_SCAN", "android.permission.BLUETOOTH_CONNECT", "android.permission.BLUETOOTH_ADVERTISE", "android.permission.ACCESS_COARSE_LOCATION", "android.permission.ACCESS_FINE_LOCATION"}},
        {PlatformPermissions::PermissionLocation, {"android.permission.ACCESS_FINE_LOCATION"}},
        {PlatformPermissions::PermissionBackgroundLocation, {"android.permission.ACCESS_FINE_LOCATION", "android.permission.ACCESS_BACKGROUND_LOCATION"}},
        {PlatformPermissions::PermissionNotifications, {"android.permission.POST_NOTIFICATIONS"}}
    };
}

PlatformPermissions::PermissionStatus PlatformPermissionsAndroid::checkPermission(Permission permission) const
{
    PermissionStatus status = PermissionStatusGranted;
    QStringList androidPermissions = permissionMap().value(permission);
    qCDebug(dcPlatformPermissions()) << "Checking permission" << permission << "(" << androidPermissions << ")";
    foreach (const QString androidPermission, androidPermissions) {
        if (QNativeInterface::QAndroidApplication::shouldShowRequestPermissionRationale(androidPermission) || m_requestedButDeniedPermissions.contains(androidPermission)) {
            qCDebug(dcPlatformPermissions()) << "Permission:" << androidPermission << "denied";
            status = PermissionStatusDenied;
        }
        if (QNativeInterface::QAndroidApplication::checkPermission(androidPermission) == QNativeInterface::QAndroidApplication::PermissionResult::Denied) {
            qDebug(dcPlatformPermissions()) << "Permission:" << androidPermission << "not determined";
            if (status != PermissionStatusDenied) {
                status = PermissionStatusNotDetermined;
            }
        } else {
            qDebug(dcPlatformPermissions()) << "Permission:" << androidPermission << "granted";
        }
    }
    qCDebug(dcPlatformPermissions()) << "Permission status for:" << permission << ":" << status;
    return status;
}

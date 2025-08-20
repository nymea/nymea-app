#include "platformpermissionsandroid.h"

#include <QDebug>
#include <QApplication>
#include <QAndroidIntent>
#include <QOperatingSystemVersion>

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

void PlatformPermissionsAndroid::requestPermission(PlatformPermissions::Permission permission)
{
    if (permissionMap().contains(permission)) {
        qCDebug(dcPlatformPermissions()) << "Requesting permissions:" << permissionMap().value(permission);
        QtAndroid::requestPermissions({permissionMap().value(permission)}, &permissionResultCallback);
    }
}

void PlatformPermissionsAndroid::openPermissionSettings()
{
    qCDebug(dcPlatformPermissions()) << "Opening permission dialog.";
    QAndroidJniObject packageName = QtAndroid::androidContext().callObjectMethod("getPackageName", "()Ljava/lang/String;");
    QString packageUri = "package:" + packageName.toString();
    QAndroidJniObject uri = QAndroidJniObject::callStaticObjectMethod("android/net/Uri", "parse", "(Ljava/lang/String;)Landroid/net/Uri;", QAndroidJniObject::fromString(packageUri).object());
    QAndroidIntent intent = QAndroidIntent("android.settings.APPLICATION_DETAILS_SETTINGS");
    intent.handle().callObjectMethod("setData", "(Landroid/net/Uri;)Landroid/content/Intent;", uri.object());
    intent.handle().callObjectMethod("addFlags", "(I)Landroid/content/Intent;", FLAG_ACTIVITY_NEW_TASK);
    QtAndroid::androidContext().callMethod<void>("startActivity", "(Landroid/content/Intent;)V", intent.handle().object());
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
        if (QtAndroid::shouldShowRequestPermissionRationale(androidPermission) || m_requestedButDeniedPermissions.contains(androidPermission)) {
            qCDebug(dcPlatformPermissions()) << "Permission:" << androidPermission << "denied";
            status = PermissionStatusDenied;
        }
        if (QtAndroid::checkPermission(androidPermission) == QtAndroid::PermissionResult::Denied) {
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

void PlatformPermissionsAndroid::permissionResultCallback(const QtAndroid::PermissionResultMap &results)
{
    foreach (const QString &androidPermission, results.keys()) {
        qCDebug(dcPlatformPermissions()) << "Permission result callback:" << androidPermission << (results.value(androidPermission) == QtAndroid::PermissionResult::Granted ? "Granted" : "Denied");
        if (results.value(androidPermission) == QtAndroid::PermissionResult::Denied) {
            s_instance->m_requestedButDeniedPermissions.append(androidPermission);
        }
    }
    emit s_instance->bluetoothPermissionChanged();
    emit s_instance->locationPermissionChanged();
    emit s_instance->backgroundLocationPermissionChanged();
    emit s_instance->notificationsPermissionChanged();
}


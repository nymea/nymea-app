#include "platformpermissionsandroid.h"

#include <QApplication>
#include <QDebug>

PlatformPermissionsAndroid * PlatformPermissionsAndroid::s_instance = nullptr;

QHash<PlatformPermissions::Permission, QStringList> permissionMap = {
    // TODO: Once QtBluetooth does not request the COARSE_LOCATION for Bluetooth any more, remove it from here. The new Bluetooth permissions would be enough.
    {PlatformPermissions::PermissionBluetooth, {"android.permission.BLUETOOTH_SCAN", "android.permission.BLUETOOTH_CONNECT", "android.permission.ACCESS_COARSE_LOCATION"}},
    {PlatformPermissions::PermissionLocation, {"android.permission.ACCESS_FINE_LOCATION"}},
    {PlatformPermissions::PermissionBackgroundLocation, {"android.permission.ACCESS_FINE_LOCATION", "android.permission.ACCESS_BACKGROUND_LOCATION"}},
    {PlatformPermissions::PermissionNotifications, {"android.permission.POST_NOTIFICATIONS"}},
};

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
        }
    });

}

void PlatformPermissionsAndroid::requestPermission(PlatformPermissions::Permission permission)
{
    if (permissionMap.contains(permission)) {
        QtAndroid::requestPermissions({permissionMap.value(permission)}, &permissionResultCallback);
    }
}

void PlatformPermissionsAndroid::openPermissionSettings()
{
    QtAndroid::androidActivity().callMethod<void>("openPermissionSettings", "()V");
}

PlatformPermissions::PermissionStatus PlatformPermissionsAndroid::checkPermission(Permission permission) const
{
    PermissionStatus status = PermissionStatusGranted;
    QStringList androidPermissions = permissionMap.value(permission);
    foreach (const QString androidPermission, androidPermissions) {
        if (QtAndroid::shouldShowRequestPermissionRationale(androidPermission)) {
            return PermissionStatusDenied;
        }
        if (QtAndroid::checkPermission(androidPermission) == QtAndroid::PermissionResult::Denied) {
            status = PermissionStatusNotDetermined;
        }
    }
    return status;
}

void PlatformPermissionsAndroid::permissionResultCallback(const QtAndroid::PermissionResultMap &/*results*/)
{
    emit s_instance->bluetoothPermissionChanged();
    emit s_instance->locationPermissionChanged();
    emit s_instance->backgroundLocationPermissionChanged();
}


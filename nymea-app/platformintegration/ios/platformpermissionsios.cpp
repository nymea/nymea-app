#include "platformpermissionsios.h"

#include <QSettings>

PlatformPermissionsIOS *PlatformPermissionsIOS::s_instance = nullptr;

PlatformPermissionsIOS::PlatformPermissionsIOS(QObject *parent)
    : PlatformPermissions{parent}
{
    s_instance = this;
    initObjC();
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

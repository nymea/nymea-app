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


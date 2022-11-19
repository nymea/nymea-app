#ifndef PLATFORMPERMISSIONSIOS_H
#define PLATFORMPERMISSIONSIOS_H

#include <QObject>

#include "../platformpermissions.h"

#if __OBJC__
@class CLLocationManager;
@class CBCentralManager;
#else
typedef void CLLocationManager;
typedef void CBCentralManager;
#endif

class PlatformPermissionsIOS : public PlatformPermissions
{
    Q_OBJECT
public:
    explicit PlatformPermissionsIOS(QObject *parent = nullptr);
    static PlatformPermissionsIOS *instance();

    PermissionStatus checkPermission(Permission permission) const override;
    void requestPermission(Permission permission) override;
    void openPermissionSettings() override;

private:
    void initObjC();
    void refreshNotificationsPermission();

    static PlatformPermissionsIOS *s_instance;

    PermissionStatus checkLocalNetworkPermission() const;
    PermissionStatus checkBluetoothPermission() const;
    PermissionStatus checkLocationPermission() const;
    PermissionStatus checkBackgroundLocationPermission() const;

    void requestLocalNetworkPermission();
    void requestNotificationPermission();
    void requestBluetoothPermission();
    void requestLocationPermission();
    void requestBackgroundLocationPermission();

    PermissionStatus m_notificationPermissions = PermissionStatusNotDetermined;


    CLLocationManager *m_locationManager = nullptr;
    CBCentralManager *m_bluetoothManager = nullptr;
};

#endif // PLATFORMPERMISSIONSIOS_H

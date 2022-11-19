#include "platformpermissionsios.h"

#import <UserNotifications/UNUserNotificationCenter.h>
#import <UserNotifications/UNNotificationSettings.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <UIKit/UIKit.h>

@interface LocationManagerPermissionDelegate : NSObject <CLLocationManagerDelegate>
@end
@implementation LocationManagerPermissionDelegate
- (void)locationManagerDidChangeAuthorization:(CLLocationManager *)manager {
    emit PlatformPermissionsIOS::instance()->locationPermissionChanged();
}
@end

@interface BluetoothManagerDelegate: NSObject<CBCentralManagerDelegate>
@end
@implementation BluetoothManagerDelegate
- (void)centralManagerDidUpdateState:(CBCentralManager *)manager {
    emit PlatformPermissionsIOS::instance()->bluetoothPermissionChanged();
}
@end

void PlatformPermissionsIOS::initObjC()
{
    m_locationManager = [[CLLocationManager alloc] init];
    m_locationManager.delegate = [[LocationManagerPermissionDelegate alloc] init];

    // Refresh notification permissions right away as that can be retrieved async only. We wanna be ready when the app requests it.
    refreshNotificationsPermission();
}

void PlatformPermissionsIOS::refreshNotificationsPermission()
{
    // Notification permissions can be retrieved async only.
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings *settings) {
        PermissionStatus newPermission;
        switch (settings.authorizationStatus) {
        case UNAuthorizationStatusNotDetermined:
            newPermission = PermissionStatusNotDetermined;
            break;
        case UNAuthorizationStatusDenied:
            newPermission = PermissionStatusDenied;
            break;
        case UNAuthorizationStatusAuthorized:
        case UNAuthorizationStatusProvisional:
        case UNAuthorizationStatusEphemeral:
            newPermission = PermissionStatusGranted;
            break;
        }
        if (newPermission != m_notificationPermissions) {
            m_notificationPermissions = newPermission;
            emit notificationsPermissionChanged();
        }
    }];
}

void PlatformPermissionsIOS::requestNotificationPermission()
{
    UNUserNotificationCenter* center = [UNUserNotificationCenter currentNotificationCenter];
    [center requestAuthorizationWithOptions:(UNAuthorizationOptionAlert + UNAuthorizationOptionBadge + UNAuthorizationOptionSound)
       completionHandler:^(BOOL granted, NSError * _Nullable error) {
        m_notificationPermissions = granted ? PermissionStatusGranted : PermissionStatusDenied;
        emit notificationsPermissionChanged();
    }];
}

PlatformPermissions::PermissionStatus PlatformPermissionsIOS::checkBluetoothPermission() const
{
    // iOS 13.0 would have an api but it's more complicated and also deprecated... Ignoring...
    if (@available(iOS 13.1, *)) {
        switch (CBCentralManager.authorization) {
        case CBManagerAuthorizationAllowedAlways:
        case CBManagerAuthorizationRestricted:
            return PermissionStatusGranted;
        case CBManagerAuthorizationDenied:
            return PermissionStatusDenied;
        case CBManagerAuthorizationNotDetermined:
            return PermissionStatusNotDetermined;
        }
    }
    // Before iOS 13, Bluetooth permissions are not required
    return PermissionStatusGranted;
}

void PlatformPermissionsIOS::requestBluetoothPermission()
{
    // Instantiating a Bluetooth manager just trigger the popup...
    if (!m_bluetoothManager) {
        BluetoothManagerDelegate *delegate = [[BluetoothManagerDelegate alloc] init];
        m_bluetoothManager = [[CBCentralManager alloc] initWithDelegate:delegate queue:nil];
    }
}

PlatformPermissions::PermissionStatus PlatformPermissionsIOS::checkLocationPermission() const
{
    switch ([CLLocationManager authorizationStatus]) {
    case kCLAuthorizationStatusNotDetermined:
        return PermissionStatusNotDetermined;
    case kCLAuthorizationStatusAuthorizedAlways:
    case kCLAuthorizationStatusAuthorizedWhenInUse:
        return PermissionStatusGranted;
    case kCLAuthorizationStatusDenied:
    case kCLAuthorizationStatusRestricted:
        return PermissionStatusDenied;
    }
    return PermissionStatusGranted;
}

void PlatformPermissionsIOS::requestLocationPermission()
{
    if ([m_locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [m_locationManager requestWhenInUseAuthorization];
    }
}

PlatformPermissions::PermissionStatus PlatformPermissionsIOS::checkBackgroundLocationPermission() const
{
    switch ([CLLocationManager authorizationStatus]) {
    case kCLAuthorizationStatusNotDetermined:
        return PermissionStatusNotDetermined;
    case kCLAuthorizationStatusAuthorizedAlways:
        return PermissionStatusGranted;
    case kCLAuthorizationStatusAuthorizedWhenInUse:
    case kCLAuthorizationStatusDenied:
    case kCLAuthorizationStatusRestricted:
        return PermissionStatusDenied;
    }
    return PermissionStatusGranted;
}

void PlatformPermissionsIOS::requestBackgroundLocationPermission()
{
    if ([m_locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [m_locationManager requestAlwaysAuthorization];
    }
}

void PlatformPermissionsIOS::openPermissionSettings()
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
}

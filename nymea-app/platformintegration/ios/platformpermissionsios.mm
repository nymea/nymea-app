#include "platformpermissionsios.h"

#include <QApplication>
#include <QBluetoothPermission>
#include <QPermission>
#include <QSharedPointer>
#include <QTimer>
#include <QtPlugin>

#import <UserNotifications/UNUserNotificationCenter.h>
#import <UserNotifications/UNNotificationSettings.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <Network/Network.h>
#import <UIKit/UIKit.h>

#include "logging.h"
Q_DECLARE_LOGGING_CATEGORY(dcPlatformPermissions)

static nw_browser_t s_localNetworkPermissionBrowser = nullptr;
constexpr int DnsServiceErrPolicyDenied = -65570;

static void stopLocalNetworkPermissionBrowser()
{
    if (!s_localNetworkPermissionBrowser) {
        return;
    }

    nw_browser_cancel(s_localNetworkPermissionBrowser);
    nw_release(s_localNetworkPermissionBrowser);
    s_localNetworkPermissionBrowser = nullptr;
}

#ifdef QT_STATICPLUGIN
Q_IMPORT_PLUGIN(QDarwinBluetoothPermissionPlugin)
#endif

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
       completionHandler:^(BOOL granted, NSError * _Nullable) {
        m_notificationPermissions = granted ? PermissionStatusGranted : PermissionStatusDenied;
        emit notificationsPermissionChanged();
    }];
}

PlatformPermissions::PermissionStatus PlatformPermissionsIOS::checkBluetoothPermission() const
{
    qCDebug(dcPlatformPermissions()) << "Checking bluetooth permission...";
    QBluetoothPermission btPermission;
    btPermission.setCommunicationModes(QBluetoothPermission::Access);
    const auto qtStatus = qGuiApp->checkPermission(btPermission);
    if (qtStatus == Qt::PermissionStatus::Granted) {
        qCDebug(dcPlatformPermissions()) << "Bluetooth permisson granted (Qt plugin)";
        return PermissionStatusGranted;
    } else {
        qCDebug(dcPlatformPermissions()) << "Bluetooth permisson NOT granted (Qt plugin)";
    }

    PermissionStatus fallbackStatus = PermissionStatusGranted;
    if (@available(iOS 13.1, *)) {
        switch (CBCentralManager.authorization) {
        case CBManagerAuthorizationAllowedAlways:
            fallbackStatus = PermissionStatusGranted;
            break;
        case CBManagerAuthorizationRestricted:
            fallbackStatus = PermissionStatusGranted;
            break;
        case CBManagerAuthorizationDenied:
            fallbackStatus = PermissionStatusDenied;
            break;
        case CBManagerAuthorizationNotDetermined:
            fallbackStatus = PermissionStatusNotDetermined;
            break;
        }
    } else {
        // Before iOS 13, Bluetooth permissions are not required
        fallbackStatus = PermissionStatusGranted;
    }

    switch (qtStatus) {
    case Qt::PermissionStatus::Denied:
        qCWarning(dcPlatformPermissions()) << "Bluetooth permission denied by Qt plugin, fallback reports" << fallbackStatus;
        break;
    case Qt::PermissionStatus::Undetermined:
        qCWarning(dcPlatformPermissions()) << "QBluetoothPermission status Undetermined...using fallback.";
        break;
    case Qt::PermissionStatus::Granted:
        break;
    }

    return fallbackStatus;
}

void PlatformPermissionsIOS::requestBluetoothPermission()
{
    qCDebug(dcPlatformPermissions()) << "Requesting bluetooth permission...";
    auto handlePermissionResult = [](const QPermission &permission) {
        switch (permission.status()) {
        case Qt::PermissionStatus::Granted:
            qCDebug(dcPlatformPermissions()) << "Bluetooth permission granted.";
            emit s_instance->bluetoothPermissionChanged();
            return;
        case Qt::PermissionStatus::Denied:
            if (s_instance->checkBluetoothPermission() == PermissionStatusNotDetermined) {
                qCWarning(dcPlatformPermissions()) << "Bluetooth permission plugin unavailable, falling back to CoreBluetooth request.";
                s_instance->requestBluetoothPermissionLegacy();
                return;
            }
            qCWarning(dcPlatformPermissions()) << "Bluetooth permission denied.";
            emit s_instance->bluetoothPermissionChanged();
            return;
        case Qt::PermissionStatus::Undetermined:
            qCWarning(dcPlatformPermissions()) << "Bluetooth permission plugin unavailable, falling back to CoreBluetooth request.";
            s_instance->requestBluetoothPermissionLegacy();
            return;
        }
    };

    QBluetoothPermission btPermission;
    btPermission.setCommunicationModes(QBluetoothPermission::Access);

    if (qApp->checkPermission(btPermission) == Qt::PermissionStatus::Undetermined) {
        auto permissionHandled = QSharedPointer<bool>::create(false);

        qApp->requestPermission(btPermission, [handlePermissionResult, permissionHandled](const QPermission &permission) {
            *permissionHandled = true;
            handlePermissionResult(permission);
        });

        // The Qt permission plugin might be missing from certain builds. If we still don't have
        // a decision after giving it a moment, fall back to the CoreBluetooth prompt.
        QTimer::singleShot(2000, this, [this, permissionHandled]() {
            if (*permissionHandled) {
                return;
            }
            if (checkBluetoothPermission() == PermissionStatusNotDetermined) {
                qCWarning(dcPlatformPermissions()) << "Bluetooth permission plugin unavailable, falling back to CoreBluetooth request.";
                requestBluetoothPermissionLegacy();
            }
        });
        return;
    }

    handlePermissionResult(btPermission);
}

void PlatformPermissionsIOS::requestBluetoothPermissionLegacy()
{
    qCDebug(dcPlatformPermissions()) << "Requesting bluetooth permission legacy...";
    // Instantiating a Bluetooth manager triggers the native dialog on first use.
    if (!m_bluetoothManager) {
        m_bluetoothDelegate = [[BluetoothManagerDelegate alloc] init];
        m_bluetoothManager = [[CBCentralManager alloc] initWithDelegate:m_bluetoothDelegate queue:nil];
    }
}

void PlatformPermissionsIOS::requestLocalNetworkPermissionNative()
{
    if (s_localNetworkPermissionBrowser) {
        return;
    }

    const auto descriptor = nw_browse_descriptor_create_bonjour_service("_jsonrpc._tcp", nullptr);
    const auto parameters = nw_parameters_create();
    s_localNetworkPermissionBrowser = nw_browser_create(descriptor, parameters);
    nw_release(descriptor);
    nw_release(parameters);

    PlatformPermissionsIOS *permissions = this;

    nw_browser_set_state_changed_handler(s_localNetworkPermissionBrowser, ^(nw_browser_state_t state, nw_error_t error) {
        if (state == nw_browser_state_ready) {
            qCDebug(dcPlatformPermissions()) << "Local network permission granted.";
            permissions->setLocalNetworkPermissionStatus(PermissionStatusGranted);
            stopLocalNetworkPermissionBrowser();
            return;
        }

        if (state != nw_browser_state_waiting && state != nw_browser_state_failed) {
            return;
        }

        if (error && nw_error_get_error_domain(error) == nw_error_domain_dns
                && nw_error_get_error_code(error) == DnsServiceErrPolicyDenied) {
            qCWarning(dcPlatformPermissions()) << "Local network permission denied.";
            permissions->setLocalNetworkPermissionStatus(PermissionStatusDenied);
            stopLocalNetworkPermissionBrowser();
            return;
        }

        if (state == nw_browser_state_failed) {
            qCWarning(dcPlatformPermissions()) << "Local network browser failed; it can be retried:" << error;
            stopLocalNetworkPermissionBrowser();
            return;
        }

        qCWarning(dcPlatformPermissions()) << "Local network browser is waiting:" << error;
    });
    nw_browser_set_queue(s_localNetworkPermissionBrowser, dispatch_get_main_queue());
    nw_browser_start(s_localNetworkPermissionBrowser);
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

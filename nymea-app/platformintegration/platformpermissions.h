#ifndef PLATFORMPERMISSIONS_H
#define PLATFORMPERMISSIONS_H

#include <QObject>

class QQmlEngine;
class QJSEngine;

class PlatformPermissions : public QObject
{
    Q_OBJECT

    Q_PROPERTY(PermissionStatus localNetworkPermission READ localNetworkPermission NOTIFY localNetworkPermissionChanged)
    Q_PROPERTY(PermissionStatus bluetoothPermission READ bluetoothPermission NOTIFY bluetoothPermissionChanged)
    Q_PROPERTY(PermissionStatus locationPermission READ locationPermission NOTIFY locationPermissionChanged)
    Q_PROPERTY(PermissionStatus backgroundLocationPermission READ backgroundLocationPermission NOTIFY backgroundLocationPermissionChanged)
    Q_PROPERTY(PermissionStatus notificationsPermission READ notificationsPermission NOTIFY notificationsPermissionChanged)

public:
    enum Permission {
        PermissionNone = 0x00,
        PermissionLocalNetwork = 0x01,
        PermissionBluetooth = 0x02,
        PermissionLocation = 0x04,
        PermissionBackgroundLocation = 0x08,
        PermissionNotifications = 0x10
    };
    Q_ENUM(Permission)
    Q_DECLARE_FLAGS(Permissions, Permission)
    Q_FLAG(Permissions)

    enum PermissionStatus {
        PermissionStatusNotDetermined,
        PermissionStatusGranted,
        PermissionStatusDenied,
    };
    Q_ENUM(PermissionStatus)

    static PlatformPermissions* instance();
    static QObject *qmlProvider(QQmlEngine *engine, QJSEngine *scriptEngine);
    virtual ~PlatformPermissions() = default;

    PermissionStatus localNetworkPermission() const;
    PermissionStatus bluetoothPermission() const;
    PermissionStatus locationPermission() const;
    PermissionStatus backgroundLocationPermission() const;
    PermissionStatus notificationsPermission() const;

    Q_INVOKABLE virtual PermissionStatus checkPermission(Permission permission) const;
    Q_INVOKABLE virtual void requestPermission(Permission permission) { Q_UNUSED(permission) }
    Q_INVOKABLE virtual void openPermissionSettings() {}

signals:
    void localNetworkPermissionChanged();
    void bluetoothPermissionChanged();
    void locationPermissionChanged();
    void backgroundLocationPermissionChanged();
    void notificationsPermissionChanged();

protected:
    explicit PlatformPermissions(QObject *parent = nullptr);

};

#endif // PLATFORMPERMISSIONS_H

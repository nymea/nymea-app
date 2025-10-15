#ifndef PLATFORMPERMISSIONSANDROID_H
#define PLATFORMPERMISSIONSANDROID_H

#include "../platformpermissions.h"

class PlatformPermissionsAndroid : public PlatformPermissions
{
    Q_OBJECT
public:
    explicit PlatformPermissionsAndroid(QObject *parent = nullptr);

    PermissionStatus checkPermission(Permission permission) const override;

    void requestPermission(Permission permission) override;
    void openPermissionSettings() override;

signals:

private:
    QHash<PlatformPermissions::Permission, QStringList> permissionMap() const;

    QStringList m_requestedButDeniedPermissions;
};

#endif // PLATFORMPERMISSIONSANDROID_H

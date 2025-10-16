#ifndef PLATFORMPERMISSIONSANDROID_H
#define PLATFORMPERMISSIONSANDROID_H

#include "../platformpermissions.h"
#include <QtCore/private/qandroidextras_p.h>

class PlatformPermissionsAndroid : public PlatformPermissions
{
    Q_OBJECT
public:
    explicit PlatformPermissionsAndroid(QObject *parent = nullptr);

    PermissionStatus checkPermission(Permission platformPermission) const override;
    void requestPermission(Permission platformPermission) override;

private:
    static PlatformPermissionsAndroid *s_instance;

    QList<PlatformPermissions::Permission> m_requestedButDeniedPermissions;
    QList<PlatformPermissions::Permission> m_grantedPermission;

};

#endif // PLATFORMPERMISSIONSANDROID_H

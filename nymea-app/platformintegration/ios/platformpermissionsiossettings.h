// SPDX-License-Identifier: GPL-3.0-or-later

#ifndef PLATFORMPERMISSIONSIOSSETTINGS_H
#define PLATFORMPERMISSIONSIOSSETTINGS_H

#include <QSettings>

#include "../platformpermissions.h"

namespace PlatformPermissionsIOSSettings {

struct LocalNetworkPermissionState {
    PlatformPermissions::PermissionStatus status = PlatformPermissions::PermissionStatusNotDetermined;
    bool needsNativeRevalidation = false;
};

inline LocalNetworkPermissionState localNetworkPermissionState(const QSettings &settings)
{
    const QVariant savedStatus = settings.value("localNetworkPermissionStatus");
    if (savedStatus.isValid()) {
        const int status = savedStatus.toInt();
        if (status >= PlatformPermissions::PermissionStatusNotDetermined
                && status <= PlatformPermissions::PermissionStatusDenied) {
            return {static_cast<PlatformPermissions::PermissionStatus>(status), false};
        }
    }

    // Older versions only recorded that the setup flow had asked for access. Keep
    // discovery available while a native probe determines the actual iOS decision.
    if (settings.value("askedForLocalNetworkPermission", false).toBool()) {
        return {PlatformPermissions::PermissionStatusGranted, true};
    }

    return {};
}

inline void setLocalNetworkPermissionStatus(QSettings &settings, PlatformPermissions::PermissionStatus status)
{
    settings.setValue("localNetworkPermissionStatus", status);
}

} // namespace PlatformPermissionsIOSSettings

#endif // PLATFORMPERMISSIONSIOSSETTINGS_H

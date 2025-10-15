#pragma once

#include <QtCore/qglobal.h>

#if defined(Q_OS_ANDROID)

#include <QHash>
#include <QJniObject>
#include <QStringList>
#include <jni.h>

#include <functional>
#include <utility>

#if __has_include(<QtCore/qnativeinterface.h>) && QT_VERSION < QT_VERSION_CHECK(6, 8, 0)
#define NYMEA_USE_QT_QNATIVEINTERFACE 1
#include <QtCore/qnativeinterface.h>
#elif __has_include(<QtCore/private/qandroidextras_p.h>)
#include <QtCore/private/qandroidextras_p.h>
#else
#error "Required Android Qt interfaces are not available."
#endif

namespace NymeaAndroidCompat
{

#if defined(NYMEA_USE_QT_QNATIVEINTERFACE)

using PermissionResult = QNativeInterface::QAndroidApplication::PermissionResult;
using PermissionsMap = QHash<QString, PermissionResult>;

inline void requestPermissions(const QStringList &permissions,
                               std::function<void(const PermissionsMap &)> callback)
{
    QNativeInterface::QAndroidApplication::requestPermissions(permissions, std::move(callback));
}

inline PermissionResult checkPermission(const QString &permission)
{
    return QNativeInterface::QAndroidApplication::checkPermission(permission);
}

inline bool shouldShowRequestPermissionRationale(const QString &permission)
{
    return QNativeInterface::QAndroidApplication::shouldShowRequestPermissionRationale(permission);
}

inline void runOnAndroidThread(std::function<void()> function)
{
    QNativeInterface::QAndroidApplication::runOnAndroidThread(std::move(function));
}

inline void hideSplashScreen(int duration)
{
    QNativeInterface::QAndroidApplication::hideSplashScreen(duration);
}

inline int sdkVersion()
{
    return QNativeInterface::QAndroidApplication::sdkVersion();
}

inline QJniObject activity()
{
    const auto activityObject = QNativeInterface::QAndroidApplication::activity();
    return QJniObject(activityObject.object<jobject>());
}

inline QJniObject context()
{
    const auto contextObject = QNativeInterface::QAndroidApplication::context();
    return QJniObject(contextObject.object<jobject>());
}

#else

using PermissionResult = QtAndroidPrivate::PermissionResult;
using PermissionsMap = QHash<QString, PermissionResult>;

inline void requestPermissions(const QStringList &permissions,
                               std::function<void(const PermissionsMap &)> callback)
{
    QtAndroidPrivate::requestPermissions(permissions, [callback = std::move(callback)](const QtAndroidPrivate::PermissionsHash &results) mutable {
        PermissionsMap converted;
        for (auto it = results.constBegin(); it != results.constEnd(); ++it) {
            converted.insert(it.key(), it.value());
        }
        callback(converted);
    });
}

inline PermissionResult checkPermission(const QString &permission)
{
    return QtAndroidPrivate::checkPermission(permission);
}

inline bool shouldShowRequestPermissionRationale(const QString &permission)
{
    return QtAndroidPrivate::shouldShowRequestPermissionRationale(permission);
}

inline void runOnAndroidThread(std::function<void()> function)
{
    QtAndroidPrivate::runOnAndroidThread(std::move(function));
}

inline void hideSplashScreen(int duration)
{
    QtAndroidPrivate::hideSplashScreen(duration);
}

inline int sdkVersion()
{
    return QtAndroidPrivate::sdkVersion();
}

inline QJniObject activity()
{
    return QtAndroidPrivate::activity();
}

inline QJniObject context()
{
    return QtAndroidPrivate::context();
}

#endif

} // namespace NymeaAndroidCompat

#endif // Q_OS_ANDROID


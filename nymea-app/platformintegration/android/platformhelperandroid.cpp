#include "platformhelperandroid.h"

#include <QAndroidJniObject>
#include <QtAndroid>
#include <QDebug>

static PlatformHelperAndroid *m_instance;

PlatformHelperAndroid::PlatformHelperAndroid(QObject *parent) : PlatformHelper(parent)
{
    m_instance = this;
}

void PlatformHelperAndroid::requestPermissions()
{
    QtAndroid::requestPermissions({"android.permission.READ_PHONE_STATE"}, &PlatformHelperAndroid::permissionRequestFinished);
}

bool PlatformHelperAndroid::hasPermissions() const
{
    QtAndroid::PermissionResult r = QtAndroid::checkPermission("android.permission.READ_PHONE_STATE");
    return r == QtAndroid::PermissionResult::Granted;
}

QString PlatformHelperAndroid::deviceSerial() const
{
    QtAndroid::PermissionResult r = QtAndroid::checkPermission("android.permission.READ_PHONE_STATE");
    if (r != QtAndroid::PermissionResult::Granted) {
        qWarning() << "Cannot read device serial. No permissions";
        return "";
    }

    QAndroidJniObject activity = QAndroidJniObject::callStaticObjectMethod("org/qtproject/qt5/android/QtNative", "activity", "()Landroid/app/Activity;");
    return activity.callObjectMethod<jstring>("deviceSerial").toString();
}

QString PlatformHelperAndroid::deviceModel() const
{
    return QAndroidJniObject::callStaticObjectMethod<jstring>("io/guh/nymeaapp/NymeaAppActivity","deviceModel").toString();
}

QString PlatformHelperAndroid::deviceManufacturer() const
{
    return QAndroidJniObject::callStaticObjectMethod<jstring>("io/guh/nymeaapp/NymeaAppActivity","deviceManufacturer").toString();
}

void PlatformHelperAndroid::permissionRequestFinished(const QtAndroid::PermissionResultMap &result)
{
    foreach (const QString &key, result.keys()) {
        qDebug() << "Permission result:" << key << static_cast<int>(result.value(key));
    }
    emit m_instance->permissionsRequestFinished();
}

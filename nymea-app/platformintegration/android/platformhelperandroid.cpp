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
    // Not using any fancy permissions in android yet...
}

bool PlatformHelperAndroid::hasPermissions() const
{
    // Not using any fancy permissions in android yet...
    return true;
}

QString PlatformHelperAndroid::deviceSerial() const
{
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

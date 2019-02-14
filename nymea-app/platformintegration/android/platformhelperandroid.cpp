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

void PlatformHelperAndroid::hideSplashScreen()
{
    // Android's splash will flicker when fading out twice
    static bool alreadyHiding = false;
    if (!alreadyHiding) {
        QtAndroid::hideSplashScreen(250);
        alreadyHiding = true;
    }
}

bool PlatformHelperAndroid::hasPermissions() const
{
    // Not using any fancy permissions in android yet...
    return true;
}

QString PlatformHelperAndroid::machineHostname() const
{
    // QSysInfo::machineHostname always gives "localhost" on android... best we can do here is:
    return deviceManufacturer() +  " " + deviceModel();
}

QString PlatformHelperAndroid::deviceSerial() const
{
    QAndroidJniObject activity = QAndroidJniObject::callStaticObjectMethod("org/qtproject/qt5/android/QtNative", "activity", "()Landroid/app/Activity;");
    return activity.callObjectMethod<jstring>("deviceSerial").toString();
}

QString PlatformHelperAndroid::device() const
{
    return QAndroidJniObject::callStaticObjectMethod<jstring>("io/guh/nymeaapp/NymeaAppActivity","device").toString();
}

QString PlatformHelperAndroid::deviceModel() const
{
    return QAndroidJniObject::callStaticObjectMethod<jstring>("io/guh/nymeaapp/NymeaAppActivity","deviceModel").toString();
}

QString PlatformHelperAndroid::deviceManufacturer() const
{
    return QAndroidJniObject::callStaticObjectMethod<jstring>("io/guh/nymeaapp/NymeaAppActivity","deviceManufacturer").toString();
}

void PlatformHelperAndroid::vibrate(PlatformHelper::HapticsFeedback feedbackType)
{
    int duration;
    switch (feedbackType) {
    case HapticsFeedbackSelection:
        duration = 20;
        break;
    case HapticsFeedbackImpact:
        duration = 30;
        break;
    case HapticsFeedbackNotification:
        duration = 500;
        break;
    }

    QtAndroid::androidActivity().callMethod<void>("vibrate","(I)V", duration);
}

void PlatformHelperAndroid::permissionRequestFinished(const QtAndroid::PermissionResultMap &result)
{
    foreach (const QString &key, result.keys()) {
        qDebug() << "Permission result:" << key << static_cast<int>(result.value(key));
    }
    emit m_instance->permissionsRequestFinished();
}

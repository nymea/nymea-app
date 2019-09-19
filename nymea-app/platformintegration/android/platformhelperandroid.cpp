#include "platformhelperandroid.h"

#include <QAndroidJniObject>
#include <QtAndroid>
#include <QDebug>


// WindowManager.LayoutParams
#define FLAG_TRANSLUCENT_STATUS 0x04000000
#define FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS 0x80000000
// View
#define SYSTEM_UI_FLAG_LIGHT_STATUS_BAR 0x00002000


static PlatformHelperAndroid *m_instance;

static QAndroidJniObject getAndroidWindow()
{
    QAndroidJniObject window = QtAndroid::androidActivity().callObjectMethod("getWindow", "()Landroid/view/Window;");
    window.callMethod<void>("addFlags", "(I)V", FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS);
    window.callMethod<void>("clearFlags", "(I)V", FLAG_TRANSLUCENT_STATUS);
    return window;
}

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

void PlatformHelperAndroid::setTopPanelColor(const QColor &color)
{
    PlatformHelper::setTopPanelColor(color);

    if (QtAndroid::androidSdkVersion() < 21)
            return;

    QtAndroid::runOnAndroidThread([=]() {
        QAndroidJniObject window = getAndroidWindow();
        window.callMethod<void>("setStatusBarColor", "(I)V", color.rgba());
    });

    if (((color.red() * 299 + color.green() * 587 + color.blue() * 114) / 1000) > 123) {
        setTopPanelTheme(Light);
    } else {
        setTopPanelTheme(Dark);
    }
}

void PlatformHelperAndroid::setBottomPanelColor(const QColor &color)
{
    PlatformHelper::setBottomPanelColor(color);

    if (QtAndroid::androidSdkVersion() < 21)
            return;
}

void PlatformHelperAndroid::permissionRequestFinished(const QtAndroid::PermissionResultMap &result)
{
    foreach (const QString &key, result.keys()) {
        qDebug() << "Permission result:" << key << static_cast<int>(result.value(key));
    }
    emit m_instance->permissionsRequestFinished();
}

void PlatformHelperAndroid::setTopPanelTheme(PlatformHelperAndroid::Theme theme)
{
    if (QtAndroid::androidSdkVersion() < 23)
        return;

    QtAndroid::runOnAndroidThread([=]() {
        QAndroidJniObject window = getAndroidWindow();
        QAndroidJniObject view = window.callObjectMethod("getDecorView", "()Landroid/view/View;");
        int visibility = view.callMethod<int>("getSystemUiVisibility", "()I");
        if (theme == Theme::Light)
            visibility |= SYSTEM_UI_FLAG_LIGHT_STATUS_BAR;
        else
            visibility &= ~SYSTEM_UI_FLAG_LIGHT_STATUS_BAR;
        view.callMethod<void>("setSystemUiVisibility", "(I)V", visibility);
    });
}

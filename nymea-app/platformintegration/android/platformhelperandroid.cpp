/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
* Copyright 2013 - 2025, nymea GmbH
* Contact: contact@nymea.io
*
* This file is part of nymea.
* This project including source code and documentation is protected by
* copyright law, and remains the property of nymea GmbH. All rights, including
* reproduction, publication, editing and translation, are reserved. The use of
* this project is subject to the terms of a license agreement to be concluded
* with nymea GmbH in accordance with the terms of use of nymea GmbH, available
* under https://nymea.io/license
*
* GNU General Public License Usage
* Alternatively, this project may be redistributed and/or modified under the
* terms of the GNU General Public License as published by the Free Software
* Foundation, GNU version 3. This project is distributed in the hope that it
* will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty
* of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
* Public License for more details.
*
* You should have received a copy of the GNU General Public License along with
* this project. If not, see <https://www.gnu.org/licenses/>.
*
* For any further details and any questions please contact us under
* contact@nymea.io or see our FAQ/Licensing Information on
* https://nymea.io/license/faq
*
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#include "platformhelperandroid.h"

#include <QDebug>
#include <QScreen>
#include <QtAndroid>
#include <QAndroidIntent>
#include <QApplication>
#include <QAndroidJniObject>

// WindowManager.LayoutParams
#define FLAG_TRANSLUCENT_STATUS 0x04000000
#define FLAG_TRANSLUCENT_NAVIGATION 0x08000000
#define FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS 0x80000000
// View
#define SYSTEM_UI_FLAG_LIGHT_STATUS_BAR 0x00002000
#define SYSTEM_UI_FLAG_LIGHT_NAVIGATION_BAR 0x00000010

static PlatformHelperAndroid *m_instance = nullptr;

static JNINativeMethod methods[] = {
    { "darkModeEnabledChangedJNI", "()V", (void *)PlatformHelperAndroid::darkModeEnabledChangedJNI },
    { "notificationActionReceivedJNI", "(Ljava/lang/String;)V", (void *)PlatformHelperAndroid::notificationActionReceivedJNI },
    { "locationServicesEnabledChangedJNI", "()V", (void *)PlatformHelperAndroid::locationServicesEnabledChangedJNI },
    };

JNIEXPORT jint JNI_OnLoad(JavaVM* vm, void* /*reserved*/)
{
    JNIEnv* env;
    if (vm->GetEnv(reinterpret_cast<void**>(&env), JNI_VERSION_1_6) != JNI_OK) {
        return JNI_ERR;
    }

    jclass javaClass = env->FindClass("io/guh/nymeaapp/NymeaAppActivity");
    if (!javaClass)
        return JNI_ERR;

    if (env->RegisterNatives(javaClass, methods, sizeof(methods) / sizeof(methods[0])) < 0) {
        return JNI_ERR;
    }
    return JNI_VERSION_1_6;
}

static QAndroidJniObject getAndroidWindow()
{
    QAndroidJniObject window = QtAndroid::androidActivity().callObjectMethod("getWindow", "()Landroid/view/Window;");
    return window;
}

PlatformHelperAndroid::PlatformHelperAndroid(QObject *parent) : PlatformHelper(parent)
{
    m_instance = this;

    QString notificationData = QtAndroid::androidActivity().callObjectMethod("notificationData", "()Ljava/lang/String;").toString();
    if (!notificationData.isNull()) {
        notificationActionReceived(notificationData);
    }

    connect(qApp, &QApplication::applicationStateChanged, this, [this](Qt::ApplicationState state){
        qCritical() << "----> Application state changed" << state;
        if (state == Qt::ApplicationActive) {
            emit locationServicesEnabledChanged();
        }
    });
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
        duration = 10;
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

//void PlatformHelperAndroid::syncThings()
//{

//    QAndroidIntent serviceIntent(QtAndroid::androidActivity().object(),
//                                        "io/guh/nymeaapp/NymeaAppService");
//    QAndroidJniObject result = QtAndroid::androidActivity().callObjectMethod(
//                "startService",
//                "(Landroid/content/Intent;)Landroid/content/ComponentName;",
//                serviceIntent.handle().object());


////    QtAndroid::androidService()

////    QAndroidIntent serviceIntent(QtAndroid::androidActivity().object(),
////                                          "io/guh/nymeaapp/NymeaAppControlService");
////      serviceIntent.putExtra("name", QByteArray("foobar"));


////    m_serviceConnection->handle().callMethod<void>("syncThings", "(Ljava/lang/String;)V", "bla");


////      QAndroidJniObject result = QtAndroid::androidActivity().callObjectMethod(
////                  "syncThings",
////                  "(Landroid/content/Intent;)Landroid/content/ComponentName;",
////                  m_serviceConnection->handle().object());
//}

void PlatformHelperAndroid::setTopPanelColor(const QColor &color)
{
    PlatformHelper::setTopPanelColor(color);

    if (QtAndroid::androidSdkVersion() < 21)
        return;

    QtAndroid::runOnAndroidThread([=]() {
        QAndroidJniObject window = getAndroidWindow();
        window.callMethod<void>("addFlags", "(I)V", FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS);
        window.callMethod<void>("clearFlags", "(I)V", FLAG_TRANSLUCENT_STATUS);
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

    QtAndroid::runOnAndroidThread([=]() {
        QAndroidJniObject window = getAndroidWindow();
        window.callMethod<void>("clearFlags", "(I)V", FLAG_TRANSLUCENT_NAVIGATION);
        window.callMethod<void>("setNavigationBarColor", "(I)V", color.rgba());

        if (((color.red() * 299 + color.green() * 587 + color.blue() * 114) / 1000) > 123) {
            setBottomPanelTheme(Light);
        } else {
            setBottomPanelTheme(Dark);
        }
    });
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

void PlatformHelperAndroid::setBottomPanelTheme(Theme theme)
{
    if (QtAndroid::androidSdkVersion() < 23)
        return;

    QtAndroid::runOnAndroidThread([=]() {
        QAndroidJniObject window = getAndroidWindow();
        QAndroidJniObject view = window.callObjectMethod("getDecorView", "()Landroid/view/View;");
        int visibility = view.callMethod<int>("getSystemUiVisibility", "()I");
        if (theme == Theme::Light)
            visibility |= SYSTEM_UI_FLAG_LIGHT_NAVIGATION_BAR;
        else
            visibility &= ~SYSTEM_UI_FLAG_LIGHT_NAVIGATION_BAR;
        view.callMethod<void>("setSystemUiVisibility", "(I)V", visibility);
    });
}

int PlatformHelperAndroid::topPadding() const
{
    // Edge to edge has been forced since android SDK 35
    // We don't want to handle it in earlied versions.
    if (QtAndroid::androidSdkVersion() < 35)
        return 0;

    return QtAndroid::androidActivity().callMethod<jint>("topPadding") / QApplication::primaryScreen()->devicePixelRatio();
}

int PlatformHelperAndroid::bottomPadding() const
{
    // Edge to edge has been forced since android SDK 35
    // We don't want to handle it in earlied versions.
    if (QtAndroid::androidSdkVersion() < 35)
        return 0;

    return QtAndroid::androidActivity().callMethod<jint>("bottomPadding") / QApplication::primaryScreen()->devicePixelRatio();
}

bool PlatformHelperAndroid::darkModeEnabled() const
{
    return QtAndroid::androidActivity().callMethod<jboolean>("darkModeEnabled");
}

bool PlatformHelperAndroid::locationServicesEnabled() const
{
    jboolean enabled = QtAndroid::androidActivity().callMethod<jboolean>("locationServicesEnabled", "()Z");
    return enabled;
}

void PlatformHelperAndroid::shareFile(const QString &fileName)
{
    QtAndroid::androidActivity().callMethod<void>("shareFile", "(Ljava/lang/String;)V",
                                                  QAndroidJniObject::fromString(fileName).object<jstring>()
                                                  );
}

void PlatformHelperAndroid::darkModeEnabledChangedJNI()
{
    if (m_instance) {
        emit m_instance->darkModeEnabledChanged();
    }
}

void PlatformHelperAndroid::notificationActionReceivedJNI(JNIEnv *env, jobject, jstring data)
{
    // Only call the platformhelper if it exists yet. We may get this callback before the Qt part is created
    // and we don't want to create the PlatformHelper on the android thread.
    PlatformHelper* platformHelper = PlatformHelperAndroid::instance(false);
    if (platformHelper) {
        platformHelper->notificationActionReceived(env->GetStringUTFChars(data, nullptr));
    }
}

void PlatformHelperAndroid::locationServicesEnabledChangedJNI()
{
    PlatformHelper* platformHelper = PlatformHelperAndroid::instance(false);
    if (platformHelper) {
        emit platformHelper->locationServicesEnabledChanged();
    }
}

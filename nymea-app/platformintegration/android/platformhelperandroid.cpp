// SPDX-License-Identifier: GPL-3.0-or-later

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
* Copyright (C) 2013 - 2024, nymea GmbH
* Copyright (C) 2024 - 2025, chargebyte austria GmbH
*
* This file is part of nymea-app.
*
* nymea-app is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* nymea-app is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with nymea-app. If not, see <https://www.gnu.org/licenses/>.
*
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#include "platformhelperandroid.h"

#include <QDebug>
#include <QScreen>
#include <QtCore/private/qandroidextras_p.h>
#include <QApplication>
#include <QJniObject>
#include <QTimer>

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

// static QJniObject getAndroidWindow()
// {
//     QJniObject window;
//     QJniObject activity = QNativeInterface::QAndroidApplication::context();
//     if(activity.isValid()) {
//         activity.callMethod<void>("setRequestedOrientation", "(I)V", 0);
//         window = activity.callObjectMethod("getWindow", "()Landroid/view/Window;");
//     }

//     // QJniObject window = QNativeInterface::QAndroidApplication::context().callMethod<jobject>("getWindow", "()Landroid/view/Window;");
//     return window;
// }

PlatformHelperAndroid::PlatformHelperAndroid(QObject *parent) : PlatformHelper(parent)
{
    m_instance = this;

    // QString notificationData = QNativeInterface::QAndroidApplication::context().callMethod<jstring>("notificationData", "()Ljava/lang/String;").toString();
    // if (!notificationData.isNull()) {
    //     notificationActionReceived(notificationData);
    // }

    connect(qApp, &QApplication::applicationStateChanged, this, [this](Qt::ApplicationState state){
        qCritical() << "----> Application state changed" << state;
        if (state == Qt::ApplicationActive) {
            emit locationServicesEnabledChanged();
            updateSafeAreaPadding();
        }
    });

    if (QScreen *screen = qApp->primaryScreen()) {
        connect(screen, &QScreen::orientationChanged, this, [this](Qt::ScreenOrientation){
            updateSafeAreaPadding();
        });
        connect(screen, &QScreen::availableGeometryChanged, this, [this](const QRect &){
            updateSafeAreaPadding();
        });
    }

    QTimer::singleShot(0, this, &PlatformHelperAndroid::updateSafeAreaPadding);
}

void PlatformHelperAndroid::hideSplashScreen()
{
    // Android's splash will flicker when fading out twice
    static bool alreadyHiding = false;
    if (!alreadyHiding) {
        //QtAndroid::hideSplashScreen(250);
        alreadyHiding = true;
    }
}

QString PlatformHelperAndroid::machineHostname() const
{
    // QSysInfo::machineHostname always gives "localhost" on android... best we can do here is:
    return deviceManufacturer() + " " + deviceModel();
}

QString PlatformHelperAndroid::deviceSerial() const
{
    QJniObject activity = QJniObject::callStaticObjectMethod("org/qtproject/qt/android/QtNative", "activity", "()Landroid/app/Activity;");
    return activity.callObjectMethod<jstring>("deviceSerial").toString();
}

QString PlatformHelperAndroid::device() const
{
    return QJniObject::callStaticObjectMethod<jstring>("io/guh/nymeaapp/NymeaAppActivity", "device").toString();
}

QString PlatformHelperAndroid::deviceModel() const
{
    return QJniObject::callStaticObjectMethod<jstring>("io/guh/nymeaapp/NymeaAppActivity", "deviceModel").toString();
}

QString PlatformHelperAndroid::deviceManufacturer() const
{
    return QJniObject::callStaticObjectMethod<jstring>("io/guh/nymeaapp/NymeaAppActivity", "deviceManufacturer").toString();
}

void PlatformHelperAndroid::vibrate(PlatformHelper::HapticsFeedback feedbackType)
{
    jlong duration;
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

    QJniObject context = QNativeInterface::QAndroidApplication::context();
    if (!context.isValid()) {
        qDebug() << "Could not get Android context.";
        return;
    }

    QJniObject vibrator = context.callObjectMethod("getSystemService", "(Ljava/lang/String;)Ljava/lang/Object;", QJniObject::fromString("vibrator").object());
    if (!vibrator.isValid()) {
        qDebug() << "Could not get vibrator service.";
        return;
    }

    const jint sdkInt = QJniObject::getStaticField<jint>("android/os/Build$VERSION", "SDK_INT");
    if (sdkInt >= 26) {
        const jint defaultAmplitude = QJniObject::getStaticField<jint>("android/os/VibrationEffect", "DEFAULT_AMPLITUDE");
        QJniObject vibrationEffect = QJniObject::callStaticObjectMethod("android/os/VibrationEffect",
                                                                        "createOneShot",
                                                                        "(JI)Landroid/os/VibrationEffect;",
                                                                        duration,
                                                                        defaultAmplitude);
        if (vibrationEffect.isValid()) {
            vibrator.callMethod<void>("vibrate", "(Landroid/os/VibrationEffect;)V", vibrationEffect.object());
            return;
        }
        qDebug() << "Falling back to legacy vibrate API, vibration effect invalid.";
    }

    // Fallback for pre-API 26 or if creating the vibration effect failed
    vibrator.callMethod<void>("vibrate", "(J)V", duration);
}

//void PlatformHelperAndroid::syncThings()
//{

//    QAndroidIntent serviceIntent(QtAndroid::androidActivity().object(),
//                                        "io/guh/nymeaapp/NymeaAppService");
//    QJniObject result = QtAndroid::androidActivity().callObjectMethod(
//                "startService",
//                "(Landroid/content/Intent;)Landroid/content/ComponentName;",
//                serviceIntent.handle().object());


////    QtAndroid::androidService()

////    QAndroidIntent serviceIntent(QtAndroid::androidActivity().object(),
////                                          "io/guh/nymeaapp/NymeaAppControlService");
////      serviceIntent.putExtra("name", QByteArray("foobar"));


////    m_serviceConnection->handle().callMethod<void>("syncThings", "(Ljava/lang/String;)V", "bla");


////      QJniObject result = QtAndroid::androidActivity().callObjectMethod(
////                  "syncThings",
////                  "(Landroid/content/Intent;)Landroid/content/ComponentName;",
////                  m_serviceConnection->handle().object());
//}

void PlatformHelperAndroid::setTopPanelColor(const QColor &color)
{
    PlatformHelper::setTopPanelColor(color);

    // if (QtAndroid::androidSdkVersion() < 21)
    //     return;

    // QtAndroid::runOnAndroidThread([=]() {
    //     QJniObject window = getAndroidWindow();
    //     window.callMethod<void>("addFlags", "(I)V", FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS);
    //     window.callMethod<void>("clearFlags", "(I)V", FLAG_TRANSLUCENT_STATUS);
    //     window.callMethod<void>("setStatusBarColor", "(I)V", color.rgba());
    // });

    // if (((color.red() * 299 + color.green() * 587 + color.blue() * 114) / 1000) > 123) {
    //     setTopPanelTheme(Light);
    // } else {
    //     setTopPanelTheme(Dark);
    // }
}

void PlatformHelperAndroid::setBottomPanelColor(const QColor &color)
{
    PlatformHelper::setBottomPanelColor(color);

    // if (QtAndroid::androidSdkVersion() < 21)
    //     return;

    // QtAndroid::runOnAndroidThread([=]() {
    //     QJniObject window = getAndroidWindow();
    //     window.callMethod<void>("clearFlags", "(I)V", FLAG_TRANSLUCENT_NAVIGATION);
    //     window.callMethod<void>("setNavigationBarColor", "(I)V", color.rgba());

    //     if (((color.red() * 299 + color.green() * 587 + color.blue() * 114) / 1000) > 123) {
    //         setBottomPanelTheme(Light);
    //     } else {
    //         setBottomPanelTheme(Dark);
    //     }
    // });
}

void PlatformHelperAndroid::setTopPanelTheme(PlatformHelperAndroid::Theme theme)
{
    Q_UNUSED(theme)
    // if (QtAndroid::androidSdkVersion() < 23)
    //     return;

    // QtAndroid::runOnAndroidThread([=]() {
    //     QJniObject window = getAndroidWindow();
    //     QJniObject view = window.callObjectMethod("getDecorView", "()Landroid/view/View;");
    //     int visibility = view.callMethod<int>("getSystemUiVisibility", "()I");
    //     if (theme == Theme::Light)
    //         visibility |= SYSTEM_UI_FLAG_LIGHT_STATUS_BAR;
    //     else
    //         visibility &= ~SYSTEM_UI_FLAG_LIGHT_STATUS_BAR;
    //     view.callMethod<void>("setSystemUiVisibility", "(I)V", visibility);
    // });
}

void PlatformHelperAndroid::setBottomPanelTheme(Theme theme)
{
    Q_UNUSED(theme)

    // if (QtAndroid::androidSdkVersion() < 23)
    //     return;

    // QtAndroid::runOnAndroidThread([=]() {
    //     QJniObject window = getAndroidWindow();
    //     QJniObject view = window.callObjectMethod("getDecorView", "()Landroid/view/View;");
    //     int visibility = view.callMethod<int>("getSystemUiVisibility", "()I");
    //     if (theme == Theme::Light)
    //         visibility |= SYSTEM_UI_FLAG_LIGHT_NAVIGATION_BAR;
    //     else
    //         visibility &= ~SYSTEM_UI_FLAG_LIGHT_NAVIGATION_BAR;
    //     view.callMethod<void>("setSystemUiVisibility", "(I)V", visibility);
    // });
}

void PlatformHelperAndroid::updateSafeAreaPadding()
{
    int topPaddingPx = 0;
    int bottomPaddingPx = 0;
    int leftPaddingPx = 0;
    int rightPaddingPx = 0;

    QJniObject context = QNativeInterface::QAndroidApplication::context();
    if (context.isValid()) {
        topPaddingPx = context.callMethod<jint>("topPadding", "()I");
        bottomPaddingPx = context.callMethod<jint>("bottomPadding", "()I");
        leftPaddingPx = context.callMethod<jint>("leftPadding", "()I");
        rightPaddingPx = context.callMethod<jint>("rightPadding", "()I");
    }

    QScreen *screen = qApp->primaryScreen();
    qreal dpr = screen ? screen->devicePixelRatio() : 1.0;
    if (dpr <= 0.0) {
        dpr = 1.0;
    }

    setSafeAreaPadding(qRound(topPaddingPx / dpr),
                       qRound(rightPaddingPx / dpr),
                       qRound(bottomPaddingPx / dpr),
                       qRound(leftPaddingPx / dpr));
}

int PlatformHelperAndroid::topPadding() const
{
    return PlatformHelper::topPadding();
}

int PlatformHelperAndroid::bottomPadding() const
{
    return PlatformHelper::bottomPadding();
}

int PlatformHelperAndroid::leftPadding() const
{
    return PlatformHelper::leftPadding();
}

int PlatformHelperAndroid::rightPadding() const
{
    return PlatformHelper::rightPadding();
}

bool PlatformHelperAndroid::darkModeEnabled() const
{
    return QNativeInterface::QAndroidApplication::context().callMethod<jboolean>("darkModeEnabled");
}

bool PlatformHelperAndroid::locationServicesEnabled() const
{
    // jboolean enabled = QNativeInterface::QAndroidApplication::context().callMethod<jboolean>("locationServicesEnabled", "()Z");
    // return enabled;
    return true;
}

void PlatformHelperAndroid::shareFile(const QString &fileName)
{
    Q_UNUSED(fileName)
    // QNativeInterface::QAndroidApplication::context().callMethod<void>("shareFile", "(Ljava/lang/String;)V",
    //                                               QJniObject::fromString(fileName).object<jstring>()
    //                                               );
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

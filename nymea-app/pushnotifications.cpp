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

#include "pushnotifications.h"
#include "platformhelper.h"

#include <QDebug>
#include <QCoreApplication>

#if defined Q_OS_ANDROID
#include <QJniObject>
#include <QJniEnvironment>

#include <QtCore/qjnienvironment.h> // QJniEnvironment
#include <QtCore/qjniobject.h>      // QJniObject
#include <QtCore/qjnitypes.h>       // QtJniTypes::Context / Activity
#include <QtCore/qnativeinterface.h>
static PushNotifications *m_client_pointer;
#endif

PushNotifications::PushNotifications(QObject *parent) : QObject(parent)
{

}

PushNotifications::~PushNotifications()
{
#if defined Q_OS_ANDROID && defined WITH_FIREBASE
    ::firebase::messaging::Terminate();
#endif
}

QObject *PushNotifications::pushNotificationsProvider(QQmlEngine *engine, QJSEngine *scriptEngine)
{
    Q_UNUSED(engine)
    Q_UNUSED(scriptEngine)
    return instance();
}

PushNotifications *PushNotifications::instance()
{
    static PushNotifications* pushNotifications = new PushNotifications();
    return pushNotifications;
}


bool PushNotifications::enabled() const
{
    return m_enabled;
}

void PushNotifications::setEnabled(bool enabled)
{
    if (m_enabled == enabled) {
        return;
    }

    m_enabled = enabled;

    if (enabled) {
        registerForPush();
    }
}

void PushNotifications::registerForPush()
{
#if defined Q_OS_ANDROID && defined WITH_FIREBASE
    qDebug() << "Checking for play services";
    jboolean playServicesAvailable = QJniObject::callStaticMethod<jboolean>("io.guh.nymeaapp.NymeaAppNotificationService", "checkPlayServices", "()Z");
    if (playServicesAvailable) {

        qDebug() << "Setting up firebase";
        m_client_pointer = this;

        JNIEnv *jni = QJniEnvironment().jniEnv();
        QtJniTypes::Context ctx = QNativeInterface::QAndroidApplication::context();
        jobject contextObj = ctx.object<jobject>();

        m_firebaseApp = firebase::App::Create(firebase::AppOptions(), jni, contextObj);

        firebase::messaging::Initialize(*m_firebaseApp, this);
        firebase::messaging::SetListener(this);

        // (Optional, Android 13+): Benachrichtigungs-Erlaubnis anfragen
        // firebase::messaging::RequestPermission();



        // // Activity + JNIEnv besorgen
        // JNIEnv* env = QNativeInterface::QAndroidApplication::jniEnv();
        // jobject activity = QNativeInterface::QAndroidApplication::context();

        // // Firebase App erstellen
        // m_firebaseApp = firebase::App::Create(firebase::AppOptions(), env, activity);

        // // Messaging initialisieren und Listener setzen
        // auto initResult = firebase::messaging::Initialize(*m_firebaseApp);
        // if (initResult != firebase::kFutureStatusComplete) {
        //     // optional: warten oder loggen
        // }
        // firebase::messaging::SetListener(this);

        // // Optional: Token anfordern (wird i.d.R. via OnTokenReceived geliefert)
        // firebase::messaging::RequestPermission(); // Android 13+ für Notifications sinnvoll




        // m_firebaseApp = ::firebase::App::Create(::firebase::AppOptions(), QAndroidJniEnvironment(), QtAndroid::androidActivity().object());
        // m_firebase_initializer.Initialize(m_firebaseApp, nullptr, [](::firebase::App * fapp, void *) {
        //     return ::firebase::messaging::Initialize( *fapp, (::firebase::messaging::Listener *)m_client_pointer);
        // });
    } else {
        qDebug() << "Google Play Services not available. Cannot connect to push client.";
    }
#endif


#ifdef UBPORTS
    m_pushClient = new PushClient(this);
    m_pushClient->setAppId("io.guh.nymeaapp_nymea-app");
    connect(m_pushClient, &PushClient::tokenChanged, this, [this](const QString &token) {
        m_token = token;
        emit tokenChanged();
    });
#endif

#ifdef Q_OS_IOS
    registerObjC();
#endif
}

QString PushNotifications::service() const
{
#if defined Q_OS_ANDROID
    return "FB-GCM";
#elif defined Q_OS_IOS
    return "FB-APNs";
#elif defined UBPORTS
    return "UBPorts";
#endif
    return "None";
}

QString PushNotifications::clientId() const
{
    return PlatformHelper::instance()->deviceSerial();
}

QString PushNotifications::token() const
{
    return m_token;
}

void PushNotifications::setFirebaseRegistrationToken(const QString &firebaseRegistrationToken)
{
    qDebug() << "Received Firebase/APNS push notification token:" << firebaseRegistrationToken;
    m_token = firebaseRegistrationToken;
    emit tokenChanged();
}

#if defined Q_OS_ANDROID && defined WITH_FIREBASE
void PushNotifications::OnMessage(const firebase::messaging::Message &message)
{
    qDebug() << "Firebase message received:" << QString::fromStdString(message.from);
}

void PushNotifications::OnTokenReceived(const char *token)
{
    m_token = QString(token);
    qDebug() << "Firebase token received:" << m_token;
    emit tokenChanged();
}
#endif

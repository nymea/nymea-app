/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
* Copyright 2013 - 2020, nymea GmbH
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

#include "pushnotifications.h"
#include "platformhelper.h"

#include <QDebug>

#if defined Q_OS_ANDROID
#include <QJniEnvironment>
#include <QJniObject>
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
        auto activity = QNativeInterface::QAndroidApplication::activity();
        m_firebaseApp = ::firebase::App::Create(::firebase::AppOptions(), QJniEnvironment(), activity.object());
        m_firebase_initializer.Initialize(m_firebaseApp, nullptr, [](::firebase::App * fapp, void *) {
            return ::firebase::messaging::Initialize( *fapp, (::firebase::messaging::Listener *)m_client_pointer);
        });
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

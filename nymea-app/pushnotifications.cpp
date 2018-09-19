#include "pushnotifications.h"

#include <QDebug>

#if defined(Q_OS_ANDROID)
#include <QtAndroid>
#include <QtAndroidExtras>
#include <QAndroidJniObject>
#endif

static PushNotifications *m_client_pointer;

PushNotifications::PushNotifications(QObject *parent) : QObject(parent)
{
    connectClient();
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

void PushNotifications::connectClient()
{
#ifdef Q_OS_ANDROID
    m_firebaseApp = ::firebase::App::Create(::firebase::AppOptions(), QAndroidJniEnvironment(),
                                                QtAndroid::androidActivity().object());

    m_client_pointer = this;

    m_firebase_initializer.Initialize(m_firebaseApp,
                                         nullptr, [](::firebase::App * fapp, void *) {
        qDebug() << "Trying to initialize Firebase Messaging";
        return ::firebase::messaging::Initialize(
                    *fapp,
                    (::firebase::messaging::Listener *)m_client_pointer);
    });

    while (m_firebase_initializer.InitializeLastResult().status() !=
            firebase::kFutureStatusComplete) {

        qDebug() << "Firebase: InitializeLastResult wait...";
    }
#endif
}

void PushNotifications::disconnectClient()
{
#ifdef Q_OS_ANDROID
    ::firebase::messaging::Terminate();
#endif
}

QString PushNotifications::token() const
{
    return m_token;
}

void PushNotifications::setAPNSRegistrationToken(const QString &apnsRegistrationToken)
{
    qDebug() << "Received APNS push notification token:" << apnsRegistrationToken;
    m_token = apnsRegistrationToken;
    emit tokenChanged();
}

#ifdef Q_OS_ANDROID
void PushNotifications::OnMessage(const firebase::messaging::Message &message)
{
    qDebug() << "Firebase message received:" << QString::fromStdString(message.from);
}

void PushNotifications::OnTokenReceived(const char *token)
{
    qDebug() << "Firebase token received:" << token;
    m_token = QString(token);
    emit tokenChanged();
}
#endif

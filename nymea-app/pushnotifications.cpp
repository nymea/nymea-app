#include "pushnotifications.h"

PushNotifications::PushNotifications(QObject *parent) : QObject(parent)
{

}

QObject *PushNotifications::pushNotificationsProvider(QQmlEngine *engine, QJSEngine *scriptEngine)
{
    return instance();
}

PushNotifications *PushNotifications::instance()
{
    static PushNotifications* pushNotifications = new PushNotifications();
    return pushNotifications;
}

QString PushNotifications::apnsRegistrationToken() const
{
    return m_apnsToken;
}

void PushNotifications::setAPNSRegistrationToken(const QString &apnsRegistrationToken)
{
    m_apnsToken = apnsRegistrationToken;
    apnsRegistrationTokenChanged(); //emit signal
}

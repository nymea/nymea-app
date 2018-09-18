#ifndef PUSHNOTIFICATIONS_H
#define PUSHNOTIFICATIONS_H

#include <QObject>
#include <QQmlEngine>

class PushNotifications : public QObject
{
    Q_OBJECT
public:
    explicit PushNotifications(QObject *parent = nullptr);

    static QObject* pushNotificationsProvider(QQmlEngine *engine, QJSEngine *scriptEngine);
    static PushNotifications* instance();

    QString apnsRegistrationToken() const;
    void setAPNSRegistrationToken(const QString &apnsRegistrationToken);

signals:
    void gcmRegistrationTokenChanged();
    void apnsRegistrationTokenChanged();
    void registeredChanged();

private:
    QString m_gcmToken;
    QString m_apnsToken;
};

#endif // PUSHNOTIFICATIONS_H

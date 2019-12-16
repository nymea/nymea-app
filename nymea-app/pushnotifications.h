#ifndef PUSHNOTIFICATIONS_H
#define PUSHNOTIFICATIONS_H

#include <QObject>
#include <QQmlEngine>

#ifdef Q_OS_ANDROID
#include "firebase/app.h"
#include "firebase/messaging.h"
#include "firebase/util.h"

#elif UBPORTS

#include "platformintegration/ubports/pushclient.h"

#endif

#ifdef Q_OS_ANDROID
class PushNotifications : public QObject, firebase::messaging::Listener
#else
class PushNotifications : public QObject
#endif
{
    Q_OBJECT
    Q_PROPERTY(QString token READ token NOTIFY tokenChanged)

public:
    explicit PushNotifications(QObject *parent = nullptr);

    static QObject* pushNotificationsProvider(QQmlEngine *engine, QJSEngine *scriptEngine);
    static PushNotifications* instance();

    void connectClient();
    void disconnectClient();

    QString token() const;

    // Called by Objective-C++
    void setAPNSRegistrationToken(const QString &apnsRegistrationToken);

signals:
    void tokenChanged();

protected:
#ifdef Q_OS_ANDROID
    //! Firebase overrides
    virtual void OnMessage(const ::firebase::messaging::Message &message) override;
    virtual void OnTokenReceived(const char *token) override;
private:
    ::firebase::App *m_firebaseApp = nullptr;
    ::firebase::ModuleInitializer  m_firebase_initializer;

#elif UBPORTS

    PushClient *m_pushClient = nullptr;

#endif

private:
    QString m_token;
};

#endif // PUSHNOTIFICATIONS_H

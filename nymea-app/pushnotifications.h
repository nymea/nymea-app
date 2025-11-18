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

#ifndef PUSHNOTIFICATIONS_H
#define PUSHNOTIFICATIONS_H

#include <QObject>
#include <QQmlEngine>

#if defined Q_OS_ANDROID && defined WITH_FIREBASE
#include "firebase/app.h"
#include "firebase/messaging.h"
#include "firebase/util.h"
#endif

#if defined UBPORTS
#include "platformintegration/ubports/pushclient.h"
#endif

#if defined Q_OS_ANDROID && defined WITH_FIREBASE
class PushNotifications : public QObject, firebase::messaging::Listener
#else
class PushNotifications : public QObject
#endif
{
    Q_OBJECT
    Q_PROPERTY(bool enabled READ enabled WRITE setEnabled NOTIFY enabledChanged)
    Q_PROPERTY(QString service READ service CONSTANT)
    Q_PROPERTY(QString clientId READ clientId CONSTANT)
    Q_PROPERTY(QString token READ token NOTIFY tokenChanged)

public:
    explicit PushNotifications(QObject *parent = nullptr);
    ~PushNotifications();

    static QObject* pushNotificationsProvider(QQmlEngine *engine, QJSEngine *scriptEngine);
    static PushNotifications* instance();

    bool enabled() const;
    void setEnabled(bool enabled);

    QString service() const;
    QString clientId() const;
    QString token() const;

    // Called by Objective-C++ on iOS
    void setFirebaseRegistrationToken(const QString &firebaseRegistrationToken);

signals:
    void enabledChanged();
    void tokenChanged();

protected:

#if defined Q_OS_ANDROID && defined WITH_FIREBASE
    //! Firebase overrides
    virtual void OnMessage(const ::firebase::messaging::Message &message) override;
    virtual void OnTokenReceived(const char *token) override;
private:
    ::firebase::App *m_firebaseApp = nullptr;
    ::firebase::ModuleInitializer  m_firebase_initializer;
#endif

#if defined UBPORTS
    PushClient *m_pushClient = nullptr;
#endif

private:

    void registerForPush();


#ifdef Q_OS_IOS
    void registerObjC();
#endif

    bool m_enabled = false;
    QString m_token;
};

#endif // PUSHNOTIFICATIONS_H

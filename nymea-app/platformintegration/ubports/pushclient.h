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

#ifndef PUSHCLIENT_H
#define PUSHCLIENT_H

#include <QObject>
#include <QString>
#include <QStringList>
#include <connectivityqt/connectivity.h>

class QDBusPendingCallWatcher;

class PushClient : public QObject
{
    Q_OBJECT
public:
    explicit PushClient(QObject *parent = 0);
    void setAppId(const QString &appid);
    QString getStatus() {return this->status;}
    QString getAppId();
    QString getToken();
    QStringList getPersistent();
    void setCount(int count);
    int getCount();

    Q_PROPERTY(QString appId WRITE setAppId READ getAppId NOTIFY appIdChanged)
    Q_PROPERTY(QString token READ getToken NOTIFY tokenChanged)
    Q_PROPERTY(QStringList notifications MEMBER notifications NOTIFY notificationsChanged)
    Q_PROPERTY(QString status READ getStatus NOTIFY statusChanged)
    Q_PROPERTY(QStringList persistent READ getPersistent NOTIFY persistentChanged)
    Q_PROPERTY(int count READ getCount WRITE setCount NOTIFY countChanged)

signals:
    void countChanged(int count);
    void notificationsChanged(const QStringList &notifications);
    void persistentChanged(const QStringList &tags);
    void appIdChanged(const QString &appId);
    void error(const QString &error);
    void tokenChanged(const QString &token);
    void statusChanged(const QString &status);

public slots:
    void getNotifications();
    void notified(const QString &appId);
    void emitError();
    void clearPersistent(const QStringList &tags);

private slots:
    void registerFinished(QDBusPendingCallWatcher *watcher);
    void popAllFinished(QDBusPendingCallWatcher *watcher);
    void setCounterFinished(QDBusPendingCallWatcher *watcher);
    void clearPersistentFinished(QDBusPendingCallWatcher *watcher);
    void connectionStatusChanged(bool status);

private:
    void registerApp();

    QScopedPointer<connectivityqt::Connectivity> ns;
    QString appId;
    QString pkgname;
    QString token;
    QString status;
    QStringList notifications;
    int counter;
};

#endif // PUSHCLIENT_H

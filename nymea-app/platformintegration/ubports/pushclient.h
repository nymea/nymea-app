/*
Copyright 2014 Canonical Ltd.

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Lesser General Public License, version 3
as published by the Free Software Foundation.

This program is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public
License along with this program.  If not, see
<http://www.gnu.org/licenses/>.
*/

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

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

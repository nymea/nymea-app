// SPDX-License-Identifier: LGPL-3.0-or-later

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
* Copyright (C) 2013 - 2024, nymea GmbH
* Copyright (C) 2024 - 2025, chargebyte austria GmbH
*
* This file is part of libnymea-app.
*
* libnymea-app is free software: you can redistribute it and/or
* modify it under the terms of the GNU Lesser General Public License
* as published by the Free Software Foundation, either version 3
* of the License, or (at your option) any later version.
*
* libnymea-app is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
* GNU Lesser General Public License for more details.
*
* You should have received a copy of the GNU Lesser General Public License
* along with libnymea-app. If not, see <https://www.gnu.org/licenses/>.
*
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#ifndef USERINFO_H
#define USERINFO_H

#include <QUuid>
#include <QObject>

class UserInfo : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString username READ username WRITE setUsername NOTIFY usernameChanged)
    Q_PROPERTY(QString email READ email WRITE setEmail NOTIFY emailChanged)
    Q_PROPERTY(QString displayName READ displayName WRITE setDisplayName NOTIFY displayNameChanged)
    Q_PROPERTY(PermissionScopes scopes READ scopes WRITE setScopes NOTIFY scopesChanged)
    Q_PROPERTY(QList<QUuid> allowedThingIds READ allowedThingIds WRITE setAllowedThingIds NOTIFY allowedThingIdsChanged)

public:
    enum PermissionScope {
        PermissionScopeNone             = 0x0000,
        PermissionScopeControlThings    = 0x0001,
        PermissionScopeConfigureThings  = 0x0003,
        PermissionScopeAccessAllThings  = 0x0004, // Since 8.4
        PermissionScopeExecuteRules     = 0x0010,
        PermissionScopeConfigureRules   = 0x0030,
        PermissionScopeAdmin            = 0xFFFF,
    };
    Q_DECLARE_FLAGS(PermissionScopes, PermissionScope)
    Q_FLAG(PermissionScopes)

    explicit UserInfo(QObject *parent = nullptr);
    explicit UserInfo(const QString &username, QObject *parent = nullptr);

    QString username() const;
    void setUsername(const QString &username);

    QString email() const;
    void setEmail(const QString &email);

    QString displayName() const;
    void setDisplayName(const QString &displayName);

    PermissionScopes scopes() const;
    void setScopes(PermissionScopes scopes);

    QList<QUuid> allowedThingIds() const;
    void setAllowedThingIds(const QList<QUuid> &allowedThingIds);

    Q_INVOKABLE bool thingAllowed(const QUuid &thingId) const;
    Q_INVOKABLE void allowThingId(const QUuid &thingId, bool allowed);

    static QStringList scopesToList(PermissionScopes scopes);
    static PermissionScopes listToScopes(const QStringList &scopeList);

signals:
    void usernameChanged();
    void emailChanged();
    void displayNameChanged();
    void scopesChanged();
    void allowedThingIdsChanged();

private:
    QString m_username;
    QString m_email;
    QString m_displayName;
    PermissionScopes m_scopes = PermissionScopeNone;
    QList<QUuid> m_allowedThingIds;

};

Q_DECLARE_METATYPE(UserInfo::PermissionScope)
Q_DECLARE_METATYPE(UserInfo::PermissionScopes)

#endif // USERINFO_H

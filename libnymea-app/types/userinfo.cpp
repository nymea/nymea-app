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

#include "userinfo.h"

#include <QMetaEnum>
#include <QDebug>

UserInfo::UserInfo(QObject *parent):
    QObject(parent)
{
    qRegisterMetaType<UserInfo::PermissionScopes>("UserInfo.PermissionScopes");
}

UserInfo::UserInfo(const QString &username, QObject *parent):
    QObject(parent),
    m_username(username)
{

}

QString UserInfo::username() const
{
    return m_username;
}

void UserInfo::setUsername(const QString &username)
{
    if (m_username != username) {
        m_username = username;
        emit usernameChanged();
    }
}

QString UserInfo::email() const
{
    return m_email;
}

void UserInfo::setEmail(const QString &email)
{
    if (m_email != email) {
        m_email = email;
        emit emailChanged();
    }
}

QString UserInfo::displayName() const
{
    return m_displayName;
}

void UserInfo::setDisplayName(const QString &displayName)
{
    if (m_displayName != displayName) {
        m_displayName = displayName;
        emit displayNameChanged();
    }
}

UserInfo::PermissionScopes UserInfo::scopes() const
{
    return m_scopes;
}

void UserInfo::setScopes(PermissionScopes scopes)
{
    if (m_scopes != scopes) {
        m_scopes = scopes;
        emit scopesChanged();
    }
}

QList<QUuid> UserInfo::allowedThingIds() const
{
    return m_allowedThingIds;
}

void UserInfo::setAllowedThingIds(const QList<QUuid> &allowedThingIds)
{
    if (m_allowedThingIds != allowedThingIds) {
        m_allowedThingIds = allowedThingIds;
        emit allowedThingIdsChanged();
    }
}

bool UserInfo::thingAllowed(const QUuid &thingId) const
{
    return m_allowedThingIds.contains(thingId);
}

void UserInfo::allowThingId(const QUuid &thingId, bool allowed)
{
    if (allowed) {
        if (!m_allowedThingIds.contains(thingId)) {
            m_allowedThingIds.append(thingId);
            emit allowedThingIdsChanged();
        }
    } else {
        if (m_allowedThingIds.contains(thingId)) {
            m_allowedThingIds.removeAll(thingId);
            emit allowedThingIdsChanged();
        }
    }
}

QStringList UserInfo::scopesToList(PermissionScopes scopes)
{
    QStringList ret;
    QMetaEnum metaEnum = QMetaEnum::fromType<PermissionScopes>();
    for (int i = 0; i < metaEnum.keyCount(); i++) {
        if (scopes.testFlag(static_cast<PermissionScope>(metaEnum.value(i)))) {
            ret << metaEnum.key(i);
        }
    }
    return ret;
}

UserInfo::PermissionScopes UserInfo::listToScopes(const QStringList &scopeList)
{
    PermissionScopes ret;
    QMetaEnum metaEnum = QMetaEnum::fromType<PermissionScopes>();
    for (int i = 0; i < metaEnum.keyCount(); i++) {
        if (scopeList.contains(metaEnum.key(i))) {
            ret.setFlag(static_cast<PermissionScope>(metaEnum.value(i)));
        }
    }
    return ret;
}

// SPDX-License-Identifier: LGPL-3.0-or-later

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
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

#include "invitationinfo.h"

InvitationInfo::InvitationInfo(const QUuid &id, const QString &username, const QDateTime &creationTime,
                               const QDateTime &expiryTime, int tokenValidityDuration, QObject *parent):
    QObject(parent),
    m_id(id),
    m_username(username),
    m_creationTime(creationTime),
    m_expiryTime(expiryTime),
    m_tokenValidityDuration(tokenValidityDuration)
{
}

QUuid InvitationInfo::id() const
{
    return m_id;
}

QString InvitationInfo::username() const
{
    return m_username;
}

QDateTime InvitationInfo::creationTime() const
{
    return m_creationTime;
}

QDateTime InvitationInfo::expiryTime() const
{
    return m_expiryTime;
}

int InvitationInfo::tokenValidityDuration() const
{
    return m_tokenValidityDuration;
}

InvitationInfo::RemovalState InvitationInfo::removalState() const
{
    return m_removalState;
}

void InvitationInfo::setRemovalState(RemovalState state)
{
    if (m_removalState == state) {
        return;
    }
    m_removalState = state;
    emit removalStateChanged();
}

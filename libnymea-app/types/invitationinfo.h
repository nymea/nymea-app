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

#ifndef INVITATIONINFO_H
#define INVITATIONINFO_H

#include <QDateTime>
#include <QObject>
#include <QUuid>

class InvitationInfo : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QUuid id READ id CONSTANT)
    Q_PROPERTY(QString username READ username CONSTANT)
    Q_PROPERTY(QDateTime creationTime READ creationTime CONSTANT)
    Q_PROPERTY(QDateTime expiryTime READ expiryTime CONSTANT)
    // -1 means absent: the redeemed regular client token never expires. The invitation's
    // own expiryTime above is always set and unrelated - it bounds the invitation, not
    // the token minted on redemption.
    Q_PROPERTY(int tokenValidityDuration READ tokenValidityDuration CONSTANT)
    // Per-row UI state for the revoke action, so a repeated click while a removal is
    // already in flight cannot send a duplicate Users.RemoveInvitation, and a failed
    // removal restores the action instead of leaving the row stuck.
    Q_PROPERTY(RemovalState removalState READ removalState NOTIFY removalStateChanged)

public:
    enum RemovalState {
        RemovalStateIdle,
        RemovalStatePending,
        RemovalStateError
    };
    Q_ENUM(RemovalState)

    explicit InvitationInfo(const QUuid &id, const QString &username, const QDateTime &creationTime,
                             const QDateTime &expiryTime, int tokenValidityDuration = -1, QObject *parent = nullptr);

    QUuid id() const;
    QString username() const;
    QDateTime creationTime() const;
    QDateTime expiryTime() const;
    int tokenValidityDuration() const;

    RemovalState removalState() const;
    void setRemovalState(RemovalState state);

signals:
    void removalStateChanged();

private:
    QUuid m_id;
    QString m_username;
    QDateTime m_creationTime;
    QDateTime m_expiryTime;
    int m_tokenValidityDuration;
    RemovalState m_removalState = RemovalStateIdle;
};

#endif // INVITATIONINFO_H

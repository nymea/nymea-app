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

#ifndef INVITATIONS_H
#define INVITATIONS_H

#include <QAbstractListModel>

class InvitationInfo;

class Invitations : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)
    Q_PROPERTY(State state READ state NOTIFY stateChanged)
    Q_PROPERTY(QString errorMessage READ errorMessage NOTIFY stateChanged)

public:
    enum Roles {
        RoleId,
        RoleUsername,
        RoleCreationTime,
        RoleExpiryTime,
        RoleTokenValidityDuration,
        RoleRemovalState
    };

    // idle: never loaded yet (e.g. invitationApiAvailable is false). loading: a
    // Users.GetInvitations request is in flight (initial load or refresh). ready: the
    // last request succeeded, even if the resulting list is empty. error: the last
    // request failed or returned ambiguously; errorMessage carries a translatable reason
    // and the caller re-requests the same load to retry.
    enum State {
        StateIdle,
        StateLoading,
        StateReady,
        StateError
    };
    Q_ENUM(State)

    explicit Invitations(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

    State state() const;
    void setState(State state);
    QString errorMessage() const;
    void setErrorMessage(const QString &errorMessage);

    // Upserts by id, keeping the list sorted by expiry then id (matches the order a
    // reconciled Users.GetInvitations reply and individual InvitationAdded notifications
    // must agree on regardless of arrival order).
    void addOrUpdateInvitation(InvitationInfo *invitationInfo);
    void removeInvitation(const QUuid &invitationId);
    void clear();

    Q_INVOKABLE InvitationInfo *get(int index) const;
    Q_INVOKABLE InvitationInfo *getInvitation(const QUuid &invitationId) const;

signals:
    void countChanged();
    void stateChanged();

private:
    int sortedInsertionIndex(InvitationInfo *invitationInfo) const;

    QList<InvitationInfo *> m_list;
    State m_state = StateIdle;
    QString m_errorMessage;
};

#endif // INVITATIONS_H

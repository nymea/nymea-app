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

#include "invitations.h"
#include "invitationinfo.h"

Invitations::Invitations(QObject *parent): QAbstractListModel(parent)
{
}

int Invitations::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return static_cast<int>(m_list.count());
}

QVariant Invitations::data(const QModelIndex &index, int role) const
{
    InvitationInfo *invitationInfo = m_list.at(index.row());
    switch (role) {
    case RoleId:
        return invitationInfo->id();
    case RoleUsername:
        return invitationInfo->username();
    case RoleCreationTime:
        return invitationInfo->creationTime();
    case RoleExpiryTime:
        return invitationInfo->expiryTime();
    case RoleTokenValidityDuration:
        return invitationInfo->tokenValidityDuration();
    case RoleRemovalState:
        return invitationInfo->removalState();
    }
    return QVariant();
}

QHash<int, QByteArray> Invitations::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles.insert(RoleId, "id");
    roles.insert(RoleUsername, "username");
    roles.insert(RoleCreationTime, "creationTime");
    roles.insert(RoleExpiryTime, "expiryTime");
    roles.insert(RoleTokenValidityDuration, "tokenValidityDuration");
    roles.insert(RoleRemovalState, "removalState");
    return roles;
}

Invitations::State Invitations::state() const
{
    return m_state;
}

void Invitations::setState(State state)
{
    if (m_state == state) {
        return;
    }
    m_state = state;
    emit stateChanged();
}

QString Invitations::errorMessage() const
{
    return m_errorMessage;
}

void Invitations::setErrorMessage(const QString &errorMessage)
{
    if (m_errorMessage == errorMessage) {
        return;
    }
    m_errorMessage = errorMessage;
    emit stateChanged();
}

int Invitations::sortedInsertionIndex(InvitationInfo *invitationInfo) const
{
    int i = 0;
    for (; i < m_list.count(); i++) {
        InvitationInfo *existing = m_list.at(i);
        if (existing->expiryTime() > invitationInfo->expiryTime()) {
            break;
        }
        if (existing->expiryTime() == invitationInfo->expiryTime()
                && existing->id().toString() > invitationInfo->id().toString()) {
            break;
        }
    }
    return i;
}

void Invitations::addOrUpdateInvitation(InvitationInfo *invitationInfo)
{
    invitationInfo->setParent(this);

    for (int i = 0; i < m_list.count(); i++) {
        if (m_list.at(i)->id() == invitationInfo->id()) {
            // Only the fields the server can actually change matter (removal state is
            // local UI-only). Reinserting at a possibly different sorted position keeps
            // ordering correct if a reconciled reply ever changes an invitation's expiry.
            beginRemoveRows(QModelIndex(), i, i);
            m_list.takeAt(i)->deleteLater();
            endRemoveRows();
            break;
        }
    }

    int insertAt = sortedInsertionIndex(invitationInfo);
    beginInsertRows(QModelIndex(), insertAt, insertAt);
    m_list.insert(insertAt, invitationInfo);
    endInsertRows();
    emit countChanged();
}

void Invitations::removeInvitation(const QUuid &invitationId)
{
    for (int i = 0; i < m_list.count(); i++) {
        if (m_list.at(i)->id() == invitationId) {
            beginRemoveRows(QModelIndex(), i, i);
            m_list.takeAt(i)->deleteLater();
            endRemoveRows();
            emit countChanged();
            return;
        }
    }
}

void Invitations::clear()
{
    if (m_list.isEmpty()) {
        return;
    }
    beginRemoveRows(QModelIndex(), 0, static_cast<int>(m_list.count()) - 1);
    foreach (InvitationInfo *invitationInfo, m_list) {
        invitationInfo->deleteLater();
    }
    m_list.clear();
    endRemoveRows();
    emit countChanged();
}

InvitationInfo *Invitations::get(int index) const
{
    if (index < 0 || index >= m_list.count()) {
        return nullptr;
    }
    return m_list.at(index);
}

InvitationInfo *Invitations::getInvitation(const QUuid &invitationId) const
{
    for (int i = 0; i < m_list.count(); i++) {
        if (m_list.at(i)->id() == invitationId) {
            return m_list.at(i);
        }
    }
    return nullptr;
}

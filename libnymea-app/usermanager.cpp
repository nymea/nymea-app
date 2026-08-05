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

#include "usermanager.h"
#include "types/tokeninfo.h"
#include "types/invitationinfo.h"

#include <QDebug>
#include <QMetaEnum>
#include <QSet>

#include "logging.h"
NYMEA_LOGGING_CATEGORY(dcUserManager, "UserManager")

UserManager::UserManager(QObject *parent):
    QObject(parent)
{
    qRegisterMetaType<UserInfo::PermissionScopes>();
    m_userInfo = new UserInfo(this);
    m_tokenInfos = new TokenInfos(this);
    m_users = new Users(this);
    m_invitations = new Invitations(this);
}

UserManager::~UserManager()
{
    if (m_engine) {
        m_engine->jsonRpcClient()->unregisterNotificationHandler(this);
    }
}

Engine *UserManager::engine() const
{
    return m_engine;
}

void UserManager::setEngine(Engine *engine)
{
    if (m_engine != engine) {
        if (m_engine) {
            m_engine->jsonRpcClient()->unregisterNotificationHandler(this);
            disconnect(m_engine->jsonRpcClient(), &JsonRpcClient::invitationApiAvailableChanged, this, nullptr);
        }

        m_engine = engine;
        emit engineChanged();

        if (m_engine) {
            m_engine->jsonRpcClient()->registerNotificationHandler(this, "Users", "notificationReceived");

            m_loading = true;
            emit loadingChanged();

            m_engine->jsonRpcClient()->sendCommand("Users.GetUsers", QVariantMap(), this, "getUsersResponse");
            m_engine->jsonRpcClient()->sendCommand("Users.GetUserInfo", QVariantMap(), this, "getUserInfoResponse");
            m_engine->jsonRpcClient()->sendCommand("Users.GetTokens", QVariantMap(), this, "getTokensResponse");

            m_invitations->clear();
            if (m_engine->jsonRpcClient()->invitationApiAvailable()) {
                refreshInvitations();
            } else {
                m_invitations->setState(Invitations::StateIdle);
            }
            connect(m_engine->jsonRpcClient(), &JsonRpcClient::invitationApiAvailableChanged, this, [this]() {
                if (m_engine->jsonRpcClient()->invitationApiAvailable()) {
                    refreshInvitations();
                } else {
                    m_invitations->clear();
                    m_invitations->setState(Invitations::StateIdle);
                }
            });
        }
    }
}

bool UserManager::loading() const
{
    return m_loading;
}

UserInfo *UserManager::userInfo() const
{
    return m_userInfo;
}

TokenInfos *UserManager::tokenInfos() const
{
    return m_tokenInfos;
}

Users *UserManager::users() const
{
    return m_users;
}

Invitations *UserManager::invitations() const
{
    return m_invitations;
}

int UserManager::createUser(const QString &username, const QString &password, const QString &displayName, const QString &email, int permissionScopes, const QList<QUuid> &allowedThingIds)
{
    QVariantMap params;
    params.insert("username", username);
    params.insert("password", password);
    if (m_engine->jsonRpcClient()->ensureServerVersion("6.0")) {
        params.insert("displayName", displayName);
        params.insert("email", email);

        // Backports compatibility for pre 8.4
        UserInfo::PermissionScopes scopes = static_cast<UserInfo::PermissionScopes>(permissionScopes);
        if (!m_engine->jsonRpcClient()->ensureServerVersion("8.4"))
            scopes.setFlag(UserInfo::PermissionScopeAccessAllThings, false);


        params.insert("scopes", UserInfo::scopesToList(scopes));
    }

    if (m_engine->jsonRpcClient()->ensureServerVersion("8.4") && !allowedThingIds.isEmpty()) {
        QVariantList thingIds;
        foreach (const QUuid &thingId, allowedThingIds)
            thingIds.append(thingId.toString());

        params.insert("allowedThingIds", thingIds);
    }
    qCDebug(dcUserManager()) << "Creating user" << username << permissionScopes << allowedThingIds;
    return m_engine->jsonRpcClient()->sendCommand("Users.CreateUser", params, this, "createUserResponse");
}

int UserManager::changePassword(const QString &newPassword)
{
    QVariantMap params;
    params.insert("newPassword", newPassword);
    int callId = m_engine->jsonRpcClient()->sendCommand("Users.ChangePassword", params, this, "changePasswordResponse");
    return callId;
}

int UserManager::removeToken(const QUuid &id)
{
    QVariantMap params;
    params.insert("tokenId", id);
    int callId = m_engine->jsonRpcClient()->sendCommand("Users.RemoveToken", params, this, "removeTokenResponse");
    m_tokensToBeRemoved.insert(callId, id);
    return callId;
}

int UserManager::removeUser(const QString &username)
{
    QVariantMap params;
    params.insert("username", username);
    return m_engine->jsonRpcClient()->sendCommand("Users.RemoveUser", params, this, "removeUserResponse");
}

int UserManager::setUserScopes(const QString &username, int scopes, const QList<QUuid> &allowedThingIds)
{
    QVariantMap params;
    params.insert("username", username);

    // Backports compatibility for pre 8.4
    UserInfo::PermissionScopes finalScopes = static_cast<UserInfo::PermissionScopes>(scopes);
    if (!m_engine->jsonRpcClient()->ensureServerVersion("8.4"))
        finalScopes.setFlag(UserInfo::PermissionScopeAccessAllThings, false);

    params.insert("scopes", UserInfo::scopesToList(finalScopes));

    if (m_engine->jsonRpcClient()->ensureServerVersion("8.4")) {
        QVariantList thingIds;
        foreach (const QUuid &thingId, allowedThingIds)
            thingIds.append(thingId.toString());

        params.insert("allowedThingIds", thingIds);
    }
    qCDebug(dcUserManager()) << "Setting new permission scopes for user" << username << scopes << (int)scopes << allowedThingIds;
    return m_engine->jsonRpcClient()->sendCommand("Users.SetUserScopes", params, this, "setUserScopesResponse");
}

int UserManager::setUserInfo(const QString &username, const QString &displayName, const QString &email)
{
    QVariantMap params;
    params.insert("username", username);
    params.insert("displayName", displayName);
    params.insert("email", email);
    qCDebug(dcUserManager()) << "Setting new info for user" << username << displayName << email;
    return m_engine->jsonRpcClient()->sendCommand("Users.SetUserInfo", params, this, "setUserInfoResponse");
}

void UserManager::refreshTokens()
{
    if (!m_engine)
        return;
    m_engine->jsonRpcClient()->sendCommand("Users.GetTokens", QVariantMap(), this, "getTokensResponse");
}

int UserManager::createInvitation(const QString &username, int validityDuration, int tokenValidityDuration)
{
    QVariantMap params;
    params.insert("username", username);
    if (validityDuration >= 0) {
        params.insert("validityDuration", validityDuration);
    }
    if (tokenValidityDuration >= 0) {
        params.insert("tokenValidityDuration", tokenValidityDuration);
    }
    qCDebug(dcUserManager()) << "Creating invitation for user" << username;
    return m_engine->jsonRpcClient()->sendCommand("Users.CreateInvitation", params, this, "createInvitationResponse");
}

int UserManager::removeInvitation(const QUuid &invitationId)
{
    InvitationInfo *invitationInfo = m_invitations->getInvitation(invitationId);
    if (invitationInfo) {
        invitationInfo->setRemovalState(InvitationInfo::RemovalStatePending);
    }

    QVariantMap params;
    params.insert("invitationId", invitationId);
    int callId = m_engine->jsonRpcClient()->sendCommand("Users.RemoveInvitation", params, this, "removeInvitationResponse");
    m_invitationsToBeRemoved.insert(callId, invitationId);
    return callId;
}

void UserManager::refreshInvitations(const QString &username)
{
    if (!m_engine)
        return;
    m_invitations->setState(Invitations::StateLoading);
    QVariantMap params;
    if (!username.isEmpty()) {
        params.insert("username", username);
    }
    int callId = m_engine->jsonRpcClient()->sendCommand("Users.GetInvitations", params, this, "getInvitationsResponse");
    m_invitationsRequestFilter.insert(callId, username);
}

InvitationInfo *UserManager::invitationInfoFromMap(const QVariantMap &invitationMap, QObject *parent)
{
    QUuid id = invitationMap.value("id").toUuid();
    QString username = invitationMap.value("username").toString();
    QDateTime creationTime = QDateTime::fromSecsSinceEpoch(invitationMap.value("creationTime").toLongLong());
    QDateTime expiryTime = QDateTime::fromSecsSinceEpoch(invitationMap.value("expiryTime").toLongLong());
    // Optional: absent from the map entirely when the redeemed token is meant to never
    // expire - -1 is InvitationInfo's sentinel for that, matching TokenInfo's invalid-
    // QDateTime idiom for the same "unset" semantics on a different property type.
    int tokenValidityDuration = -1;
    if (invitationMap.contains("tokenValidityDuration")) {
        tokenValidityDuration = invitationMap.value("tokenValidityDuration").toInt();
    }
    return new InvitationInfo(id, username, creationTime, expiryTime, tokenValidityDuration, parent);
}

void UserManager::notificationReceived(const QVariantMap &data)
{
    qCDebug(dcUserManager()) << "Users notification" << data;
    QString notification = data.value("notification").toString();
    if (notification == "Users.UserAdded") {
        QVariantMap userMap = data.value("params").toMap().value("userInfo").toMap();
        UserInfo *info = new UserInfo(userMap.value("username").toString());
        info->setDisplayName(userMap.value("displayName").toString());
        info->setEmail(userMap.value("email").toString());
        info->setScopes(UserInfo::listToScopes(userMap.value("scopes").toStringList()));
        QList<QUuid> allowedThingIds;
        foreach (const QString &thingIdString, userMap.value("allowedThingIds").toStringList())
            allowedThingIds.append(QUuid(thingIdString));

        info->setAllowedThingIds(allowedThingIds);
        m_users->insertUser(info);
    } else if (notification == "Users.UserRemoved") {
        m_users->removeUser(data.value("params").toMap().value("username").toString());
    } else if (notification == "Users.UserChanged") {
        QVariantMap userMap = data.value("params").toMap().value("userInfo").toMap();
        QString username = userMap.value("username").toString();
        QString displayName = userMap.value("displayName").toString();
        QString email = userMap.value("email").toString();
        UserInfo::PermissionScopes scopes = UserInfo::listToScopes(userMap.value("scopes").toStringList());

        QList<QUuid> allowedThingIds;
        foreach (const QString &thingIdString, userMap.value("allowedThingIds").toStringList())
            allowedThingIds.append(QUuid(thingIdString));


        // Update current user info
        if (m_userInfo && m_userInfo->username() == username) {
            m_userInfo->setDisplayName(displayName);
            m_userInfo->setEmail(email);
            m_userInfo->setScopes(scopes);
            m_userInfo->setAllowedThingIds(allowedThingIds);

        }
        // Update user info in the list of all users.
        UserInfo *info = m_users->getUserInfo(username);
        if (!info) {
            qCWarning(dcUserManager()) << "Received a change notification for a user we don't know:" << username;
            return;
        }
        info->setDisplayName(displayName);
        info->setEmail(email);
        info->setScopes(scopes);
        info->setAllowedThingIds(allowedThingIds);
    } else if (notification == "Users.InvitationAdded") {
        QVariantMap invitationMap = data.value("params").toMap().value("invitation").toMap();
        m_invitations->addOrUpdateInvitation(invitationInfoFromMap(invitationMap));
    } else if (notification == "Users.InvitationRemoved") {
        QUuid invitationId = data.value("params").toMap().value("invitationId").toUuid();
        m_invitations->removeInvitation(invitationId);
    }
}

void UserManager::getUsersResponse(int commandId, const QVariantMap &data)
{
    qCDebug(dcUserManager) << "Get users response:" << commandId << data;

    foreach (const QVariant &userVariant, data.value("users").toList()) {
        QVariantMap userMap = userVariant.toMap();

        QList<QUuid> allowedThingIds;
        foreach (const QString &thingIdString, userMap.value("allowedThingIds").toStringList())
            allowedThingIds.append(QUuid(thingIdString));

        UserInfo *userInfo = new UserInfo(userMap.value("username").toString());
        userInfo->setDisplayName(userMap.value("displayName").toString());
        userInfo->setEmail(userMap.value("email").toString());
        userInfo->setScopes(UserInfo::listToScopes(userMap.value("scopes").toStringList()));
        userInfo->setAllowedThingIds(allowedThingIds);
        m_users->insertUser(userInfo);
    }
}

void UserManager::getUserInfoResponse(int commandId, const QVariantMap &data)
{
    qCDebug(dcUserManager()) << "User info reply" << commandId << data;
    QVariantMap userMap = data.value("userInfo").toMap();
    QList<QUuid> allowedThingIds;
    foreach (const QString &thingIdString, userMap.value("allowedThingIds").toStringList())
        allowedThingIds.append(QUuid(thingIdString));

    m_userInfo->setUsername(userMap.value("username").toString());
    m_userInfo->setEmail(userMap.value("email").toString());
    m_userInfo->setDisplayName(userMap.value("displayName").toString());
    m_userInfo->setScopes(UserInfo::listToScopes(userMap.value("scopes").toStringList()));
    m_userInfo->setAllowedThingIds(allowedThingIds);
}

void UserManager::getTokensResponse(int commandId, const QVariantMap &data)
{
    Q_UNUSED(commandId)
    // The full list is authoritative on every response (initial load and refreshTokens()
    // alike); clear first so a refresh doesn't duplicate every existing entry.
    m_tokenInfos->clear();
    foreach (const QVariant &tokenVariant, data.value("tokenInfoList").toList()) {
        //        qDebug() << "Token received" << tokenVariant.toMap();
        QVariantMap token = tokenVariant.toMap();
        QUuid id = token.value("id").toUuid();
        QString username = token.value("username").toString();
        QString deviceName = token.value("deviceName").toString();
        QDateTime creationTime = QDateTime::fromSecsSinceEpoch(token.value("creationTime").toInt());
        // Optional fields: absent from the map entirely when unset. Do not default to
        // epoch 0 - an invalid QDateTime means "never expires"/"not yet observed".
        QDateTime expiryTime;
        if (token.contains("expiryTime"))
            expiryTime = QDateTime::fromSecsSinceEpoch(token.value("expiryTime").toLongLong());
        QDateTime lastSeen;
        if (token.contains("lastSeen"))
            lastSeen = QDateTime::fromSecsSinceEpoch(token.value("lastSeen").toLongLong());
        TokenInfo *tokenInfo = new TokenInfo(id, username, deviceName, creationTime, expiryTime, lastSeen);
        m_tokenInfos->addToken(tokenInfo);
    }
}

void UserManager::removeTokenResponse(int commandId, const QVariantMap &params)
{
    qCDebug(dcUserManager()) << "Delete token reply" << commandId << params;
    QUuid tokenId = m_tokensToBeRemoved.take(commandId);
    QString errorString = params.value("error").toString();
    QMetaEnum metaEnum = QMetaEnum::fromType<UserManager::UserError>();
    UserError error = static_cast<UserError>(metaEnum.keyToValue(errorString.toUtf8()));

    emit removeTokenReply(commandId, error);

    if (error == UserErrorNoError) {
        m_tokenInfos->removeToken(tokenId);
    }
}

void UserManager::getInvitationsResponse(int commandId, const QVariantMap &params)
{
    qCDebug(dcUserManager()) << "Get invitations response:" << commandId << params;
    QString requestFilter = m_invitationsRequestFilter.take(commandId);

    QString errorString = params.value("error").toString();
    QMetaEnum metaEnum = QMetaEnum::fromType<UserManager::UserError>();
    UserError error = static_cast<UserError>(metaEnum.keyToValue(errorString.toUtf8()));

    if (error != UserErrorNoError) {
        // Ambiguous/failed load: keep whatever was already reconciled from notifications
        // rather than clearing it, and let the caller retry via refreshInvitations().
        m_invitations->setErrorMessage(errorString);
        m_invitations->setState(Invitations::StateError);
        return;
    }

    // The list is authoritative for its own filter scope on every successful response;
    // reconcile by id so an InvitationAdded/InvitationRemoved notification racing this
    // reply is never clobbered or duplicated.
    QSet<QUuid> receivedIds;
    foreach (const QVariant &invitationVariant, params.value("invitations").toList()) {
        InvitationInfo *invitationInfo = invitationInfoFromMap(invitationVariant.toMap());
        receivedIds.insert(invitationInfo->id());
        m_invitations->addOrUpdateInvitation(invitationInfo);
    }
    // Only an unfiltered ("all users") response is authoritative enough to prune rows it
    // didn't return - a per-user filtered refresh must not remove other users' rows.
    if (requestFilter.isEmpty()) {
        for (int i = m_invitations->rowCount() - 1; i >= 0; i--) {
            InvitationInfo *existing = m_invitations->get(i);
            if (existing && !receivedIds.contains(existing->id())) {
                m_invitations->removeInvitation(existing->id());
            }
        }
    }

    m_invitations->setState(Invitations::StateReady);
}

void UserManager::createInvitationResponse(int commandId, const QVariantMap &params)
{
    qCDebug(dcUserManager()) << "Create invitation response:" << commandId;
    QMetaEnum metaEnum = QMetaEnum::fromType<UserManager::UserError>();
    UserError error = static_cast<UserError>(metaEnum.keyToValue(params.value("error").toString().toUtf8()));

    QByteArray token;
    QUuid invitationId;
    if (error == UserErrorNoError && params.contains("token") && params.contains("invitation")) {
        token = params.value("token").toByteArray();
        QVariantMap invitationMap = params.value("invitation").toMap();
        invitationId = invitationMap.value("id").toUuid();
        m_invitations->addOrUpdateInvitation(invitationInfoFromMap(invitationMap));
    } else if (error == UserErrorNoError) {
        // Malformed success payload: treat as a protocol-level failure rather than
        // reporting a nonexistent invitation as created.
        error = UserErrorBackendError;
    }

    emit createInvitationReply(commandId, error, token, invitationId);
}

void UserManager::removeInvitationResponse(int commandId, const QVariantMap &params)
{
    qCDebug(dcUserManager()) << "Remove invitation response:" << commandId << params;
    QUuid invitationId = m_invitationsToBeRemoved.take(commandId);
    QMetaEnum metaEnum = QMetaEnum::fromType<UserManager::UserError>();
    UserError error = static_cast<UserError>(metaEnum.keyToValue(params.value("error").toString().toUtf8()));

    emit removeInvitationReply(commandId, error);

    if (error != UserErrorNoError) {
        // Success is reconciled via the InvitationRemoved notification instead of being
        // applied here directly, so a racing notification can never double-remove or
        // fight this response for the row.
        InvitationInfo *invitationInfo = m_invitations->getInvitation(invitationId);
        if (invitationInfo) {
            invitationInfo->setRemovalState(InvitationInfo::RemovalStateError);
        }
    }
}

void UserManager::changePasswordResponse(int commandId, const QVariantMap &params)
{
    qCDebug(dcUserManager()) << "Change password reply" << commandId << params;

    QString errorString = params.value("error").toString();
    QMetaEnum metaEnum = QMetaEnum::fromType<UserManager::UserError>();
    UserError error = static_cast<UserError>(metaEnum.keyToValue(errorString.toUtf8()));

    emit changePasswordReply(commandId, error);
}

void UserManager::createUserResponse(int commandId, const QVariantMap &params)
{
    qCDebug(dcUserManager()) << "Create user response:" << commandId << params;
    QMetaEnum metaEnum = QMetaEnum::fromType<UserManager::UserError>();
    UserError error = static_cast<UserError>(metaEnum.keyToValue(params.value("error").toString().toUtf8()));
    emit createUserReply(commandId, error);
}

void UserManager::removeUserResponse(int commandId, const QVariantMap &params)
{
    qCDebug(dcUserManager()) << "Remove user response:" << commandId << params;
    QMetaEnum metaEnum = QMetaEnum::fromType<UserManager::UserError>();
    UserError error = static_cast<UserError>(metaEnum.keyToValue(params.value("error").toString().toUtf8()));
    emit removeUserReply(commandId, error);
}

void UserManager::setUserScopesResponse(int commandId, const QVariantMap &params)
{
    qCDebug(dcUserManager()) << "Set user scopes response:" << commandId << params;
    QMetaEnum metaEnum = QMetaEnum::fromType<UserManager::UserError>();
    UserError error = static_cast<UserError>(metaEnum.keyToValue(params.value("error").toString().toUtf8()));
    emit setUserScopesReply(commandId, error);
}

void UserManager::setUserInfoResponse(int commandId, const QVariantMap &params)
{
    qCDebug(dcUserManager()) << "Set user info response:" << commandId << params;
    QMetaEnum metaEnum = QMetaEnum::fromType<UserManager::UserError>();
    UserError error = static_cast<UserError>(metaEnum.keyToValue(params.value("error").toString().toUtf8()));
    emit setUserInfoReply(commandId, error);
}

Users::Users(QObject *parent): QAbstractListModel(parent)
{

}

int Users::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return static_cast<int>(m_users.count());
}

QVariant Users::data(const QModelIndex &index, int role) const
{
    switch (role) {
    case RoleUsername:
        return m_users.at(index.row())->username();
    case RoleDisplayName:
        return m_users.at(index.row())->displayName();
    case RoleEmail:
        return m_users.at(index.row())->email();
    case RoleScopes:
        return static_cast<int>(m_users.at(index.row())->scopes());
    case RoleAllowedThingIds: {
        QVariantList thingIds;
        foreach (const QUuid &thingId, m_users.at(index.row())->allowedThingIds())
            thingIds.append(thingId);

        return thingIds;
    }
    }
    return QVariant();
}

QHash<int, QByteArray> Users::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles.insert(RoleUsername, "username");
    roles.insert(RoleDisplayName, "displayName");
    roles.insert(RoleEmail, "email");
    roles.insert(RoleScopes, "scopes");
    roles.insert(RoleAllowedThingIds, "allowedThingIds");
    return roles;
}

void Users::insertUser(UserInfo *userInfo)
{
    userInfo->setParent(this);
    connect(userInfo, &UserInfo::displayNameChanged, this, [=](){
        int idx = static_cast<int>(m_users.indexOf(userInfo));
        if (idx >= 0) {
            emit dataChanged(index(idx), index(idx), {RoleDisplayName});
        }
    });
    connect(userInfo, &UserInfo::emailChanged, this, [=](){
        int idx = static_cast<int>(m_users.indexOf(userInfo));
        if (idx >= 0) {
            emit dataChanged(index(idx), index(idx), {RoleEmail});
        }
    });
    connect(userInfo, &UserInfo::scopesChanged, this, [=](){
        int idx = static_cast<int>(m_users.indexOf(userInfo));
        if (idx >= 0) {
            emit dataChanged(index(idx), index(idx), {RoleScopes});
        }
    });
    connect(userInfo, &UserInfo::allowedThingIdsChanged, this, [=](){
        int idx = m_users.indexOf(userInfo);
        if (idx >= 0) {
            emit dataChanged(index(idx), index(idx), {RoleAllowedThingIds});
        }
    });

    beginInsertRows(QModelIndex(), static_cast<int>(m_users.count()), static_cast<int>(m_users.count()));
    m_users.append(userInfo);
    endInsertRows();
    emit countChanged();
}

void Users::removeUser(const QString &username)
{
    for (int i = 0; i < m_users.count(); i++) {
        if (m_users.at(i)->username() == username) {
            beginRemoveRows(QModelIndex(), i, i);
            m_users.takeAt(i)->deleteLater();
            endRemoveRows();
            emit countChanged();
            return;
        }
    }
}

UserInfo *Users::get(int index) const
{
    if (index < 0 || index >= m_users.count()) {
        return nullptr;
    }
    return m_users.at(index);
}

UserInfo *Users::getUserInfo(const QString &username) const
{
    for (int i = 0; i < m_users.count(); i++) {
        if (m_users.at(i)->username() == username) {
            return m_users.at(i);
        }
    }
    return nullptr;
}

bool Users::contains(const QString &username) const
{
    return getUserInfo(username) != nullptr;
}

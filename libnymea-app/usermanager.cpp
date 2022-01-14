#include "usermanager.h"
#include "types/tokeninfo.h"

#include <QDebug>
#include <QMetaEnum>

#include "logging.h"
NYMEA_LOGGING_CATEGORY(dcUserManager, "UserManager")

UserManager::UserManager(QObject *parent):
    QObject(parent)
{
    qRegisterMetaType<UserInfo::PermissionScopes>();
    m_userInfo = new UserInfo(this);
    m_tokenInfos = new TokenInfos(this);
    m_users = new Users(this);
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

int UserManager::createUser(const QString &username, const QString &password, int permissionScopes)
{
    QVariantMap params;
    params.insert("username", username);
    params.insert("password", password);
    if (m_engine->jsonRpcClient()->ensureServerVersion("5.6")) {
        params.insert("scopes", UserInfo::scopesToList((UserInfo::PermissionScopes)permissionScopes));
    }
    qCDebug(dcUserManager()) << "Creating user" << username << permissionScopes;
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

int UserManager::setUserScopes(const QString &username, int scopes)
{
    QVariantMap params;
    params.insert("username", username);
    params.insert("scopes", UserInfo::scopesToList((UserInfo::PermissionScopes)scopes));
    qCDebug(dcUserManager()) << "Setting new permission scopes for user" << username << scopes << (int)scopes;
    return m_engine->jsonRpcClient()->sendCommand("Users.SetUserScopes", params, this, "setUserScopesResponse");
}

void UserManager::notificationReceived(const QVariantMap &data)
{
    qCDebug(dcUserManager()) << "Users notification" << data;
    QString notification = data.value("notification").toString();
    if (notification == "Users.UserAdded") {
        QVariantMap userMap = data.value("params").toMap().value("userInfo").toMap();
        UserInfo *info = new UserInfo(userMap.value("username").toString());
        info->setScopes(UserInfo::listToScopes(userMap.value("scopes").toStringList()));
        m_users->insertUser(info);
    } else if (notification == "Users.UserRemoved") {
        m_users->removeUser(data.value("params").toMap().value("username").toString());
    } else if (notification == "Users.UserChanged") {
        QVariantMap userMap = data.value("params").toMap().value("userInfo").toMap();
        QString username = userMap.value("username").toString();
        UserInfo *info = m_users->getUserInfo(username);
        if (!info) {
            qCWarning(dcUserManager()) << "Received a change notification for a user we don't know:" << username;
            return;
        }
        info->setScopes(UserInfo::listToScopes(userMap.value("scopes").toStringList()));
    }
}

void UserManager::getUsersResponse(int commandId, const QVariantMap &data)
{
    qCDebug(dcUserManager) << "Get users response:" << commandId << data;

    foreach (const QVariant &userVariant, data.value("users").toList()) {
        QVariantMap userMap = userVariant.toMap();
        UserInfo *userInfo = new UserInfo(userMap.value("username").toString());
        userInfo->setScopes(UserInfo::listToScopes(userMap.value("scopes").toStringList()));
        m_users->insertUser(userInfo);
    }
}

void UserManager::getUserInfoResponse(int commandId, const QVariantMap &data)
{
    qCDebug(dcUserManager()) << "User info reply" << commandId << data;
    QVariantMap userMap = data.value("userInfo").toMap();
    m_userInfo->setUsername(userMap.value("username").toString());
    m_userInfo->setScopes(UserInfo::listToScopes(userMap.value("scopes").toStringList()));
}

void UserManager::getTokensResponse(int /*commandId*/, const QVariantMap &data)
{

    foreach (const QVariant &tokenVariant, data.value("tokenInfoList").toList()) {
        //        qDebug() << "Token received" << tokenVariant.toMap();
        QVariantMap token = tokenVariant.toMap();
        QUuid id = token.value("id").toString();
        QString username = token.value("username").toString();
        QString deviceName = token.value("deviceName").toString();
        QDateTime creationTime = QDateTime::fromSecsSinceEpoch(token.value("creationTime").toInt());
        TokenInfo *tokenInfo = new TokenInfo(id, username, deviceName, creationTime);
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

Users::Users(QObject *parent): QAbstractListModel(parent)
{

}

int Users::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return m_users.count();
}

QVariant Users::data(const QModelIndex &index, int role) const
{
    switch (role) {
    case RoleUsername:
        return m_users.at(index.row())->username();
    case RoleScopes:
        return static_cast<int>(m_users.at(index.row())->scopes());
    }
    return QVariant();
}

QHash<int, QByteArray> Users::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles.insert(RoleUsername, "username");
    roles.insert(RoleScopes, "scopes");
    return roles;
}

void Users::insertUser(UserInfo *userInfo)
{
    userInfo->setParent(this);
    connect(userInfo, &UserInfo::scopesChanged, this, [=](){
        int idx = m_users.indexOf(userInfo);
        if (idx >= 0) {
            emit dataChanged(index(idx), index(idx), {RoleScopes});
        }
    });

    beginInsertRows(QModelIndex(), m_users.count(), m_users.count());
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

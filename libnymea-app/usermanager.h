#ifndef USERMANAGER_H
#define USERMANAGER_H

#include <QObject>

#include "jsonrpc/jsonrpcclient.h"
#include "engine.h"

#include "types/tokeninfos.h"
#include "types/userinfo.h"

class Users;

class UserManager: public QObject
{
    Q_OBJECT
    Q_PROPERTY(Engine* engine READ engine WRITE setEngine NOTIFY engineChanged)
    Q_PROPERTY(bool loading READ loading NOTIFY loadingChanged)

    Q_PROPERTY(UserInfo* userInfo READ userInfo CONSTANT)
    Q_PROPERTY(TokenInfos* tokenInfos READ tokenInfos CONSTANT)
    Q_PROPERTY(Users* users READ users CONSTANT)

public:
    enum UserError {
        UserErrorNoError,
        UserErrorBackendError,
        UserErrorInvalidUserId,
        UserErrorDuplicateUserId,
        UserErrorBadPassword,
        UserErrorTokenNotFound,
        UserErrorPermissionDenied
    };
    Q_ENUM(UserError)

    explicit UserManager(QObject *parent = nullptr);
    ~UserManager();

    Engine* engine() const;
    void setEngine(Engine* engine);

    bool loading() const;

    UserInfo* userInfo() const;
    TokenInfos* tokenInfos() const;
    Users *users() const;

    // NOTE: Q_FLAG from another QObject (UserInfo::PermissionScopes) doesn't seem to work in certain Qt versions. Using int instead
    Q_INVOKABLE int createUser(const QString &username, const QString &password, const QString &displayName, const QString &email, int permissionScopes = UserInfo::PermissionScopeAdmin);
    Q_INVOKABLE int changePassword(const QString &newPassword);
    Q_INVOKABLE int removeToken(const QUuid &id);
    Q_INVOKABLE int removeUser(const QString &username);
    // NOTE: Q_FLAG from another QObject (UserInfo::PermissionScopes) doesn't seem to work in certain Qt versions. Using int instead
    Q_INVOKABLE int setUserScopes(const QString &username, int permissionScopes);
    Q_INVOKABLE int setUserInfo(const QString &username, const QString &displayName, const QString &email);

signals:
    void engineChanged();
    void loadingChanged();

    void createUserReply(int id, UserError error);
    void removeTokenReply(int id, UserError error);
    void changePasswordReply(int id, UserError error);
    void removeUserReply(int id, UserError error);
    void setUserScopesReply(int id, UserError error);
    void setUserInfoReply(int id, UserError error);

private slots:
    void notificationReceived(const QVariantMap &data);

    void getUsersResponse(int commandId, const QVariantMap &data);
    void getUserInfoResponse(int commandId, const QVariantMap &data);
    void getTokensResponse(int commandId, const QVariantMap &data);
    void removeTokenResponse(int commandId, const QVariantMap &params);
    void changePasswordResponse(int commandId, const QVariantMap &params);
    void createUserResponse(int commandId, const QVariantMap &params);
    void removeUserResponse(int commandId, const QVariantMap &params);
    void setUserScopesResponse(int commandId, const QVariantMap &params);
    void setUserInfoResponse(int commandId, const QVariantMap &params);

private:
    Engine *m_engine = nullptr;
    bool m_loading = false;

    UserInfo *m_userInfo = nullptr;
    TokenInfos *m_tokenInfos = nullptr;

    Users *m_users = nullptr;

    QHash<int, QUuid> m_tokensToBeRemoved;
};

class Users: public QAbstractListModel {
    Q_OBJECT
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)

public:
    enum Roles {
        RoleUsername,
        RoleDisplayName,
        RoleEmail,
        RoleScopes
    };
    Q_ENUM(Roles)

    explicit Users(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

    void insertUser(UserInfo *userInfo);
    void removeUser(const QString &username);

    Q_INVOKABLE UserInfo* get(int index) const;
    Q_INVOKABLE UserInfo* getUserInfo(const QString &username) const;

signals:
    void countChanged();

private:
    QList<UserInfo*> m_users;
};

#endif // USERMANAGER_H

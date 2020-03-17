#ifndef USERMANAGER_H
#define USERMANAGER_H

#include <QObject>

#include "jsonrpc/jsonrpcclient.h"
#include "engine.h"

#include "types/tokeninfos.h"
#include "types/userinfo.h"

class UserManager: public JsonHandler
{
    Q_OBJECT
    Q_PROPERTY(Engine* engine READ engine WRITE setEngine NOTIFY engineChanged)
    Q_PROPERTY(bool loading READ loading NOTIFY loadingChanged)

    Q_PROPERTY(UserInfo* userInfo READ userInfo CONSTANT)
    Q_PROPERTY(TokenInfos* tokenInfos READ tokenInfos CONSTANT)

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

    Engine* engine() const;
    void setEngine(Engine* engine);

    bool loading() const;

    UserInfo* userInfo() const;
    TokenInfos* tokenInfos() const;

    QString nameSpace() const override;

    Q_INVOKABLE int changePassword(const QString &newPassword);
    Q_INVOKABLE int removeToken(const QUuid &id);

signals:
    void engineChanged();
    void loadingChanged();

    void deleteTokenResponse(int id, UserError error);
    void changePasswordResponse(int id, UserError error);

private slots:
    void notificationReceived(const QVariantMap &data);

    void getUserInfoReply(const QVariantMap &data);
    void getTokensReply(const QVariantMap &data);
    void deleteTokenReply(const QVariantMap &data);
    void changePasswordReply(const QVariantMap &data);

private:
    Engine *m_engine = nullptr;
    bool m_loading = false;

    UserInfo *m_userInfo = nullptr;
    TokenInfos *m_tokenInfos = nullptr;

    QHash<int, QUuid> m_tokensToBeRemoved;
};

#endif // USERMANAGER_H

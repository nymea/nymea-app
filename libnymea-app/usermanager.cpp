#include "usermanager.h"
#include "types/tokeninfo.h"

#include <QDebug>
#include <QMetaEnum>

UserManager::UserManager(QObject *parent):
    JsonHandler(parent)
{
    m_userInfo = new UserInfo(this);
    m_tokenInfos = new TokenInfos(this);
}

Engine *UserManager::engine() const
{
    return m_engine;
}

void UserManager::setEngine(Engine *engine)
{
    if (m_engine != engine) {
        m_engine = engine;
        m_engine->jsonRpcClient()->registerNotificationHandler(this, "notificationReceived");
        emit engineChanged();

        m_loading = true;
        emit loadingChanged();

        m_engine->jsonRpcClient()->sendCommand("Users.GetUserInfo", QVariantMap(), this, "getUserInfoReply");
        m_engine->jsonRpcClient()->sendCommand("Users.GetTokens", QVariantMap(), this, "getTokensReply");
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

QString UserManager::nameSpace() const
{
    return "Users";
}

int UserManager::changePassword(const QString &newPassword)
{
    QVariantMap params;
    params.insert("newPassword", newPassword);
    int callId = m_engine->jsonRpcClient()->sendCommand("Users.ChangePassword", params, this, "changePasswordReply");
    return callId;
}

int UserManager::removeToken(const QUuid &id)
{
    QVariantMap params;
    params.insert("tokenId", id);
    int callId = m_engine->jsonRpcClient()->sendCommand("Users.RemoveToken", params, this, "deleteTokenReply");
    m_tokensToBeRemoved.insert(callId, id);
    return callId;
}

void UserManager::notificationReceived(const QVariantMap &data)
{
    qDebug() << "Users notification" << data;
}

void UserManager::getUserInfoReply(const QVariantMap &data)
{
    qDebug() << "User info reply" << data;

    m_userInfo->setUsername(data.value("params").toMap().value("userInfo").toMap().value("username").toString());
}

void UserManager::getTokensReply(const QVariantMap &data)
{

    foreach (const QVariant &tokenVariant, data.value("params").toMap().value("tokenInfoList").toList()) {
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



void UserManager::deleteTokenReply(const QVariantMap &payload)
{
    qDebug() << "Delete token reply" << payload;
    int callId = payload.value("id").toInt();
    QUuid tokenId = m_tokensToBeRemoved.take(callId);
    QVariantMap params = payload.value("params").toMap();
    QString errorString = params.value("error").toString();
    QMetaEnum metaEnum = QMetaEnum::fromType<UserManager::UserError>();
    UserError error = static_cast<UserError>(metaEnum.keyToValue(errorString.toUtf8()));

    emit deleteTokenResponse(callId, error);

    if (error == UserErrorNoError) {
        m_tokenInfos->removeToken(tokenId);
    }
}

void UserManager::changePasswordReply(const QVariantMap &data)
{
    qDebug() << "Change password reply" << data;

    int callId = data.value("id").toInt();
    QVariantMap params = data.value("params").toMap();
    QString errorString = params.value("error").toString();
    QMetaEnum metaEnum = QMetaEnum::fromType<UserManager::UserError>();
    UserError error = static_cast<UserError>(metaEnum.keyToValue(errorString.toUtf8()));

    emit changePasswordResponse(callId, error);
}

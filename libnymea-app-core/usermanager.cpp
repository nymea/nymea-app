#include "usermanager.h"
#include "types/tokeninfo.h"

#include <QDebug>

UserManager::UserManager(QObject *parent):
    JsonHandler(parent)
{
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

        m_engine->jsonRpcClient()->sendCommand("Users.GetTokens", QVariantMap(), this, "getTokensReply");
    }
}

bool UserManager::loading() const
{
    return m_loading;
}

TokenInfos *UserManager::tokenInfos() const
{
    return m_tokenInfos;
}

QString UserManager::nameSpace() const
{
    return "Users";
}

void UserManager::notificationReceived(const QVariantMap &data)
{
    qDebug() << "Users notification" << data;
}

void UserManager::getTokensReply(const QVariantMap &params)
{

    foreach (const QVariant &tokenVariant, params.value("params").toMap().value("tokenInfoList").toList()) {
        qDebug() << "Token received" << tokenVariant.toMap();
        QVariantMap token = tokenVariant.toMap();
        QUuid id = token.value("id").toString();
        QString username = token.value("username").toString();
        QString deviceName = token.value("deviceName").toString();
        QDateTime creationTime = QDateTime::fromSecsSinceEpoch(token.value("creationTime").toInt());
        TokenInfo *tokenInfo = new TokenInfo(id, username, deviceName, creationTime);
        m_tokenInfos->addToken(tokenInfo);
    }
}

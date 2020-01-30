#include "usersmanager.h"

#include <QDebug>

UsersManager::UsersManager(JsonRpcClient *client, QObject *parent):
    JsonHandler(parent),
    m_jsonRpcClient(client)
{
    m_jsonRpcClient->registerNotificationHandler(this, "notificationReceived");
}

QString UsersManager::nameSpace() const
{
    return "Users";
}

void UsersManager::notificationReceived(const QVariantMap &data)
{
    qDebug() << "Users notification" << data;
}

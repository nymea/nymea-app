#include "logmanager.h"

#include "engine.h"

LogManager::LogManager(JsonRpcClient *jsonClient, QObject *parent) :
    JsonHandler(parent),
    m_client(jsonClient)
{
    m_client->registerNotificationHandler(this, "notificationReceived");
}

QString LogManager::nameSpace() const
{
    return "Logging";
}

void LogManager::notificationReceived(const QVariantMap &data)
{
    emit logEntryReceived(data.value("params").toMap().value("logEntry").toMap());
}

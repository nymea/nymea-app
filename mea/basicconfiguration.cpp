#include "basicconfiguration.h"

#include "jsonrpc/jsonrpcclient.h"

BasicConfiguration::BasicConfiguration(JsonRpcClient* client, QObject *parent) :
    QObject(parent),
    m_client(client)
{

}

bool BasicConfiguration::debugServerEnabled() const
{
    return m_debugServerEnabled;
}

void BasicConfiguration::setDebugServerEnabled(bool debugServerEnabled)
{
    QVariantMap params;
    params.insert("enabled", debugServerEnabled);
    m_client->sendCommand("Configuration.SetDebugServerEnabled", params, this, "setDebugServerEnabledResponse");
}

QString BasicConfiguration::serverName() const
{
    return m_serverName;
}

void BasicConfiguration::setServerName(const QString &serverName)
{
    QVariantMap params;
    params.insert("serverName", serverName);
    m_client->sendCommand("Configuration.SetServerName", params, this, "setServerNameResponse");
}

void BasicConfiguration::init()
{
    m_client->sendCommand("Configuration.GetConfigurations", this, "getConfigurationsResponse");
}

void BasicConfiguration::getConfigurationsResponse(const QVariantMap &params)
{
    qDebug() << "have config reply" << params;
    QVariantMap basicConfig = params.value("params").toMap().value("basicConfiguration").toMap();
    m_debugServerEnabled = basicConfig.value("debugServerEnabled").toBool();
    m_serverName = basicConfig.value("serverName").toString();
}

void BasicConfiguration::setDebugServerEnabledResponse(const QVariantMap &params)
{
    qDebug() << "Debug server set:" << params;
}

void BasicConfiguration::setServerNameResponse(const QVariantMap &params)
{
    qDebug() << "Server name set:" << params;
}

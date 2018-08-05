#include "basicconfiguration.h"

#include "jsonrpc/jsonrpcclient.h"

BasicConfiguration::BasicConfiguration(JsonRpcClient* client, QObject *parent) :
    JsonHandler(parent),
    m_client(client)
{
    client->registerNotificationHandler(this, "notificationReceived");
}

QString BasicConfiguration::nameSpace() const
{
    return "Configuration";
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

bool BasicConfiguration::cloudEnabled() const
{
    return m_cloudEnabled;
}

void BasicConfiguration::setCloudEnabled(bool cloudEnabled)
{
    QVariantMap params;
    params.insert("enabled", cloudEnabled);
    m_client->sendCommand("Configuration.SetCloudEnabled", params, this, "setCloudEnabledResponse");
}

void BasicConfiguration::init()
{
    m_client->sendCommand("Configuration.GetConfigurations", this, "getConfigurationsResponse");
}

void BasicConfiguration::getConfigurationsResponse(const QVariantMap &params)
{
//    qDebug() << "have config reply" << params;
    QVariantMap basicConfig = params.value("params").toMap().value("basicConfiguration").toMap();
    m_debugServerEnabled = basicConfig.value("debugServerEnabled").toBool();
    emit debugServerEnabledChanged();
    m_serverName = basicConfig.value("serverName").toString();
    emit serverNameChanged();
    QVariantMap cloudConfig = params.value("params").toMap().value("cloud").toMap();
    m_cloudEnabled = cloudConfig.value("enabled").toBool();
    emit cloudEnabledChanged();
}

void BasicConfiguration::getCloudConfigurationResponse(const QVariantMap &params)
{
    qDebug() << "Cloud config reply" << params;
}

void BasicConfiguration::setDebugServerEnabledResponse(const QVariantMap &params)
{
    qDebug() << "Debug server set:" << params;
}

void BasicConfiguration::setServerNameResponse(const QVariantMap &params)
{
    qDebug() << "Server name set:" << params;
}

void BasicConfiguration::setCloudEnabledResponse(const QVariantMap &params)
{
    qDebug() << "Set cloud enabled:" << params;
}

void BasicConfiguration::notificationReceived(const QVariantMap &notification)
{
    QString notif = notification.value("notification").toString();
    if (notif == "Configuration.BasicConfigurationChanged") {
        QVariantMap params = notification.value("params").toMap().value("basicConfiguration").toMap();
        qDebug() << "notif" << params;
        m_debugServerEnabled = params.value("debugServerEnabled").toBool();
        emit debugServerEnabled();
        m_serverName = params.value("serverName").toString();
        emit serverNameChanged();
        return;
    }
    if (notif == "Configuration.CloudConfigurationChanged") {
        QVariantMap params = notification.value("params").toMap().value("cloudConfiguration").toMap();
        qDebug() << "notif" << params;
        m_cloudEnabled = params.value("enabled").toBool();
        emit cloudEnabledChanged();
        return;
    }
    qDebug() << "Unhandled Configuration notification" << notif;
}

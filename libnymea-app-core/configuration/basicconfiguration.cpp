#include "basicconfiguration.h"
#include "serverconfiguration.h"

#include "jsonrpc/jsonrpcclient.h"

BasicConfiguration::BasicConfiguration(JsonRpcClient* client, QObject *parent) :
    JsonHandler(parent),
    m_client(client),
    m_tcpServerConfigurations(new ServerConfigurations(this)),
    m_websocketServerConfigurations(new ServerConfigurations(this))
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

QString BasicConfiguration::language() const
{
    return m_language;
}

void BasicConfiguration::setLanguage(const QString &language)
{
    QVariantMap params;
    params.insert("language", language);
    m_client->sendCommand("Configuration.SetLanguage", params);
}

QString BasicConfiguration::timezone() const
{
    return m_timezone;
}

void BasicConfiguration::setTimezone(const QString &timezone)
{
    QVariantMap params;
    params.insert("timeZone", timezone);
    m_client->sendCommand("Configuration.SetTimeZone", params, this, "setTimezoneResponse");
}

QStringList BasicConfiguration::timezones() const
{
    return m_timezones;
}

ServerConfigurations *BasicConfiguration::tcpServerConfigurations() const
{
    return m_tcpServerConfigurations;
}

ServerConfigurations *BasicConfiguration::websocketServerConfigurations() const
{
    return m_websocketServerConfigurations;
}

void BasicConfiguration::setTcpServerConfiguration(ServerConfiguration *configuration) const
{
    QVariantMap params;
    params.insert("id", configuration->id());
    params.insert("address", configuration->address());
    params.insert("port", configuration->address());
    params.insert("authentiactionEnabled", configuration->authenticationEnabled());
    params.insert("sslEnabled", configuration->sslEnabled());
    m_client->sendCommand("Configuration.SetTcpServerConfiguration", params);
}

void BasicConfiguration::deleteTcpServerConfiguration(const QString &id)
{
    QVariantMap params;
    params.insert("id", id);
    m_client->sendCommand("Configuration.DeleteTcpServerConfiguration", params, this, "deleteTcpConfigReply");
}

void BasicConfiguration::deleteWebsocketServerConfiguration(const QString &id)
{
    QVariantMap params;
    params.insert("id", id);
    m_client->sendCommand("Configuration.DeleteWebSocketServerConfiguration", params, this, "deleteWebSocketConfigReply");
}

QStringList BasicConfiguration::availableLanguages() const
{
    return m_availableLanguages;
}

void BasicConfiguration::init()
{
    m_client->sendCommand("Configuration.GetConfigurations", this, "getConfigurationsResponse");
    m_client->sendCommand("Configuration.GetAvailableLanguages", this, "getAvailableLanguagesResponse");
    m_client->sendCommand("Configuration.GetTimeZones", this, "getTimezonesResponse");
}

void BasicConfiguration::getConfigurationsResponse(const QVariantMap &params)
{
    qDebug() << "have config reply" << params;
    QVariantMap basicConfig = params.value("params").toMap().value("basicConfiguration").toMap();
    m_debugServerEnabled = basicConfig.value("debugServerEnabled").toBool();
    emit debugServerEnabledChanged();
    m_serverName = basicConfig.value("serverName").toString();
    emit serverNameChanged();
    m_language = basicConfig.value("language").toString();
    emit languageChanged();
    m_timezone = basicConfig.value("timeZone").toString();
    emit timezoneChanged();
    QVariantMap cloudConfig = params.value("params").toMap().value("cloud").toMap();
    m_cloudEnabled = cloudConfig.value("enabled").toBool();
    emit cloudEnabledChanged();

    tcpServerConfigurations()->clear();
    foreach (const QVariant &tcpServerVariant, params.value("params").toMap().value("tcpServerConfigurations").toList()) {
        qDebug() << "tcp server config:" << tcpServerVariant;
        QVariantMap tcpConfigMap = tcpServerVariant.toMap();
        ServerConfiguration *config = new ServerConfiguration(tcpConfigMap.value("id").toString(), QHostAddress(tcpConfigMap.value("address").toString()), tcpConfigMap.value("port").toInt(), tcpConfigMap.value("authenticationEnabled").toBool(), tcpConfigMap.value("sslEnabled").toBool());
        m_tcpServerConfigurations->addConfiguration(config);
    }
    websocketServerConfigurations()->clear();
    foreach (const QVariant &websocketServerVariant, params.value("params").toMap().value("webSocketServerConfigurations").toList()) {
        QVariantMap websocketConfigMap = websocketServerVariant.toMap();
        ServerConfiguration *config = new ServerConfiguration(websocketConfigMap.value("id").toString(), QHostAddress(websocketConfigMap.value("address").toString()), websocketConfigMap.value("port").toInt(), websocketConfigMap.value("authenticationEnabled").toBool(), websocketConfigMap.value("sslEnabled").toBool());
        m_websocketServerConfigurations->addConfiguration(config);
    }
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

void BasicConfiguration::getAvailableLanguagesResponse(const QVariantMap &params)
{
//    qDebug() << "Get available languages response" << params;
    m_availableLanguages = params.value("params").toMap().value("languages").toStringList();
    emit availableLanguagesChanged();
}

void BasicConfiguration::getTimezonesResponse(const QVariantMap &params)
{
//    qDebug() << "Get timezones response" << params;
    m_timezones = params.value("params").toMap().value("timeZones").toStringList();
    emit timezonesChanged();
}

void BasicConfiguration::setTimezoneResponse(const QVariantMap &params)
{
    qDebug() << "Set timezones response" << params;
}

void BasicConfiguration::deleteTcpConfigReply(const QVariantMap &params)
{
    if (params.value("params").toMap().value("configurationError").toString() == "ConfigurationErrorNoError") {
    }
}

void BasicConfiguration::deleteWebSocketConfigReply(const QVariantMap &params)
{

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

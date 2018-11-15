#include "nymeaconfiguration.h"

#include "serverconfiguration.h"
#include "serverconfigurations.h"
#include "mqttbrokerconfiguration.h"

#include "jsonrpc/jsonrpcclient.h"

#include <QUuid>

NymeaConfiguration::NymeaConfiguration(JsonRpcClient *client, QObject *parent):
    JsonHandler(parent),
    m_client(client),
    m_tcpServerConfigurations(new ServerConfigurations(this)),
    m_webSocketServerConfigurations(new ServerConfigurations(this)),
    m_mqttServerConfigurations(new ServerConfigurations(this)),
    m_mqttBrokerConfiguration(new MqttBrokerConfiguration(this))
{
    client->registerNotificationHandler(this, "notificationReceived");
}

QString NymeaConfiguration::nameSpace() const
{
    return "Configuration";
}

void NymeaConfiguration::init()
{
    m_tcpServerConfigurations->clear();
    m_webSocketServerConfigurations->clear();
    m_mqttServerConfigurations->clear();
    m_client->sendCommand("Configuration.GetConfigurations", this, "getConfigurationsResponse");
    m_client->sendCommand("Configuration.GetAvailableLanguages", this, "getAvailableLanguagesResponse");
    m_client->sendCommand("Configuration.GetTimeZones", this, "getTimezonesResponse");
}

QString NymeaConfiguration::serverName() const
{
    return m_serverName;
}

void NymeaConfiguration::setServerName(const QString &serverName)
{
    QVariantMap params;
    params.insert("serverName", serverName);
    m_client->sendCommand("Configuration.SetServerName", params, this, "setServerNameResponse");
}

QString NymeaConfiguration::language() const
{
    return m_language;
}

void NymeaConfiguration::setLanguage(const QString &language)
{
    QVariantMap params;
    params.insert("language", language);
    m_client->sendCommand("Configuration.SetLanguage", params);
}

QStringList NymeaConfiguration::availableLanguages() const
{
    return m_availableLanguages;
}

QString NymeaConfiguration::timezone() const
{
    return m_timezone;
}

void NymeaConfiguration::setTimezone(const QString &timezone)
{
    QVariantMap params;
    params.insert("timeZone", timezone);
    m_client->sendCommand("Configuration.SetTimeZone", params, this, "setTimezoneResponse");
}

QStringList NymeaConfiguration::timezones() const
{
    return m_timezones;
}

bool NymeaConfiguration::debugServerEnabled() const
{
    return m_debugServerEnabled;
}

void NymeaConfiguration::setDebugServerEnabled(bool debugServerEnabled)
{
    QVariantMap params;
    params.insert("enabled", debugServerEnabled);
    m_client->sendCommand("Configuration.SetDebugServerEnabled", params, this, "setDebugServerEnabledResponse");
}

bool NymeaConfiguration::cloudEnabled() const
{
    return m_cloudEnabled;
}

void NymeaConfiguration::setCloudEnabled(bool cloudEnabled)
{
    QVariantMap params;
    params.insert("enabled", cloudEnabled);
    m_client->sendCommand("Configuration.SetCloudEnabled", params, this, "setCloudEnabledResponse");
}

ServerConfigurations *NymeaConfiguration::tcpServerConfigurations() const
{
    return m_tcpServerConfigurations;
}

ServerConfigurations *NymeaConfiguration::webSocketServerConfigurations() const
{
    return m_webSocketServerConfigurations;
}

ServerConfigurations *NymeaConfiguration::mqttServerConfigurations() const
{
    return m_mqttServerConfigurations;
}

MqttBrokerConfiguration *NymeaConfiguration::mqttBrokerConfiguration() const
{
    return m_mqttBrokerConfiguration;
}

ServerConfiguration *NymeaConfiguration::createServerConfiguration(const QString &address, int port, bool authEnabled, bool sslEnabled)
{
    return new ServerConfiguration(QUuid::createUuid().toString(), QHostAddress(address), port, authEnabled, sslEnabled);
}

void NymeaConfiguration::setTcpServerConfiguration(ServerConfiguration *configuration)
{
    QVariantMap params;
    QVariantMap configurationMap;
    configurationMap.insert("id", configuration->id());
    configurationMap.insert("address", configuration->address());
    configurationMap.insert("port", configuration->port());
    configurationMap.insert("authenticationEnabled", configuration->authenticationEnabled());
    configurationMap.insert("sslEnabled", configuration->sslEnabled());
    params.insert("configuration", configurationMap);
    m_client->sendCommand("Configuration.SetTcpServerConfiguration", params, this, "setTcpConfigReply");
}

void NymeaConfiguration::setWebSocketServerConfiguration(ServerConfiguration *configuration)
{
    QVariantMap params;
    QVariantMap configurationMap;
    configurationMap.insert("id", configuration->id());
    configurationMap.insert("address", configuration->address());
    configurationMap.insert("port", configuration->port());
    configurationMap.insert("authenticationEnabled", configuration->authenticationEnabled());
    configurationMap.insert("sslEnabled", configuration->sslEnabled());
    params.insert("configuration", configurationMap);
    m_client->sendCommand("Configuration.SetWebSocketServerConfiguration", params, this, "setWebSocketConfigReply");
}

void NymeaConfiguration::setMqttServerConfiguration(ServerConfiguration *configuration)
{
    QVariantMap params;
    QVariantMap configurationMap;
    configurationMap.insert("id", configuration->id());
    configurationMap.insert("address", configuration->address());
    configurationMap.insert("port", configuration->port());
    configurationMap.insert("authenticationEnabled", configuration->authenticationEnabled());
    configurationMap.insert("sslEnabled", configuration->sslEnabled());
    params.insert("configuration", configurationMap);
    m_client->sendCommand("Configuration.SetMqttServerConfiguration", params, this, "setMqttConfigReply");
}

void NymeaConfiguration::deleteTcpServerConfiguration(const QString &id)
{
    QVariantMap params;
    params.insert("id", id);
    m_client->sendCommand("Configuration.DeleteTcpServerConfiguration", params, this, "deleteTcpConfigReply");
}

void NymeaConfiguration::deleteWebSocketServerConfiguration(const QString &id)
{
    QVariantMap params;
    params.insert("id", id);
    m_client->sendCommand("Configuration.DeleteWebSocketServerConfiguration", params, this, "deleteWebSocketConfigReply");
}

void NymeaConfiguration::deleteMqttServerConfiguration(const QString &id)
{
    QVariantMap params;
    params.insert("id", id);
    m_client->sendCommand("Configuration.DeleteMqttServerConfiguration", params, this, "deleteMqttConfigReply");
}

void NymeaConfiguration::getConfigurationsResponse(const QVariantMap &params)
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
    webSocketServerConfigurations()->clear();
    foreach (const QVariant &websocketServerVariant, params.value("params").toMap().value("webSocketServerConfigurations").toList()) {
        QVariantMap websocketConfigMap = websocketServerVariant.toMap();
        ServerConfiguration *config = new ServerConfiguration(websocketConfigMap.value("id").toString(), QHostAddress(websocketConfigMap.value("address").toString()), websocketConfigMap.value("port").toInt(), websocketConfigMap.value("authenticationEnabled").toBool(), websocketConfigMap.value("sslEnabled").toBool());
        m_webSocketServerConfigurations->addConfiguration(config);
    }

    if (m_client->ensureServerVersion("1.11")) {
        foreach (const QVariant &mqttServerVariant, params.value("params").toMap().value("mqttServerConfigurations").toList()) {
            QVariantMap mqttConfigMap = mqttServerVariant.toMap();
            ServerConfiguration *config = new ServerConfiguration(mqttConfigMap.value("id").toString(), QHostAddress(mqttConfigMap.value("address").toString()), mqttConfigMap.value("port").toInt(), mqttConfigMap.value("authenticationEnabled").toBool(), mqttConfigMap.value("sslEnabled").toBool());
            m_mqttServerConfigurations->addConfiguration(config);
        }
    }
}

void NymeaConfiguration::getAvailableLanguagesResponse(const QVariantMap &params)
{
    qDebug() << "available languages" << params;
}

void NymeaConfiguration::getTimezonesResponse(const QVariantMap &params)
{
//    qDebug() << "Get timezones response" << params;
    m_timezones = params.value("params").toMap().value("timeZones").toStringList();
    emit timezonesChanged();
}

void NymeaConfiguration::setTimezoneResponse(const QVariantMap &params)
{
    qDebug() << "Set timezones response" << params;
}

void NymeaConfiguration::setServerNameResponse(const QVariantMap &params)
{
    qDebug() << "Server name set:" << params;
}

void NymeaConfiguration::getCloudConfigurationResponse(const QVariantMap &params)
{
    qDebug() << "Cloud config reply" << params;
}

void NymeaConfiguration::setCloudEnabledResponse(const QVariantMap &params)
{
    qDebug() << "Set cloud enabled:" << params;
}

void NymeaConfiguration::setDebugServerEnabledResponse(const QVariantMap &params)
{
    qDebug() << "Debug server set:" << params;
}

void NymeaConfiguration::setTcpConfigReply(const QVariantMap &params)
{

}

void NymeaConfiguration::deleteTcpConfigReply(const QVariantMap &params)
{
    if (params.value("params").toMap().value("configurationError").toString() == "ConfigurationErrorNoError") {
    }
}

void NymeaConfiguration::setWebSocketConfigReply(const QVariantMap &params)
{
    qDebug() << "set weboscket config reply" << params;
}

void NymeaConfiguration::deleteWebSocketConfigReply(const QVariantMap &params)
{

}

void NymeaConfiguration::setMqttConfigReply(const QVariantMap &params)
{
    qDebug() << "Set mqtt config reply" << params;
}

void NymeaConfiguration::deleteMqttConfigReply(const QVariantMap &params)
{
    qDebug() << "Delete Mqtt Broker config reply:" << params;
}

void NymeaConfiguration::notificationReceived(const QVariantMap &notification)
{
    QString notif = notification.value("notification").toString();
    if (notif == "Configuration.BasicConfigurationChanged") {
        QVariantMap params = notification.value("params").toMap().value("basicConfiguration").toMap();
        qDebug() << "notif" << params;
        m_debugServerEnabled = params.value("debugServerEnabled").toBool();
        emit debugServerEnabledChanged();
        m_serverName = params.value("serverName").toString();
        emit serverNameChanged();
        m_language = params.value("language").toString();
        emit languageChanged();
        m_timezone = params.value("timeZone").toString();
        emit timezoneChanged();
        return;
    }
    if (notif == "Configuration.CloudConfigurationChanged") {
        QVariantMap params = notification.value("params").toMap().value("cloudConfiguration").toMap();
        qDebug() << "notif" << params;
        m_cloudEnabled = params.value("enabled").toBool();
        emit cloudEnabledChanged();
        return;
    }
    if (notif.endsWith("ServerConfigurationChanged")) {
        ServerConfigurations *configModel = nullptr;
        QVariantMap params;
        if (notif == "Configuration.TcpServerConfigurationChanged") {
            configModel = m_tcpServerConfigurations;
            params = notification.value("params").toMap().value("tcpServerConfiguration").toMap();
        }
        if (notif == "Configuration.WebSocketServerConfigurationChanged") {
            configModel = m_webSocketServerConfigurations;
            params = notification.value("params").toMap().value("webSocketServerConfiguration").toMap();
        }
        if (notif == "Configuration.MqttServerConfigurationChanged") {
            configModel = m_mqttServerConfigurations;
            params = notification.value("params").toMap().value("mqttServerConfiguration").toMap();
        }
        if (!configModel) {
            return;
        }

        ServerConfiguration *serverConfig = nullptr;
        for (int i = 0; i < configModel->rowCount(); i++) {
            ServerConfiguration* config = configModel->get(i);
            if (config->id() == params.value("id").toString()) {
                serverConfig = config;
            }
        }

        if (!serverConfig) {
            serverConfig = new ServerConfiguration(params.value("id").toString());
            configModel->addConfiguration(serverConfig);
        }
        serverConfig->setAddress(params.value("address").toString());
        serverConfig->setPort(params.value("port").toInt());
        serverConfig->setAuthenticationEnabled(params.value("authenticationEnabled").toBool());
        serverConfig->setSslEnabled(params.value("sslEnabled").toBool());
        return;
    }
    if (notif == "Configuration.TcpServerConfigurationRemoved") {
        m_tcpServerConfigurations->removeConfiguration(notification.value("params").toMap().value("id").toString());
        return;
    }
    if (notif == "Configuration.WebSocketServerConfigurationRemoved") {
        m_webSocketServerConfigurations->removeConfiguration(notification.value("params").toMap().value("id").toString());
        return;
    }
    if (notif == "Configuration.MqttServerConfigurationRemoved") {
        m_mqttServerConfigurations->removeConfiguration(notification.value("params").toMap().value("id").toString());
        return;
    }

    qDebug() << "Unhandled Configuration notification" << notif << notification;
}

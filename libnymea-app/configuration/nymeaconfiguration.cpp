/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
* Copyright 2013 - 2020, nymea GmbH
* Contact: contact@nymea.io
*
* This file is part of nymea.
* This project including source code and documentation is protected by
* copyright law, and remains the property of nymea GmbH. All rights, including
* reproduction, publication, editing and translation, are reserved. The use of
* this project is subject to the terms of a license agreement to be concluded
* with nymea GmbH in accordance with the terms of use of nymea GmbH, available
* under https://nymea.io/license
*
* GNU General Public License Usage
* Alternatively, this project may be redistributed and/or modified under the
* terms of the GNU General Public License as published by the Free Software
* Foundation, GNU version 3. This project is distributed in the hope that it
* will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty
* of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
* Public License for more details.
*
* You should have received a copy of the GNU General Public License along with
* this project. If not, see <https://www.gnu.org/licenses/>.
*
* For any further details and any questions please contact us under
* contact@nymea.io or see our FAQ/Licensing Information on
* https://nymea.io/license/faq
*
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#include "nymeaconfiguration.h"

#include "serverconfiguration.h"
#include "serverconfigurations.h"
#include "mqttpolicy.h"
#include "mqttpolicies.h"

#include "jsonrpc/jsonrpcclient.h"

#include <QUuid>
#include <QJsonDocument>

#include "logging.h"
NYMEA_LOGGING_CATEGORY(dcNymeaConfiguration, "NymeaConfiguration")

NymeaConfiguration::NymeaConfiguration(JsonRpcClient *client, QObject *parent):
    QObject(parent),
    m_client(client),
    m_tcpServerConfigurations(new ServerConfigurations(this)),
    m_webSocketServerConfigurations(new ServerConfigurations(this)),
    m_webServerConfigurations(new WebServerConfigurations(this)),
    m_tunnelProxyServerConfigurations(new TunnelProxyServerConfigurations(this)),
    m_mqttServerConfigurations(new ServerConfigurations(this)),
    m_mqttPolicies(new MqttPolicies(this))
{
    client->registerNotificationHandler(this, "Configuration", "notificationReceived");
}

bool NymeaConfiguration::fetchingData() const
{
    return m_fetchingData;
}

void NymeaConfiguration::init()
{
    m_fetchingData = true;
    emit fetchingDataChanged();

    m_tcpServerConfigurations->clear();
    m_webSocketServerConfigurations->clear();
    m_mqttServerConfigurations->clear();
    m_tunnelProxyServerConfigurations->clear();
    m_client->sendCommand("Configuration.GetConfigurations", this, "getConfigurationsResponse");
    m_client->sendCommand("Configuration.GetMqttServerConfigurations", this, "getMqttServerConfigsReply");
    m_client->sendCommand("Configuration.GetMqttPolicies", this, "getMqttPoliciesReply");
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

void NymeaConfiguration::setTimezone(const QString &timezone)
{
    QVariantMap params;
    params.insert("timeZone", timezone);
    m_client->sendCommand("System.SetTimeZone", params, this, "setTimezoneResponse");
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

WebServerConfigurations *NymeaConfiguration::webServerConfigurations() const
{
    return m_webServerConfigurations;
}

TunnelProxyServerConfigurations *NymeaConfiguration::tunnelProxyServerConfigurations() const
{
    return m_tunnelProxyServerConfigurations;
}

ServerConfigurations *NymeaConfiguration::mqttServerConfigurations() const
{
    return m_mqttServerConfigurations;
}

MqttPolicies *NymeaConfiguration::mqttPolicies() const
{
    return m_mqttPolicies;
}

ServerConfiguration *NymeaConfiguration::createServerConfiguration(const QString &address, int port, bool authEnabled, bool sslEnabled)
{
    return new ServerConfiguration(QUuid::createUuid().toString(), address, port, authEnabled, sslEnabled);
}

WebServerConfiguration *NymeaConfiguration::createWebServerConfiguration(const QString &address, int port, bool authEnabled, bool sslEnabled, const QString &publicFolder)
{
    auto ret = new WebServerConfiguration(QUuid::createUuid().toString(), address, port, authEnabled, sslEnabled);
    ret->setPublicFolder(publicFolder);
    return ret;
}

TunnelProxyServerConfiguration *NymeaConfiguration::createTunnelProxyServerConfiguration(const QString &address, int port, bool authEnabled, bool sslEnabled, bool ignoreSslErrors)
{
    return new TunnelProxyServerConfiguration(QUuid::createUuid().toString(), address, port, authEnabled, sslEnabled, ignoreSslErrors);
}

MqttPolicy *NymeaConfiguration::createMqttPolicy() const
{
    return new MqttPolicy(QString(), QString(), QString(), {"#"}, {"#"});
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

void NymeaConfiguration::setWebServerConfiguration(WebServerConfiguration *configuration)
{
    QVariantMap params;
    QVariantMap configurationMap;
    configurationMap.insert("id", configuration->id());
    configurationMap.insert("address", configuration->address());
    configurationMap.insert("port", configuration->port());
    configurationMap.insert("authenticationEnabled", configuration->authenticationEnabled());
    configurationMap.insert("sslEnabled", configuration->sslEnabled());
    configurationMap.insert("publicFolder", configuration->publicFolder());
    params.insert("configuration", configurationMap);
    m_client->sendCommand("Configuration.SetWebServerConfiguration", params, this, "setWebConfigReply");
}

void NymeaConfiguration::setTunnelProxyServerConfiguration(TunnelProxyServerConfiguration *configuration)
{
    QVariantMap params;
    QVariantMap configurationMap;
    configurationMap.insert("id", configuration->id());
    configurationMap.insert("address", configuration->address());
    configurationMap.insert("port", configuration->port());
    configurationMap.insert("authenticationEnabled", configuration->authenticationEnabled());
    configurationMap.insert("sslEnabled", configuration->sslEnabled());
    configurationMap.insert("ignoreSslErrors", configuration->ignoreSslErrors());
    params.insert("configuration", configurationMap);
    m_client->sendCommand("Configuration.SetTunnelProxyServerConfiguration", params, this, "setTunnelProxyServerConfigReply");
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

void NymeaConfiguration::deleteWebServerConfiguration(const QString &id)
{
    QVariantMap params;
    params.insert("id", id);
    m_client->sendCommand("Configuration.DeleteWebServerConfiguration", params, this, "deleteWebConfigReply");
}

void NymeaConfiguration::deleteTunnelProxyServerConfiguration(const QString &id)
{
    QVariantMap params;
    params.insert("id", id);
    m_client->sendCommand("Configuration.DeleteTunnelProxyServerConfiguration", params, this, "deleteTunnelProxyServerConfigReply");
}

void NymeaConfiguration::deleteMqttServerConfiguration(const QString &id)
{
    QVariantMap params;
    params.insert("id", id);
    m_client->sendCommand("Configuration.DeleteMqttServerConfiguration", params, this, "deleteMqttConfigReply");
}

void NymeaConfiguration::updateMqttPolicy(MqttPolicy *policy)
{
    QVariantMap params;
    QVariantMap policyMap;
    policyMap.insert("clientId", policy->clientId());
    policyMap.insert("username", policy->username());
    policyMap.insert("password", policy->password());
    policyMap.insert("allowedPublishTopicFilters", policy->allowedPublishTopicFilters());
    policyMap.insert("allowedSubscribeTopicFilters", policy->allowedSubscribeTopicFilters());
    params.insert("policy", policyMap);
    m_client->sendCommand("Configuration.SetMqttPolicy", params, this, "setMqttPolicyReply");
}

void NymeaConfiguration::deleteMqttPolicy(const QString &clientId)
{
    QVariantMap params;
    params.insert("clientId", clientId);
    m_client->sendCommand("Configuration.DeleteMqttPolicy", params, this, "deleteMqttPolicyReply");
}

void NymeaConfiguration::getConfigurationsResponse(int commandId, const QVariantMap &params)
{
    Q_UNUSED(commandId)
    qCDebug(dcNymeaConfiguration) << "GetConfigurations response" << qUtf8Printable(QJsonDocument::fromVariant(params).toJson());
    QVariantMap basicConfig = params.value("basicConfiguration").toMap();
    m_debugServerEnabled = basicConfig.value("debugServerEnabled").toBool();
    emit debugServerEnabledChanged();
    m_serverName = basicConfig.value("serverName").toString();
    emit serverNameChanged();
    QVariantMap cloudConfig = params.value("cloud").toMap();
    m_cloudEnabled = cloudConfig.value("enabled").toBool();
    emit cloudEnabledChanged();

    tcpServerConfigurations()->clear();
    foreach (const QVariant &tcpServerVariant, params.value("tcpServerConfigurations").toList()) {
        QVariantMap tcpConfigMap = tcpServerVariant.toMap();
        ServerConfiguration *config = new ServerConfiguration(tcpConfigMap.value("id").toString(), tcpConfigMap.value("address").toString(), tcpConfigMap.value("port").toInt(), tcpConfigMap.value("authenticationEnabled").toBool(), tcpConfigMap.value("sslEnabled").toBool());
        qCInfo(dcNymeaConfiguration) << "TCP server config:" << config->id() << config->address() << config->port() << config->authenticationEnabled() << config->sslEnabled();
        m_tcpServerConfigurations->addConfiguration(config);
    }
    webSocketServerConfigurations()->clear();
    foreach (const QVariant &websocketServerVariant, params.value("webSocketServerConfigurations").toList()) {
        QVariantMap websocketConfigMap = websocketServerVariant.toMap();
        ServerConfiguration *config = new ServerConfiguration(websocketConfigMap.value("id").toString(), websocketConfigMap.value("address").toString(), websocketConfigMap.value("port").toInt(), websocketConfigMap.value("authenticationEnabled").toBool(), websocketConfigMap.value("sslEnabled").toBool());
        qCInfo(dcNymeaConfiguration) << "WebSocket server config:" << config->id() << config->address() << config->port() << config->authenticationEnabled() << config->sslEnabled();
        m_webSocketServerConfigurations->addConfiguration(config);
    }

    webServerConfigurations()->clear();
    foreach (const QVariant &webServerVariant, params.value("webServerConfigurations").toList()) {
        QVariantMap webServerConfigMap = webServerVariant.toMap();
        WebServerConfiguration* config = new WebServerConfiguration(webServerConfigMap.value("id").toString(), webServerConfigMap.value("address").toString(), webServerConfigMap.value("port").toInt(), webServerConfigMap.value("authenticationEnabled").toBool(), webServerConfigMap.value("sslEnabled").toBool());
        config->setPublicFolder(webServerConfigMap.value("publicFolder").toString());
        qCInfo(dcNymeaConfiguration) << "WebServer server config:" << config->id() << config->address() << config->port() << config->authenticationEnabled() << config->sslEnabled() << config->publicFolder();
        m_webServerConfigurations->addConfiguration(config);
    }

    tunnelProxyServerConfigurations()->clear();
    foreach (const QVariant &tunnelProxyServerVariant, params.value("tunnelProxyServerConfigurations").toList()) {
        QVariantMap tunnelProxyServerConfigMap = tunnelProxyServerVariant.toMap();
        TunnelProxyServerConfiguration *config = new TunnelProxyServerConfiguration(tunnelProxyServerConfigMap.value("id").toString(), tunnelProxyServerConfigMap.value("address").toString(), tunnelProxyServerConfigMap.value("port").toInt(), tunnelProxyServerConfigMap.value("authenticationEnabled").toBool(), tunnelProxyServerConfigMap.value("sslEnabled").toBool(), tunnelProxyServerConfigMap.value("ignoreSslErrors").toBool());
        qCInfo(dcNymeaConfiguration) << "Tunnel server config:" << config->id() << config->address() << config->port() << config->authenticationEnabled() << config->sslEnabled() << config->ignoreSslErrors();
        m_tunnelProxyServerConfigurations->addConfiguration(config);
    }

    m_fetchingData = false;
    emit fetchingDataChanged();
}

void NymeaConfiguration::setServerNameResponse(int commandId, const QVariantMap &params)
{
    qCDebug(dcNymeaConfiguration) << "Server name set:" << commandId << params;
}

void NymeaConfiguration::setTimezoneResponse(int commandId, const QVariantMap &params)
{
    qCDebug(dcNymeaConfiguration) << "Set timezone response" << commandId << params;
}

void NymeaConfiguration::getCloudConfigurationResponse(const QVariantMap &params)
{
    qCDebug(dcNymeaConfiguration) << "Cloud config reply" << params;
}

void NymeaConfiguration::setCloudEnabledResponse(int commandId, const QVariantMap &params)
{
    qCDebug(dcNymeaConfiguration) << "Set cloud enabled:" << commandId << params;
}

void NymeaConfiguration::setDebugServerEnabledResponse(int commandId, const QVariantMap &params)
{
    qCDebug(dcNymeaConfiguration) << "Debug server set:" << commandId << params;
}

void NymeaConfiguration::setTcpConfigReply(int commandId, const QVariantMap &params)
{
    qCDebug(dcNymeaConfiguration) << "Set TCP server config reply" << commandId << params;
}

void NymeaConfiguration::deleteTcpConfigReply(int commandId, const QVariantMap &params)
{
    qCDebug(dcNymeaConfiguration) << "Deöete  TCP server config reply" << commandId << params;
}

void NymeaConfiguration::setWebSocketConfigReply(int commandId, const QVariantMap &params)
{
    qCDebug(dcNymeaConfiguration) << "set websocket config reply" << commandId << params;
}

void NymeaConfiguration::setWebConfigReply(int commandId, const QVariantMap &params)
{
    qCDebug(dcNymeaConfiguration) << "set web server config reply" << commandId << params;
}

void NymeaConfiguration::deleteWebConfigReply(int commandId, const QVariantMap &params)
{
    qCDebug(dcNymeaConfiguration) << "Delete web server config reply" << commandId << params;
}

void NymeaConfiguration::deleteWebSocketConfigReply(int commandId, const QVariantMap &params)
{
    qCDebug(dcNymeaConfiguration) << "Delete web socket server config reply" << commandId << params;
}

void NymeaConfiguration::setTunnelProxyServerConfigReply(int commandId, const QVariantMap &params)
{
    qCDebug(dcNymeaConfiguration) << "Set tunnel proxy server config reply" << commandId << params;
}

void NymeaConfiguration::deleteTunnelProxyServerConfigReply(int commandId, const QVariantMap &params)
{
    qCDebug(dcNymeaConfiguration) << "Delete tunnel proxy server config reply" << commandId << params;
}

void NymeaConfiguration::getMqttServerConfigsReply(int commandId, const QVariantMap &params)
{
    Q_UNUSED(commandId)
    m_mqttServerConfigurations->clear();
    foreach (const QVariant &mqttServerVariant, params.value("mqttServerConfigurations").toList()) {
        QVariantMap mqttConfigMap = mqttServerVariant.toMap();
        ServerConfiguration *config = new ServerConfiguration(mqttConfigMap.value("id").toString(), mqttConfigMap.value("address").toString(), mqttConfigMap.value("port").toInt(), mqttConfigMap.value("authenticationEnabled").toBool(), mqttConfigMap.value("sslEnabled").toBool());
        m_mqttServerConfigurations->addConfiguration(config);
    }
}

void NymeaConfiguration::setMqttConfigReply(int commandId, const QVariantMap &params)
{
    qCDebug(dcNymeaConfiguration) << "Set mqtt config reply" << commandId << params;
}

void NymeaConfiguration::deleteMqttConfigReply(int commandId, const QVariantMap &params)
{
    qCDebug(dcNymeaConfiguration) << "Delete Mqtt Broker config reply:" << commandId << params;
}

void NymeaConfiguration::getMqttPoliciesReply(int commandId, const QVariantMap &params)
{
    Q_UNUSED(commandId)
//    qCDebug(dcNymeaConfiguration) << "Mqtt polices:" << params;
    m_mqttPolicies->clear();
    foreach (const QVariant &policyVariant, params.value("mqttPolicies").toList()) {
        QVariantMap policyMap = policyVariant.toMap();
        MqttPolicy *policy = new MqttPolicy(
                    policyMap.value("clientId").toString(),
                    policyMap.value("username").toString(),
                    policyMap.value("password").toString(),
                    policyMap.value("allowedPublishTopicFilters").toStringList(),
                    policyMap.value("allowedSubscribeTopicFilters").toStringList());
        m_mqttPolicies->addPolicy(policy);
    }
}

void NymeaConfiguration::setMqttPolicyReply(int commandId, const QVariantMap &params)
{
    qCDebug(dcNymeaConfiguration) << "Set MQTT policy reply" << commandId << params;
}

void NymeaConfiguration::deleteMqttPolicyReply(int commandId, const QVariantMap &params)
{
    qCDebug(dcNymeaConfiguration) << "Delete MQTT policy reply" << commandId << params;
}

void NymeaConfiguration::notificationReceived(const QVariantMap &notification)
{
    qCDebug(dcNymeaConfiguration()) << "Config notification received" << qUtf8Printable(QJsonDocument::fromVariant(notification).toJson());
    QString notif = notification.value("notification").toString();
    QVariantMap params = notification.value("params").toMap();

    if (notif == "Configuration.BasicConfigurationChanged") {
        QVariantMap configMap = params.value("basicConfiguration").toMap();
        m_debugServerEnabled = configMap.value("debugServerEnabled").toBool();
        emit debugServerEnabledChanged();
        m_serverName = configMap.value("serverName").toString();
        emit serverNameChanged();
        qCDebug(dcNymeaConfiguration()) << "Basic configuration changed. Server name:" << m_serverName << "Debug server enabled:" << m_debugServerEnabled;
    } else if (notif == "Configuration.CloudConfigurationChanged") {
        QVariantMap configMap = params.value("cloudConfiguration").toMap();
        qCDebug(dcNymeaConfiguration()) << "Cloud coniguration changed" << configMap;
        m_cloudEnabled = configMap.value("enabled").toBool();
        emit cloudEnabledChanged();
    } else if (notif == "Configuration.TcpServerConfigurationChanged") {
        QVariantMap configMap = params.value("tcpServerConfiguration").toMap();
        QString id = configMap.value("id").toString();
        QString address = configMap.value("address").toString();
        int port = configMap.value("port").toInt();
        bool authEnabled = configMap.value("authenticationEnabled").toBool();
        bool sslEnabled = configMap.value("sslEnabled").toBool();

        ServerConfiguration *config = m_tcpServerConfigurations->getConfiguration(id);
        bool existing = true;
        if (!config) {
            existing = false;
            config = new ServerConfiguration(id);
        }
        config->setAddress(address);
        config->setPort(port);
        config->setAuthenticationEnabled(authEnabled);
        config->setSslEnabled(sslEnabled);
        if (!existing) {
            m_tcpServerConfigurations->addConfiguration(config);
        }
    } else if (notif == "Configuration.WebSocketServerConfigurationChanged") {
        QVariantMap configMap = params.value("webSocketServerConfiguration").toMap();
        QString id = configMap.value("id").toString();
        QString address = configMap.value("address").toString();
        int port = configMap.value("port").toInt();
        bool authEnabled = configMap.value("authenticationEnabled").toBool();
        bool sslEnabled = configMap.value("sslEnabled").toBool();

        ServerConfiguration *config = m_webSocketServerConfigurations->getConfiguration(id);
        bool existing = true;
        if (!config) {
            existing = false;
            config = new ServerConfiguration(id);
        }
        config->setAddress(address);
        config->setPort(port);
        config->setAuthenticationEnabled(authEnabled);
        config->setSslEnabled(sslEnabled);
        if (!existing) {
            m_webSocketServerConfigurations->addConfiguration(config);
        }
    } else if (notif == "Configuration.TunnelProxyServerConfigurationChanged") {
        QVariantMap configMap = params.value("tunnelProxyServerConfiguration").toMap();
        QString id = configMap.value("id").toString();
        QString address = configMap.value("address").toString();
        int port = configMap.value("port").toInt();
        bool authEnabled = configMap.value("authenticationEnabled").toBool();
        bool sslEnabled = configMap.value("sslEnabled").toBool();
        bool ignoreSslErrors = configMap.value("ignoreSslErrors").toBool();

        TunnelProxyServerConfiguration *config = qobject_cast<TunnelProxyServerConfiguration*>(m_tunnelProxyServerConfigurations->getConfiguration(id));
        bool existing = true;
        if (!config) {
            existing = false;
            config = new TunnelProxyServerConfiguration(id);
        }
        config->setAddress(address);
        config->setPort(port);
        config->setAuthenticationEnabled(authEnabled);
        config->setSslEnabled(sslEnabled);
        config->setIgnoreSslErrors(ignoreSslErrors);
        if (!existing) {
            qCInfo(dcNymeaConfiguration()) << "Adding tunnel proxy connection:" << config->id() << config->address() << config->port() << config->sslEnabled() << config->authenticationEnabled() << config->ignoreSslErrors();
            m_tunnelProxyServerConfigurations->addConfiguration(config);
        }
    } else if (notif == "Configuration.WebServerConfigurationChanged") {
        QVariantMap configMap = params.value("webServerConfiguration").toMap();
        QString id = configMap.value("id").toString();
        QString address = configMap.value("address").toString();
        int port = configMap.value("port").toInt();
        bool authEnabled = configMap.value("authenticationEnabled").toBool();
        bool sslEnabled = configMap.value("sslEnabled").toBool();
        QString publicFolder  = configMap.value("publicFolder").toString();

        WebServerConfiguration *config = qobject_cast<WebServerConfiguration*>(m_webServerConfigurations->getConfiguration(id));
        bool existing = true;
        if (!config) {
            existing = false;
            config = new WebServerConfiguration(id);
        }
        config->setAddress(address);
        config->setPort(port);
        config->setAuthenticationEnabled(authEnabled);
        config->setSslEnabled(sslEnabled);
        config->setPublicFolder(publicFolder);
        if (!existing) {
            m_webServerConfigurations->addConfiguration(config);
        }
    } else if (notif == "Configuration.MqttServerConfigurationChanged") {
        QVariantMap configMap = params.value("mqttServerConfiguration").toMap();
        QString id = configMap.value("id").toString();
        QString address = configMap.value("address").toString();
        int port = configMap.value("port").toInt();
        bool authEnabled = configMap.value("authenticationEnabled").toBool();
        bool sslEnabled = configMap.value("sslEnabled").toBool();

        ServerConfiguration *config = m_mqttServerConfigurations->getConfiguration(id);
        bool existing = true;
        if (!config) {
            existing = false;
            config = new WebServerConfiguration(id);
        }
        config->setAddress(address);
        config->setPort(port);
        config->setAuthenticationEnabled(authEnabled);
        config->setSslEnabled(sslEnabled);
        if (!existing) {
            m_mqttServerConfigurations->addConfiguration(config);
        }
    } else if (notif == "Configuration.TcpServerConfigurationRemoved") {
        m_tcpServerConfigurations->removeConfiguration(params.value("id").toString());
    } else if (notif == "Configuration.WebSocketServerConfigurationRemoved") {
        m_webSocketServerConfigurations->removeConfiguration(params.value("id").toString());
    } else if (notif == "Configuration.TunnelProxyServerConfigurationRemoved") {
        m_tunnelProxyServerConfigurations->removeConfiguration(params.value("id").toString());
    } else if (notif == "Configuration.WebServerConfigurationRemoved") {
        m_webServerConfigurations->removeConfiguration(params.value("id").toString());
    } else if (notif == "Configuration.MqttServerConfigurationRemoved") {
        m_mqttServerConfigurations->removeConfiguration(params.value("id").toString());
    } else if (notif == "Configuration.MqttPolicyChanged") {
        MqttPolicy *policy = nullptr;
        QVariantMap policyMap = params.value("policy").toMap();
        for (int i = 0; i < m_mqttPolicies->rowCount(); i++) {
            if (m_mqttPolicies->get(i)->clientId() == policyMap.value("clientId").toString()) {
                policy = m_mqttPolicies->get(i);
                break;
            }
        }
        if (!policy) {
            policy = new MqttPolicy(policyMap.value("clientId").toString());
            m_mqttPolicies->addPolicy(policy);
        }
        policy->setUsername(policyMap.value("username").toString());
        policy->setPassword(policyMap.value("password").toString());
        policy->setAllowedPublishTopicFilters(policyMap.value("allowedPublishTopicFilters").toStringList());
        policy->setAllowedSubscribeTopicFilters(policyMap.value("allowedSubscribeTopicFilters").toStringList());
        qCInfo(dcNymeaConfiguration()) << "MQTT policy changed" << policy->clientId() << policy->username() << policy->password();
    } else if (notif == "Configuration.MqttPolicyRemoved") {
        MqttPolicy* policy = m_mqttPolicies->getPolicy(params.value("clientId").toString());
        if (!policy) {
            qCWarning(dcNymeaConfiguration()) << "Reveived a policy removed notification for apolicy we don't know";
            return;
        }
        qCInfo(dcNymeaConfiguration()) << "MQTT policy removed" << policy->clientId() << policy->username() << policy->password();
        m_mqttPolicies->removePolicy(policy);
    } else {
        qCWarning(dcNymeaConfiguration) << "Unhandled Configuration notification" << qUtf8Printable(QJsonDocument::fromVariant(notification).toJson());
    }
}

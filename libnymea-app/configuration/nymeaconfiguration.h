// SPDX-License-Identifier: LGPL-3.0-or-later

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
* Copyright (C) 2013 - 2024, nymea GmbH
* Copyright (C) 2024 - 2025, chargebyte austria GmbH
*
* This file is part of libnymea-app.
*
* libnymea-app is free software: you can redistribute it and/or
* modify it under the terms of the GNU Lesser General Public License
* as published by the Free Software Foundation, either version 3
* of the License, or (at your option) any later version.
*
* libnymea-app is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
* GNU Lesser General Public License for more details.
*
* You should have received a copy of the GNU Lesser General Public License
* along with libnymea-app. If not, see <https://www.gnu.org/licenses/>.
*
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#ifndef NYMEACONFIGURATION_H
#define NYMEACONFIGURATION_H

#include <QObject>

#include "serverconfigurations.h"
#include "mqttpolicies.h"

class JsonRpcClient;
class ServerConfiguration;
class ServerConfigurations;
class WebServerConfiguration;
class WebServerConfigurations;
class TunnelProxyServerConfiguration;
class TunnelProxyServerConfigurations;
class MqttPolicy;

class NymeaConfiguration : public QObject
{
    Q_OBJECT

    Q_PROPERTY(bool fetchingData READ fetchingData NOTIFY fetchingDataChanged)

    Q_PROPERTY(QString serverName READ serverName WRITE setServerName NOTIFY serverNameChanged)

    Q_PROPERTY(bool debugServerEnabled READ debugServerEnabled WRITE setDebugServerEnabled NOTIFY debugServerEnabledChanged)

    Q_PROPERTY(ServerConfigurations* tcpServerConfigurations READ tcpServerConfigurations CONSTANT)
    Q_PROPERTY(ServerConfigurations* webSocketServerConfigurations READ webSocketServerConfigurations CONSTANT)
    Q_PROPERTY(WebServerConfigurations* webServerConfigurations READ webServerConfigurations CONSTANT)
    Q_PROPERTY(TunnelProxyServerConfigurations* tunnelProxyServerConfigurations READ tunnelProxyServerConfigurations CONSTANT)
    Q_PROPERTY(ServerConfigurations* mqttServerConfigurations READ mqttServerConfigurations CONSTANT)

    Q_PROPERTY(MqttPolicies* mqttPolicies READ mqttPolicies CONSTANT)

public:
    explicit NymeaConfiguration(JsonRpcClient* client, QObject *parent = nullptr);

    bool fetchingData() const;

    QString serverName() const;
    void setServerName(const QString &serverName);

    QString language() const;
    void setLanguage(const QString &language);
    QStringList availableLanguages() const;

    QString timezone() const;
    void setTimezone(const QString &timezone);
    QStringList timezones() const;

    bool debugServerEnabled() const;
    void setDebugServerEnabled(bool debugServerEnabled);

    ServerConfigurations *tcpServerConfigurations() const;
    ServerConfigurations *webSocketServerConfigurations() const;
    WebServerConfigurations *webServerConfigurations() const;
    TunnelProxyServerConfigurations *tunnelProxyServerConfigurations() const;
    ServerConfigurations *mqttServerConfigurations() const;
    MqttPolicies *mqttPolicies() const;

    Q_INVOKABLE ServerConfiguration* createServerConfiguration(const QString &address = "0.0.0.0", int port = 0, bool authEnabled = false, bool sslEnabled = false);
    Q_INVOKABLE WebServerConfiguration* createWebServerConfiguration(const QString &address = "0.0.0.0", int port = 0, bool authEnabled = false, bool sslEnabled = false, const QString &publicFolder = QString());
    Q_INVOKABLE TunnelProxyServerConfiguration* createTunnelProxyServerConfiguration(const QString &address, int port, bool authEnabled = true, bool sslEnabled = true, bool ignoreSslErrors = false);
    Q_INVOKABLE MqttPolicy* createMqttPolicy() const;

    Q_INVOKABLE void setTcpServerConfiguration(ServerConfiguration *configuration);
    Q_INVOKABLE void setWebSocketServerConfiguration(ServerConfiguration *configuration);
    Q_INVOKABLE void setWebServerConfiguration(WebServerConfiguration *configuration);
    Q_INVOKABLE void setTunnelProxyServerConfiguration(TunnelProxyServerConfiguration *configuration);
    Q_INVOKABLE void setMqttServerConfiguration(ServerConfiguration *configuration);

    Q_INVOKABLE void deleteTcpServerConfiguration(const QString &id);
    Q_INVOKABLE void deleteWebSocketServerConfiguration(const QString &id);
    Q_INVOKABLE void deleteWebServerConfiguration(const QString &id);
    Q_INVOKABLE void deleteTunnelProxyServerConfiguration(const QString &id);
    Q_INVOKABLE void deleteMqttServerConfiguration(const QString &id);

    Q_INVOKABLE void updateMqttPolicy(MqttPolicy* policy);
    Q_INVOKABLE void deleteMqttPolicy(const QString &clientId);
    void init();

private:
    Q_INVOKABLE void getConfigurationsResponse(int commandId, const QVariantMap &params);
    Q_INVOKABLE void getCloudConfigurationResponse(const QVariantMap &params);
    Q_INVOKABLE void setDebugServerEnabledResponse(int commandId, const QVariantMap &params);
    Q_INVOKABLE void setServerNameResponse(int commandId, const QVariantMap &params);
    Q_INVOKABLE void setTimezoneResponse(int commandId, const QVariantMap &params);
    Q_INVOKABLE void setTcpConfigReply(int commandId, const QVariantMap &params);
    Q_INVOKABLE void deleteTcpConfigReply(int commandId, const QVariantMap &params);
    Q_INVOKABLE void setWebSocketConfigReply(int commandId, const QVariantMap &params);
    Q_INVOKABLE void deleteWebSocketConfigReply(int commandId, const QVariantMap &params);
    Q_INVOKABLE void setTunnelProxyServerConfigReply(int commandId, const QVariantMap &params);
    Q_INVOKABLE void deleteTunnelProxyServerConfigReply(int commandId, const QVariantMap &params);
    Q_INVOKABLE void setWebConfigReply(int commandId, const QVariantMap &params);
    Q_INVOKABLE void deleteWebConfigReply(int commandId, const QVariantMap &params);
    Q_INVOKABLE void getMqttServerConfigsReply(int commandId, const QVariantMap &params);
    Q_INVOKABLE void setMqttConfigReply(int commandId, const QVariantMap &params);
    Q_INVOKABLE void deleteMqttConfigReply(int commandId, const QVariantMap &params);
    Q_INVOKABLE void getMqttPoliciesReply(int commandId, const QVariantMap &params);
    Q_INVOKABLE void setMqttPolicyReply(int commandId, const QVariantMap &params);
    Q_INVOKABLE void deleteMqttPolicyReply(int commandId, const QVariantMap &params);

    Q_INVOKABLE void notificationReceived(const QVariantMap &notification);

signals:
    void fetchingDataChanged();
    void debugServerEnabledChanged();
    void serverNameChanged();

private:
    JsonRpcClient* m_client = nullptr;

    bool m_fetchingData = false;
    bool m_debugServerEnabled = false;
    QString m_serverName;

    ServerConfigurations *m_tcpServerConfigurations = nullptr;
    ServerConfigurations *m_webSocketServerConfigurations = nullptr;
    WebServerConfigurations* m_webServerConfigurations = nullptr;
    TunnelProxyServerConfigurations *m_tunnelProxyServerConfigurations = nullptr;
    ServerConfigurations *m_mqttServerConfigurations = nullptr;
    MqttPolicies *m_mqttPolicies = nullptr;

};

#endif // NYMEACONFIGURATION_H

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

#ifndef NYMEACONFIGURATION_H
#define NYMEACONFIGURATION_H

#include <QObject>

class JsonRpcClient;
class ServerConfiguration;
class ServerConfigurations;
class WebServerConfiguration;
class WebServerConfigurations;
class TunnelProxyServerConfiguration;
class TunnelProxyServerConfigurations;
class MqttPolicy;
class MqttPolicies;

class NymeaConfiguration : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QString serverName READ serverName WRITE setServerName NOTIFY serverNameChanged)

    Q_PROPERTY(bool cloudEnabled READ cloudEnabled WRITE setCloudEnabled NOTIFY cloudEnabledChanged)
    Q_PROPERTY(bool debugServerEnabled READ debugServerEnabled WRITE setDebugServerEnabled NOTIFY debugServerEnabledChanged)

    Q_PROPERTY(ServerConfigurations* tcpServerConfigurations READ tcpServerConfigurations CONSTANT)
    Q_PROPERTY(ServerConfigurations* webSocketServerConfigurations READ webSocketServerConfigurations CONSTANT)
    Q_PROPERTY(WebServerConfigurations* webServerConfigurations READ webServerConfigurations CONSTANT)
    Q_PROPERTY(TunnelProxyServerConfigurations* tunnelProxyServerConfigurations READ tunnelProxyServerConfigurations CONSTANT)
    Q_PROPERTY(ServerConfigurations* mqttServerConfigurations READ mqttServerConfigurations CONSTANT)

    Q_PROPERTY(MqttPolicies* mqttPolicies READ mqttPolicies CONSTANT)

public:
    explicit NymeaConfiguration(JsonRpcClient* client, QObject *parent = nullptr);

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

    bool cloudEnabled() const;
    void setCloudEnabled(bool cloudEnabled);

    ServerConfigurations *tcpServerConfigurations() const;
    ServerConfigurations *webSocketServerConfigurations() const;
    WebServerConfigurations *webServerConfigurations() const;
    TunnelProxyServerConfigurations *tunnelProxyServerConfigurations() const;
    ServerConfigurations *mqttServerConfigurations() const;
    MqttPolicies *mqttPolicies() const;

    Q_INVOKABLE ServerConfiguration* createServerConfiguration(const QString &address = "0.0.0.0", int port = 0, bool authEnabled = false, bool sslEnabled = false);
    Q_INVOKABLE WebServerConfiguration* createWebServerConfiguration(const QString &address = "0.0.0.0", int port = 0, bool authEnabled = false, bool sslEnabled = false, const QString &publicFolder = QString());
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
    Q_INVOKABLE void setCloudEnabledResponse(int commandId, const QVariantMap &params);
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
    void debugServerEnabledChanged();
    void serverNameChanged();
    void cloudEnabledChanged();

private:
    JsonRpcClient* m_client = nullptr;

    bool m_debugServerEnabled = false;
    QString m_serverName;
    bool m_cloudEnabled = false;

    ServerConfigurations *m_tcpServerConfigurations = nullptr;
    ServerConfigurations *m_webSocketServerConfigurations = nullptr;
    WebServerConfigurations* m_webServerConfigurations = nullptr;
    TunnelProxyServerConfigurations *m_tunnelProxyServerConfigurations = nullptr;
    ServerConfigurations *m_mqttServerConfigurations = nullptr;
    MqttPolicies *m_mqttPolicies = nullptr;

};

#endif // NYMEACONFIGURATION_H

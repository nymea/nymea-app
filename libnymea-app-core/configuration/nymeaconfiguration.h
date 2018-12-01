#ifndef NYMEACONFIGURATION_H
#define NYMEACONFIGURATION_H

#include <QObject>

#include "jsonrpc/jsonhandler.h"

class JsonRpcClient;
class ServerConfiguration;
class ServerConfigurations;
class MqttPolicy;
class MqttPolicies;

class NymeaConfiguration : public JsonHandler
{
    Q_OBJECT

    Q_PROPERTY(QString serverName READ serverName WRITE setServerName NOTIFY serverNameChanged)

    Q_PROPERTY(QString language READ language WRITE setLanguage NOTIFY languageChanged)
    Q_PROPERTY(QStringList availableLanguages READ availableLanguages NOTIFY availableLanguagesChanged)

    Q_PROPERTY(QString timezone READ timezone WRITE setTimezone NOTIFY timezoneChanged)
    Q_PROPERTY(QStringList timezones READ timezones NOTIFY timezonesChanged)

    Q_PROPERTY(bool cloudEnabled READ cloudEnabled WRITE setCloudEnabled NOTIFY cloudEnabledChanged)
    Q_PROPERTY(bool debugServerEnabled READ debugServerEnabled WRITE setDebugServerEnabled NOTIFY debugServerEnabledChanged)

    Q_PROPERTY(ServerConfigurations* tcpServerConfigurations READ tcpServerConfigurations CONSTANT)
    Q_PROPERTY(ServerConfigurations* webSocketServerConfigurations READ webSocketServerConfigurations CONSTANT)
    Q_PROPERTY(ServerConfigurations* mqttServerConfigurations READ mqttServerConfigurations CONSTANT)

    Q_PROPERTY(MqttPolicies* mqttPolicies READ mqttPolicies CONSTANT)

public:
    explicit NymeaConfiguration(JsonRpcClient* client, QObject *parent = nullptr);

    QString nameSpace() const override;

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
    ServerConfigurations *mqttServerConfigurations() const;
    MqttPolicies *mqttPolicies() const;

    Q_INVOKABLE ServerConfiguration* createServerConfiguration(const QString &address = "0.0.0.0", int port = 0, bool authEnabled = false, bool sslEnabled = false);
    Q_INVOKABLE MqttPolicy* createMqttPolicy() const;

    Q_INVOKABLE void setTcpServerConfiguration(ServerConfiguration *configuration);
    Q_INVOKABLE void setWebSocketServerConfiguration(ServerConfiguration *configuration);
    Q_INVOKABLE void setMqttServerConfiguration(ServerConfiguration *configuration);

    Q_INVOKABLE void deleteTcpServerConfiguration(const QString &id);
    Q_INVOKABLE void deleteWebSocketServerConfiguration(const QString &id);
    Q_INVOKABLE void deleteMqttServerConfiguration(const QString &id);

    Q_INVOKABLE void updateMqttPolicy(MqttPolicy* policy);
    Q_INVOKABLE void deleteMqttPolicy(const QString &clientId);
    void init();

private:
    Q_INVOKABLE void getConfigurationsResponse(const QVariantMap &params);
    Q_INVOKABLE void getCloudConfigurationResponse(const QVariantMap &params);
    Q_INVOKABLE void setDebugServerEnabledResponse(const QVariantMap &params);
    Q_INVOKABLE void setServerNameResponse(const QVariantMap &params);
    Q_INVOKABLE void setCloudEnabledResponse(const QVariantMap &params);
    Q_INVOKABLE void getAvailableLanguagesResponse(const QVariantMap &params);
    Q_INVOKABLE void getTimezonesResponse(const QVariantMap &params);
    Q_INVOKABLE void setTimezoneResponse(const QVariantMap &params);
    Q_INVOKABLE void setTcpConfigReply(const QVariantMap &params);
    Q_INVOKABLE void deleteTcpConfigReply(const QVariantMap &params);
    Q_INVOKABLE void setWebSocketConfigReply(const QVariantMap &params);
    Q_INVOKABLE void deleteWebSocketConfigReply(const QVariantMap &params);
    Q_INVOKABLE void getMqttServerConfigsReply(const QVariantMap &params);
    Q_INVOKABLE void setMqttConfigReply(const QVariantMap &params);
    Q_INVOKABLE void deleteMqttConfigReply(const QVariantMap &params);
    Q_INVOKABLE void getMqttPoliciesReply(const QVariantMap &params);
    Q_INVOKABLE void setMqttPolicyReply(const QVariantMap &params);
    Q_INVOKABLE void deleteMqttPolicyReply(const QVariantMap &params);

    Q_INVOKABLE void notificationReceived(const QVariantMap &notification);

signals:
    void debugServerEnabledChanged();
    void serverNameChanged();
    void languageChanged();
    void availableLanguagesChanged();
    void timezoneChanged();
    void timezonesChanged();
    void cloudEnabledChanged();

private:
    JsonRpcClient* m_client = nullptr;

    bool m_debugServerEnabled = false;
    QString m_serverName;
    QString m_language;
    QStringList m_availableLanguages;
    QString m_timezone;
    QStringList m_timezones;
    bool m_cloudEnabled = false;

    ServerConfigurations *m_tcpServerConfigurations = nullptr;
    ServerConfigurations *m_webSocketServerConfigurations = nullptr;
    ServerConfigurations *m_mqttServerConfigurations = nullptr;
    MqttPolicies *m_mqttPolicies = nullptr;

};

#endif // NYMEACONFIGURATION_H

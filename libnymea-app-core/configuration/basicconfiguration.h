#ifndef BASICCONFIGURATION_H
#define BASICCONFIGURATION_H

#include <QObject>
#include "jsonrpc/jsonhandler.h"
#include "serverconfigurations.h"

class JsonRpcClient;

class BasicConfiguration : public JsonHandler
{
    Q_OBJECT
    Q_PROPERTY(bool debugServerEnabled READ debugServerEnabled WRITE setDebugServerEnabled NOTIFY debugServerEnabledChanged)
    Q_PROPERTY(QString serverName READ serverName WRITE setServerName NOTIFY serverNameChanged)
    Q_PROPERTY(QString language READ language WRITE setLanguage NOTIFY languageChanged)
    Q_PROPERTY(QString timezone READ timezone WRITE setTimezone NOTIFY timezoneChanged)

    Q_PROPERTY(bool cloudEnabled READ cloudEnabled WRITE setCloudEnabled NOTIFY cloudEnabledChanged)

    Q_PROPERTY(QStringList availableLanguages READ availableLanguages NOTIFY availableLanguagesChanged)
    Q_PROPERTY(QStringList timezones READ timezones NOTIFY timezonesChanged)

    Q_PROPERTY(ServerConfigurations* tcpServerConfigurations READ tcpServerConfigurations CONSTANT)
    Q_PROPERTY(ServerConfigurations* websocketServerConfigurations READ websocketServerConfigurations CONSTANT)

public:
    explicit BasicConfiguration(JsonRpcClient* client, QObject *parent = nullptr);

    QString nameSpace() const override;

    bool debugServerEnabled() const;
    void setDebugServerEnabled(bool debugServerEnabled);

    QString serverName() const;
    void setServerName(const QString &serverName);

    bool cloudEnabled() const;
    void setCloudEnabled(bool cloudEnabled);

    QString language() const;
    void setLanguage(const QString &language);

    QStringList availableLanguages() const;

    QString timezone() const;
    void setTimezone(const QString &timezone);

    QStringList timezones() const;

    ServerConfigurations *tcpServerConfigurations() const;
    ServerConfigurations *websocketServerConfigurations() const;

    void setTcpServerConfiguration(ServerConfiguration *configuration) const;
    void setWebsocketServerConfiguration(ServerConfiguration *configuration) const;

    Q_INVOKABLE void deleteTcpServerConfiguration(const QString &id);
    Q_INVOKABLE void deleteWebsocketServerConfiguration(const QString &id);

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
    Q_INVOKABLE void deleteTcpConfigReply(const QVariantMap &params);
    Q_INVOKABLE void deleteWebSocketConfigReply(const QVariantMap &params);

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
    ServerConfigurations *m_websocketServerConfigurations = nullptr;
};

#endif // BASICCONFIGURATION_H

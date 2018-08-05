#ifndef BASICCONFIGURATION_H
#define BASICCONFIGURATION_H

#include <QObject>
#include "jsonrpc/jsonhandler.h"

class JsonRpcClient;

class BasicConfiguration : public JsonHandler
{
    Q_OBJECT
    Q_PROPERTY(bool debugServerEnabled READ debugServerEnabled WRITE setDebugServerEnabled NOTIFY debugServerEnabledChanged)
    Q_PROPERTY(QString serverName READ serverName WRITE setServerName NOTIFY serverNameChanged)

    Q_PROPERTY(bool cloudEnabled READ cloudEnabled WRITE setCloudEnabled NOTIFY cloudEnabledChanged)

public:
    explicit BasicConfiguration(JsonRpcClient* client, QObject *parent = nullptr);

    QString nameSpace() const override;

    bool debugServerEnabled() const;
    void setDebugServerEnabled(bool debugServerEnabled);

    QString serverName() const;
    void setServerName(const QString &serverName);

    bool cloudEnabled() const;
    void setCloudEnabled(bool cloudEnabled);

    void init();

private:
    Q_INVOKABLE void getConfigurationsResponse(const QVariantMap &params);
    Q_INVOKABLE void getCloudConfigurationResponse(const QVariantMap &params);
    Q_INVOKABLE void setDebugServerEnabledResponse(const QVariantMap &params);
    Q_INVOKABLE void setServerNameResponse(const QVariantMap &params);
    Q_INVOKABLE void setCloudEnabledResponse(const QVariantMap &params);

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
};

#endif // BASICCONFIGURATION_H

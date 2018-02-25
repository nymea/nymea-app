#ifndef BASICCONFIGURATION_H
#define BASICCONFIGURATION_H

#include <QObject>

class JsonRpcClient;

class BasicConfiguration : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool debugServerEnabled READ debugServerEnabled WRITE setDebugServerEnabled NOTIFY debugServerEnabledChanged)
    Q_PROPERTY(QString serverName READ serverName WRITE setServerName NOTIFY serverNameChanged)
public:
    explicit BasicConfiguration(JsonRpcClient* client, QObject *parent = nullptr);

    bool debugServerEnabled() const;
    void setDebugServerEnabled(bool debugServerEnabled);

    QString serverName() const;
    void setServerName(const QString &serverName);

    void init();

private:
    Q_INVOKABLE void getConfigurationsResponse(const QVariantMap &params);
    Q_INVOKABLE void setDebugServerEnabledResponse(const QVariantMap &params);
    Q_INVOKABLE void setServerNameResponse(const QVariantMap &params);

signals:
    void debugServerEnabledChanged();
    void serverNameChanged();

private:
    JsonRpcClient* m_client = nullptr;
    bool m_debugServerEnabled = false;
    QString m_serverName;
};

#endif // BASICCONFIGURATION_H

#ifndef MQTTBROKERCONFIGURATION_H
#define MQTTBROKERCONFIGURATION_H

#include <QObject>

class MqttBrokerConfiguration : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString username READ username WRITE setUsername NOTIFY usernameChanged)
    Q_PROPERTY(QString password READ password WRITE setPassword NOTIFY passwordChanged)
public:
    explicit MqttBrokerConfiguration(QObject *parent = nullptr);

    QString username() const;
    void setUsername(const QString &username);

    QString password() const;
    void setPassword(const QString &password);

signals:
    void usernameChanged();
    void passwordChanged();

private:
    QString m_username;
    QString m_password;
};

#endif // MQTTBROKERCONFIGURATION_H

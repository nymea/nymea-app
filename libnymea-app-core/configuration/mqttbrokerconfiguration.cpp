#include "mqttbrokerconfiguration.h"

MqttBrokerConfiguration::MqttBrokerConfiguration(QObject *parent) : QObject(parent)
{

}

QString MqttBrokerConfiguration::username() const
{
    return m_username;
}

void MqttBrokerConfiguration::setUsername(const QString &username)
{
    if (m_username != username) {
        m_username = username;
        emit usernameChanged();
    }
}

QString MqttBrokerConfiguration::password() const
{
    return m_password;
}

void MqttBrokerConfiguration::setPassword(const QString &password)
{
    if (m_password != password) {
        m_password = password;
        emit passwordChanged();
    }
}

#include "mqttpolicy.h"

MqttPolicy::MqttPolicy(const QString &clientId, const QString &username, const QString &password, const QStringList &allowedPublishTopicFilters, const QStringList &allowedSubscribeTopicFilters, QObject *parent):
    QObject(parent),
    m_clientId(clientId),
    m_username(username),
    m_password(password),
    m_allowedSubscribeTopicFilters(allowedSubscribeTopicFilters),
    m_allowedPublishTopicFilters(allowedPublishTopicFilters)
{

}

QString MqttPolicy::clientId() const
{
    return m_clientId;
}

void MqttPolicy::setClientId(const QString &clientId)
{
    if (m_clientId != clientId) {
        m_clientId = clientId;
        emit clientIdChanged();
    }
}

QString MqttPolicy::username() const
{
    return m_username;
}

void MqttPolicy::setUsername(const QString &username)
{
    if (m_username != username) {
        m_username = username;
        emit usernameChanged();
    }
}

QString MqttPolicy::password() const
{
    return m_password;
}

void MqttPolicy::setPassword(const QString &password)
{
    if (m_password != password) {
        m_password = password;
        emit passwordChanged();
    }
}

QStringList MqttPolicy::allowedPublishTopicFilters() const
{
    return m_allowedPublishTopicFilters;
}

void MqttPolicy::setAllowedPublishTopicFilters(const QStringList &allowedPublishTopicFilters)
{
    if (m_allowedPublishTopicFilters != allowedPublishTopicFilters) {
        m_allowedPublishTopicFilters = allowedPublishTopicFilters;
        emit allowedPublishTopicFiltersChanged();
    }
}

QStringList MqttPolicy::allowedSubscribeTopicFilters() const
{
    return m_allowedSubscribeTopicFilters;
}

void MqttPolicy::setAllowedSubscribeTopicFilters(const QStringList &allowedSubscribeTopicFilters)
{
    if (m_allowedSubscribeTopicFilters != allowedSubscribeTopicFilters) {
        m_allowedSubscribeTopicFilters = allowedSubscribeTopicFilters;
        emit allowedSubscribeTopicFiltersChanged();
    }
}

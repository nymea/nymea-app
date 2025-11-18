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

#include "mqttpolicy.h"

MqttPolicy::MqttPolicy(const QString &clientId, const QString &username, const QString &password, const QStringList &allowedPublishTopicFilters, const QStringList &allowedSubscribeTopicFilters, QObject *parent):
    QObject(parent),
    m_clientId(clientId),
    m_username(username),
    m_password(password),
    m_allowedPublishTopicFilters(allowedPublishTopicFilters),
    m_allowedSubscribeTopicFilters(allowedSubscribeTopicFilters)
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

MqttPolicy *MqttPolicy::clone()
{
    return new MqttPolicy(m_clientId, m_username, m_password, m_allowedPublishTopicFilters, m_allowedSubscribeTopicFilters, this);
}

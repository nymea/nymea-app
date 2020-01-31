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

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

#ifndef MQTTPOLICY_H
#define MQTTPOLICY_H

#include <QObject>

class MqttPolicy : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString clientId READ clientId WRITE setClientId NOTIFY clientIdChanged)
    Q_PROPERTY(QString username READ username WRITE setUsername NOTIFY usernameChanged)
    Q_PROPERTY(QString password READ password WRITE setPassword NOTIFY passwordChanged)
    Q_PROPERTY(QStringList allowedPublishTopicFilters READ allowedPublishTopicFilters WRITE setAllowedPublishTopicFilters NOTIFY allowedPublishTopicFiltersChanged)
    Q_PROPERTY(QStringList allowedSubscribeTopicFilters READ allowedSubscribeTopicFilters WRITE setAllowedSubscribeTopicFilters NOTIFY allowedSubscribeTopicFiltersChanged)

public:
    explicit MqttPolicy(const QString &clientId = QString(),
                        const QString &username = QString(),
                        const QString &password = QString(),
                        const QStringList &allowedPublishTopicFilters = QStringList(),
                        const QStringList &allowedSubscribeTopicFilters = QStringList(),
                        QObject *parent = nullptr);

    QString clientId() const;
    void setClientId(const QString &clientId);

    QString username() const;
    void setUsername(const QString &username);

    QString password() const;
    void setPassword(const QString &password);

    QStringList allowedPublishTopicFilters() const;
    void setAllowedPublishTopicFilters(const QStringList &allowedPublishTopicFilters);

    QStringList allowedSubscribeTopicFilters() const;
    void setAllowedSubscribeTopicFilters(const QStringList &allowedSubscribeTopicFilters);

    Q_INVOKABLE MqttPolicy* clone();
signals:
    void clientIdChanged();
    void usernameChanged();
    void passwordChanged();
    void allowedPublishTopicFiltersChanged();
    void allowedSubscribeTopicFiltersChanged();

private:
    QString m_clientId;
    QString m_username;
    QString m_password;
    QStringList m_allowedPublishTopicFilters;
    QStringList m_allowedSubscribeTopicFilters;
};

#endif // MQTTPOLICY_H

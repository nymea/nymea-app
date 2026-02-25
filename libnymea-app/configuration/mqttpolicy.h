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

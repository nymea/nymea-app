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

#ifndef MQTTPOLICIES_H
#define MQTTPOLICIES_H

#include <QObject>
#include <QAbstractListModel>

class MqttPolicy;

class MqttPolicies : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)
public:
    enum Roles {
        RoleClientId,
        RoleUsername,
        RolePassword,
        RoleAllowedPublishTopicFilters,
        RoleAllowedSubscribeTopicFilters
    };

    explicit MqttPolicies(QObject *parent = nullptr);

    int rowCount(const QModelIndex &index = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

    void addPolicy(MqttPolicy *policy);
    void removePolicy(MqttPolicy *policy);

    Q_INVOKABLE MqttPolicy* getPolicy(const QString &clientId) const;
    Q_INVOKABLE MqttPolicy* get(int index) const;

    void clear();
signals:
    void countChanged();

private:
    QList<MqttPolicy*> m_list;
};

#endif // MQTTPOLICIES_H

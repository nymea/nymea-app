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

#ifndef SERVERCONFIGURATIONS_H
#define SERVERCONFIGURATIONS_H

#include <QObject>
#include <QAbstractListModel>

#include "serverconfiguration.h"

class ServerConfigurations : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)

public:
    enum Roles {
        RoleId,
        RoleAddress,
        RolePort,
        RoleAuthenticationEnabled,
        RoleSslEnabled
    };
    Q_ENUM(Roles)

    explicit ServerConfigurations(QObject *parent = nullptr);
    virtual ~ServerConfigurations() override = default;

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

    void addConfiguration(ServerConfiguration *configuration);
    void removeConfiguration(const QString &id);

    void clear();

    Q_INVOKABLE ServerConfiguration* get(int index) const;
    Q_INVOKABLE ServerConfiguration* getConfiguration(const QString &id) const;

signals:
    void countChanged();

protected:
    QList<ServerConfiguration*> m_list;
};


class WebServerConfigurations: public ServerConfigurations
{
    Q_OBJECT
public:
    WebServerConfigurations(QObject *parent = nullptr): ServerConfigurations(parent) {}

    Q_INVOKABLE WebServerConfiguration* getWebServerConfiguration(int index) const {
        return dynamic_cast<WebServerConfiguration*>(m_list.at(index));
    }
};

class TunnelProxyServerConfigurations: public ServerConfigurations
{
    Q_OBJECT
public:
    TunnelProxyServerConfigurations(QObject *parent = nullptr): ServerConfigurations(parent) {}

    Q_INVOKABLE TunnelProxyServerConfiguration* getTunnelProxyServerConfiguration(int index) const {
        return dynamic_cast<TunnelProxyServerConfiguration*>(m_list.at(index));
    }
};

#endif // SERVERCONFIGURATIONS_H

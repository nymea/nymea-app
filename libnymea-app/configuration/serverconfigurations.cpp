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

#include "serverconfigurations.h"
#include "serverconfiguration.h"

ServerConfigurations::ServerConfigurations(QObject *parent) : QAbstractListModel(parent)
{

}

int ServerConfigurations::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return m_list.count();
}

QVariant ServerConfigurations::data(const QModelIndex &index, int role) const
{
    switch (role) {
    case RoleId:
        return m_list.at(index.row())->id();
    case RoleAddress:
        return m_list.at(index.row())->address();
    case RolePort:
        return m_list.at(index.row())->port();
    case RoleAuthenticationEnabled:
        return m_list.at(index.row())->authenticationEnabled();
    case RoleSslEnabled:
        return m_list.at(index.row())->sslEnabled();
    }
    return QVariant();
}

QHash<int, QByteArray> ServerConfigurations::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles.insert(RoleId, "id");
    roles.insert(RoleAddress, "address");
    roles.insert(RolePort, "port");
    roles.insert(RoleAuthenticationEnabled, "authenticationEnabled");
    roles.insert(RoleSslEnabled, "sslEnabled");
    return roles;
}

void ServerConfigurations::addConfiguration(ServerConfiguration *configuration)
{
    configuration->setParent(this);
    beginInsertRows(QModelIndex(), m_list.count(), m_list.count());
    m_list.append(configuration);

    connect(configuration, &ServerConfiguration::addressChanged, this, [this, configuration]() {
        QModelIndex idx = index(m_list.indexOf(configuration), 0);
        emit dataChanged(idx, idx, {RoleAddress});
    });
    connect(configuration, &ServerConfiguration::portChanged, this, [this, configuration]() {
        QModelIndex idx = index(m_list.indexOf(configuration), 0);
        emit dataChanged(idx, idx, {RolePort});
    });
    connect(configuration, &ServerConfiguration::authenticationEnabledChanged, this, [this, configuration]() {
        QModelIndex idx = index(m_list.indexOf(configuration), 0);
        emit dataChanged(idx, idx, {RoleAuthenticationEnabled});
    });
    connect(configuration, &ServerConfiguration::sslEnabledChanged, this, [this, configuration]() {
        QModelIndex idx = index(m_list.indexOf(configuration), 0);
        emit dataChanged(idx, idx, {RoleSslEnabled});
    });

    endInsertRows();
    emit countChanged();
}

void ServerConfigurations::removeConfiguration(const QString &id)
{
    for (int i = 0; i < m_list.count(); i++) {
        if (m_list.at(i)->id() == id) {
            beginRemoveRows(QModelIndex(), i, i);
            m_list.takeAt(i)->deleteLater();
            endRemoveRows();
            emit countChanged();
            return;
        }
    }
}

void ServerConfigurations::clear()
{
    beginResetModel();
    qDeleteAll(m_list);
    m_list.clear();
    endResetModel();
    emit countChanged();
}

ServerConfiguration *ServerConfigurations::get(int index) const
{
    if (index < 0 || index > m_list.count() - 1) {
        return nullptr;
    }
    return m_list.at(index);
}

ServerConfiguration *ServerConfigurations::getConfiguration(const QString &id) const
{
    for (int i = 0; i < m_list.count(); i++) {
        if (m_list.at(i)->id() == id) {
            return m_list.at(i);
        }
    }
    return nullptr;
}

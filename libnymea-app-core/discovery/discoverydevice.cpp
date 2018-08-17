/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *                                                                         *
 *  Copyright (C) 2018 Michael Zanetti <michael.zanetti@guh.io>            *
 *                                                                         *
 *  This file is part of nymea:app.                                              *
 *                                                                         *
 *  nymea:app is free software: you can redistribute it and/or modify            *
 *  it under the terms of the GNU General Public License as published by   *
 *  the Free Software Foundation, version 3 of the License.                *
 *                                                                         *
 *  nymea:app is distributed in the hope that it will be useful,                 *
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of         *
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the           *
 *  GNU General Public License for more details.                           *
 *                                                                         *
 *  You should have received a copy of the GNU General Public License      *
 *  along with nymea:app. If not, see <http://www.gnu.org/licenses/>.            *
 *                                                                         *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#include "discoverydevice.h"

#include <QUrl>

DiscoveryDevice::DiscoveryDevice(QObject *parent):
    QObject(parent),
    m_connections(new Connections(this))
{
}

QUuid DiscoveryDevice::uuid() const
{
    return m_uuid;
}

void DiscoveryDevice::setUuid(const QUuid &uuid)
{
    m_uuid = uuid;
}

QString DiscoveryDevice::name() const
{
    return m_name;
}

void DiscoveryDevice::setName(const QString &name)
{
    if (m_name != name) {
        m_name = name;
        emit nameChanged();
    }
}

QString DiscoveryDevice::version() const
{
    return m_version;
}

void DiscoveryDevice::setVersion(const QString &version)
{
    if (m_version != version) {
        m_version = version;
        emit versionChanged();
    }
}

Connections* DiscoveryDevice::connections() const
{
    return m_connections;
}

Connections::Connections(QObject *parent):
    QAbstractListModel(parent)
{

}

int Connections::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return m_connections.count();
}

QVariant Connections::data(const QModelIndex &index, int role) const
{
    switch (role) {
    case RoleUrl:
        return m_connections.at(index.row())->url();
    case RoleName:
        return m_connections.at(index.row())->displayName();
    case RoleBearerType:
        return m_connections.at(index.row())->bearerType();
    case RoleSecure:
        return m_connections.at(index.row())->secure();
    }
    return QVariant();
}

Connection* Connections::find(const QUrl &url) const
{
    foreach (Connection *conn, m_connections) {
        if (conn->url() == url) {
            return conn;
        }
    }
    return nullptr;
}

void Connections::addConnection(Connection *connection)
{
    connection->setParent(this);
    beginInsertRows(QModelIndex(), m_connections.count(), m_connections.count());
    m_connections.append(connection);
    endInsertRows();
    emit countChanged();
}

Connection* Connections::get(int index) const
{
    if (index >= 0 && index < m_connections.count()) {
        return m_connections.at(index);
    }
    return nullptr;
}

QHash<int, QByteArray> Connections::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles.insert(RoleUrl, "url");
    roles.insert(RoleBearerType, "bearerType");
    roles.insert(RoleName, "name");
    roles.insert(RoleSecure, "secure");
    return roles;
}

Connection::Connection(const QUrl &url, Connection::BearerType bearerType, bool secure, const QString &displayName, QObject *parent):
    QObject(parent),
    m_url(url),
    m_bearerType(bearerType),
    m_secure(secure),
    m_displayName(displayName)
{

}

QUrl Connection::url() const
{
    return m_url;
}

Connection::BearerType Connection::bearerType() const
{
    return m_bearerType;
}

bool Connection::secure() const
{
    return m_secure;
}

QString Connection::displayName() const
{
    return m_displayName;
}

bool Connection::online() const
{
    return m_online;
}

void Connection::setOnline(bool online)
{
    if (m_online != online) {
        m_online = online;
        emit onlineChanged();
    }
}

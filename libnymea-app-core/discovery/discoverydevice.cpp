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
    case RoleOnline:
        return m_connections.at(index.row())->online();
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
    connect(connection, &Connection::onlineChanged, this, [this, connection]() {
        int idx = m_connections.indexOf(connection);
        if (idx < 0) {
            return;
        }
        emit dataChanged(index(idx), index(idx), {RoleOnline});
    });
    endInsertRows();
    emit connectionAdded(connection);
    emit countChanged();
}

void Connections::removeConnection(Connection *connection)
{
    int idx = m_connections.indexOf(connection);
    if (idx == -1) {
        qWarning() << "Cannot remove connections as it's not in this model";
        return;
    }
    beginRemoveRows(QModelIndex(), idx, idx);
    m_connections.takeAt(idx)->deleteLater();
    endRemoveRows();
    emit connectionRemoved(connection);
    emit countChanged();
}

void Connections::removeConnection(int index)
{
    if (index < 0 || index >= m_connections.count()) {
        qWarning() << "Index out of range. Not removing any connection";
        return;
    }
    beginRemoveRows(QModelIndex(), index, index);
    m_connections.takeAt(index)->deleteLater();
    endRemoveRows();
    emit countChanged();
}

Connection* Connections::get(int index) const
{
    if (index >= 0 && index < m_connections.count()) {
        return m_connections.at(index);
    }
    return nullptr;
}

Connection* Connections::bestMatch() const
{
    QList<Connection::BearerType> bearerPreference = {Connection::BearerTypeEthernet, Connection::BearerTypeWifi, Connection::BearerTypeCloud, Connection::BearerTypeBluetooth, Connection::BearerTypeUnknown};
    Connection *best = nullptr;
    foreach (Connection *c, m_connections) {
        if (!best) {
            best = c;
            continue;
        }
        uint oldBearerPriority = static_cast<uint>(bearerPreference.indexOf(best->bearerType()));
        uint newBearerPriority = static_cast<uint>(bearerPreference.indexOf(c->bearerType()));
        if (newBearerPriority < oldBearerPriority) {
            // New one has better bearer, switch
            best = c;
            continue;
        }
        if (oldBearerPriority < newBearerPriority) {
            // Discard new one as the existing is on a better bearer
            continue;
        }

        // Same bearer, prefer secure over insecure
        if (!best->secure() && c->secure()) {
            // New one is secure, old one not. switch
            best = c;
            continue;
        }
        if (best->secure() && !c->secure()) {
            // Old one is secure, new one isn't, skip new one
            continue;
        }

        // both options are now on the same bearer and either secure or insecure, prefer nymearpc over websocket for less overhead
        if (best->url().scheme().startsWith("ws") && c->url().scheme().startsWith("nymea")) {
            best = c;
        }
    }
    return best;
}

QHash<int, QByteArray> Connections::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles.insert(RoleUrl, "url");
    roles.insert(RoleBearerType, "bearerType");
    roles.insert(RoleName, "name");
    roles.insert(RoleSecure, "secure");
    roles.insert(RoleOnline, "online");
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

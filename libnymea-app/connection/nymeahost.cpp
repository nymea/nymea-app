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

#include "nymeahost.h"

#include <QUrl>

NymeaHost::NymeaHost(QObject *parent):
    QObject(parent),
    m_connections(new Connections(this))
{
    connect(m_connections, &Connections::dataChanged, this, [this](const QModelIndex &, const QModelIndex &, const QVector<int>){
        emit connectionChanged();
        syncOnlineState();
    });
    connect(m_connections, &Connections::connectionAdded, this, [this](Connection*){
        emit connectionChanged();
        syncOnlineState();
    });
    connect(m_connections, &Connections::connectionRemoved, this, [this](Connection*){
        emit connectionChanged();
        syncOnlineState();
    });
}

NymeaHost::~NymeaHost()
{
    qDebug() << "Deleting host:" << this << m_name;
}

QUuid NymeaHost::uuid() const
{
    return m_uuid;
}

void NymeaHost::setUuid(const QUuid &uuid)
{
    m_uuid = uuid;
}

QString NymeaHost::name() const
{
    return m_name;
}

void NymeaHost::setName(const QString &name)
{
    if (m_name != name) {
        m_name = name;
        emit nameChanged();
    }
}

QString NymeaHost::version() const
{
    return m_version;
}

void NymeaHost::setVersion(const QString &version)
{
    if (m_version != version) {
        m_version = version;
        emit versionChanged();
    }
}

Connections* NymeaHost::connections() const
{
    return m_connections;
}

bool NymeaHost::online() const
{
    return m_online;
}

void NymeaHost::syncOnlineState()
{
    for (int i = 0; i < m_connections->rowCount(); i++) {
        if (m_connections->get(i)->online()) {
            if (!m_online) {
                m_online = true;
                emit onlineChanged();
            }
            return;
        }
    }
    if (m_online) {
        m_online = false;
        emit onlineChanged();
    }
}

Connections::Connections(QObject *parent):
    QAbstractListModel(parent)
{

}

Connections::~Connections()
{
    qDebug() << "Deleting connections" << this;
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

Connection *Connections::bestMatch(Connection::BearerTypes bearerTypes) const
{
    Connection *best = nullptr;
    foreach (Connection *c, m_connections) {
//        qWarning() << "have connection:" << bearerTypes << c->url() << c->bearerType() << bearerTypes.testFlag(c->bearerType());
        if ((bearerTypes & c->bearerType()) == Connection::BearerTypeNone) {
            continue;
        }
        if (!best) {
            best = c;
            continue;
        }
        if (c->priority() > best->priority()) {
            best = c;
        }
    }
    return best;
}

void Connections::addConnection(const QUrl &url, Connection::BearerType bearerType, bool secure, const QString &displayName, bool manual)
{
    Connection *connection = new Connection(url, bearerType, secure, displayName);
    connection->setManual(manual);
    addConnection(connection);
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

Connection::Connection(const QUrl &url, Connection::BearerType bearerType, bool secure, const QString &note, QObject *parent):
    QObject(parent),
    m_url(url),
    m_bearerType(bearerType),
    m_secure(secure),
    m_displayName(note)
{
    qRegisterMetaType<Connection::BearerType>("Connection.BearerType");
}

Connection::~Connection()
{
    qDebug() << "Deleting Connection" << this << parent() << parent()->parent();
}

QUrl Connection::url() const
{
    return m_url;
}

QString Connection::hostAddress() const
{
    return m_url.host();
}

int Connection::port() const
{
    return m_url.port();
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
    return m_manual || m_online;
}

void Connection::setOnline(bool online)
{
    if (m_online != online) {
        m_online = online;
        m_lastSeen = QDateTime::currentDateTime();
        emit onlineChanged();
        emit priorityChanged();
    }
}

bool Connection::manual() const
{
    return m_manual;
}

void Connection::setManual(bool manual)
{
    if (m_manual != manual) {
        m_manual = manual;
        emit onlineChanged();
        emit priorityChanged();
    }
}

int Connection::priority() const
{
    int prio = 0;
    if (m_online) {
        prio += 1000;
        prio -= qMin(500, (int)m_lastSeen.secsTo(QDateTime::currentDateTime()));
    }

    switch(m_bearerType) {
    case BearerTypeLan:
        prio += 400;
        break;
    case BearerTypeWan:
        prio += 300;
        break;
    case BearerTypeCloud:
        prio += 200;
        if (m_url.scheme().startsWith("tunnel")) {
            prio += 1;
        }
        break;
    case BearerTypeBluetooth:
        prio += 100;
        break;
    default:
        prio += 0;
    }
    if (m_secure) {
        prio += 10;
    }
    if (m_url.scheme().startsWith("nymea")) {
        prio += 1;
    }
    return prio;
}

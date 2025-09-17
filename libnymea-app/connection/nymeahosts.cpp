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

#include "nymeahosts.h"
#include "nymeahost.h"

#include <QUuid>

NymeaHosts::NymeaHosts(QObject *parent) :
    QAbstractListModel(parent)
{
}

int NymeaHosts::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return m_hosts.count();
}

QVariant NymeaHosts::data(const QModelIndex &index, int role) const
{
    if (index.row() < 0 || index.row() >= m_hosts.count())
        return QVariant();

    NymeaHost *host = m_hosts.at(index.row());
    switch (role) {
    case UuidRole:
        return host->uuid();
    case NameRole:
        return host->name();
    case VersionRole:
        return host->version();
    }
    return QVariant();
}

void NymeaHosts::addHost(NymeaHost *host)
{
    for (int i = 0; i < m_hosts.count(); i++) {
        if (m_hosts.at(i)->uuid() == host->uuid()) {
            qWarning() << "Host already added. Update existing host instead.";
            return;
        }
    }
    host->setParent(this);
    connect(host, &NymeaHost::nameChanged, this, [=](){
        int idx = m_hosts.indexOf(host);
        emit dataChanged(index(idx), index(idx), {NameRole});
    });
    connect(host, &NymeaHost::versionChanged, this, [=](){
        int idx = m_hosts.indexOf(host);
        emit dataChanged(index(idx), index(idx), {VersionRole});
    });
    connect(host, &NymeaHost::connectionChanged, this, &NymeaHosts::hostChanged);

    beginInsertRows(QModelIndex(), m_hosts.count(), m_hosts.count());
    m_hosts.append(host);
    endInsertRows();
    emit hostAdded(host);
    emit countChanged();
}

void NymeaHosts::removeHost(NymeaHost *host)
{
    int idx = m_hosts.indexOf(host);
    if (idx == -1) {
        qWarning() << "Cannot remove NymeaHost" << host << "as its not in the model";
        return;
    }
    beginRemoveRows(QModelIndex(), idx, idx);
    m_hosts.takeAt(idx);
    endRemoveRows();



    emit hostRemoved(host);
    emit countChanged();
}

NymeaHost *NymeaHosts::createCloudHost(const QString &name, const QUrl &url)
{
    return createHost(name, url, Connection::BearerTypeCloud);
}

NymeaHost *NymeaHosts::createLanHost(const QString &name, const QUrl &url)
{
    if (QHostAddress(url.host()).isLoopback()) {
        return createHost(name, url, Connection::BearerTypeLoopback);
    }
    return createHost(name, url, Connection::BearerTypeLan);
}

NymeaHost *NymeaHosts::createWanHost(const QString &name, const QUrl &url)
{
    return createHost(name, url, Connection::BearerTypeWan);
}

NymeaHost *NymeaHosts::createHost(const QString &name, const QUrl &url, Connection::BearerType bearerType)
{
    NymeaHost *host = new NymeaHost(this);
    host->setName(name);
    Connection *connection = new Connection(url, bearerType, false, name, host);
    connection->setManual(true);
    host->connections()->addConnection(connection);
    addHost(host);
    return host;
}

NymeaHost *NymeaHosts::get(int index) const
{
    if (index < 0 || index >= m_hosts.count()) {
        return nullptr;
    }
    return m_hosts.at(index);
}

NymeaHost *NymeaHosts::find(const QUuid &uuid)
{
    foreach (NymeaHost *dev, m_hosts) {
        if (dev->uuid() == uuid) {
            return dev;
        }
    }
    return nullptr;
}

void NymeaHosts::clearModel()
{
    beginResetModel();
    m_hosts.clear();
    endResetModel();
    emit countChanged();
}

QHash<int, QByteArray> NymeaHosts::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[UuidRole] = "uuid";
    roles[NameRole] = "name";
    roles[VersionRole] = "version";
    return roles;
}

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *                                                                         *
 *  Copyright (C) 2015 Simon Stuerz <stuerz.simon@gmail.com>               *
 *                                                                         *
 *  This file is part of nymea:app.                                       *
 *                                                                         *
 *  nymea:app is free software: you can redistribute it and/or modify     *
 *  it under the terms of the GNU General Public License as published by   *
 *  the Free Software Foundation, version 3 of the License.                *
 *                                                                         *
 *  nymea:app is distributed in the hope that it will be useful,          *
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of         *
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the           *
 *  GNU General Public License for more details.                           *
 *                                                                         *
 *  You should have received a copy of the GNU General Public License      *
 *  along with nymea:app. If not, see <http://www.gnu.org/licenses/>.     *
 *                                                                         *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#include "nymeahosts.h"
#include "connection/discovery/nymeadiscovery.h"
#include "nymeahost.h"
#include "connection/nymeaconnection.h"
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
        qWarning() << "Cannot remove NymeaHost" << host << "as its nit in the model";
        return;
    }
    beginRemoveRows(QModelIndex(), idx, idx);
    m_hosts.takeAt(idx);
    endRemoveRows();
    emit hostRemoved(host);
    emit countChanged();
}

NymeaHost *NymeaHosts::createHost(const QString &name, const QUrl &url, Connection::BearerType bearerType)
{
    NymeaHost *host = new NymeaHost(this);
    host->setName(name);
    Connection *connection = new Connection(url, bearerType, false, url.toString(), host);
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

NymeaHostsFilterModel::NymeaHostsFilterModel(QObject *parent):
    QSortFilterProxyModel(parent)
{

}

NymeaDiscovery *NymeaHostsFilterModel::discovery() const
{
    return m_nymeaDiscovery;
}

void NymeaHostsFilterModel::setDiscovery(NymeaDiscovery *discovery)
{
    if (m_nymeaDiscovery != discovery) {
        m_nymeaDiscovery = discovery;
        setSourceModel(discovery->nymeaHosts());
        emit discoveryChanged();

        connect(discovery->nymeaHosts(), &NymeaHosts::hostChanged, this, [this](){
//            qDebug() << "Host Changed!";
            invalidateFilter();
            emit countChanged();
        });

        emit countChanged();
    }
}

NymeaConnection *NymeaHostsFilterModel::nymeaConnection() const
{
    return m_nymeaConnection;
}

void NymeaHostsFilterModel::setNymeaConnection(NymeaConnection *nymeaConnection)
{
    if (m_nymeaConnection != nymeaConnection) {
        m_nymeaConnection = nymeaConnection;
        emit nymeaConnectionChanged();

        connect(m_nymeaConnection, &NymeaConnection::availableBearerTypesChanged, this, [this](){
//            qDebug() << "Bearer Types Changed!";
            invalidateFilter();
            emit countChanged();
        });

        invalidateFilter();
        emit countChanged();
    }
}

bool NymeaHostsFilterModel::showUnreachableBearers() const
{
    return m_showUneachableBearers;
}

void NymeaHostsFilterModel::setShowUnreachableBearers(bool showUnreachableBearers)
{
    if (m_showUneachableBearers != showUnreachableBearers) {
        m_showUneachableBearers = showUnreachableBearers;
        emit showUnreachableBearersChanged();
        invalidateFilter();
        emit countChanged();
    }
}

NymeaHost *NymeaHostsFilterModel::get(int index) const
{
    return m_nymeaDiscovery->nymeaHosts()->get(mapToSource(this->index(index, 0)).row());
}

bool NymeaHostsFilterModel::filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const
{
    Q_UNUSED(sourceParent)
    NymeaHost *host = m_nymeaDiscovery->nymeaHosts()->get(sourceRow);
    if (m_nymeaConnection && !m_showUneachableBearers) {
        bool hasReachableConnection = false;
        for (int i = 0; i < host->connections()->rowCount(); i++) {
//            qDebug() << "checking host for available bearer" << host->name() << host->connections()->get(i)->url();
            if (m_nymeaConnection->availableBearerTypes().testFlag(host->connections()->get(i)->bearerType())) {
                hasReachableConnection = true;
                break;
            }
        }
        if (!hasReachableConnection) {
            return false;
        }
    }
    return true;
}

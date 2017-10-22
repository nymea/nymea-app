/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *                                                                         *
 *  Copyright (C) 2015 Simon Stuerz <stuerz.simon@gmail.com>               *
 *                                                                         *
 *  This file is part of guh-ubuntu.                                       *
 *                                                                         *
 *  guh-ubuntu is free software: you can redistribute it and/or modify     *
 *  it under the terms of the GNU General Public License as published by   *
 *  the Free Software Foundation, version 3 of the License.                *
 *                                                                         *
 *  guh-ubuntu is distributed in the hope that it will be useful,          *
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of         *
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the           *
 *  GNU General Public License for more details.                           *
 *                                                                         *
 *  You should have received a copy of the GNU General Public License      *
 *  along with guh-ubuntu. If not, see <http://www.gnu.org/licenses/>.     *
 *                                                                         *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#include "guhhosts.h"

#include <QUuid>
#include <QDebug>
#include <QSettings>

GuhHosts::GuhHosts(QObject *parent) :
    QAbstractListModel(parent)
{
    beginResetModel();
    QSettings settings;
    qDebug() << "Connections: loading connections " << settings.fileName();
    settings.beginGroup("Connections");
    foreach (const QString &uuid, settings.childGroups()) {
        settings.beginGroup(uuid);
        GuhHost *host = new GuhHost(this);
        host->setName(settings.value("name").toString());
        host->setHostAddress(settings.value("hostAddress").toString());
        host->setWebSocketUrl(settings.value("webSocketUrl").toString());
        host->setUuid(QUuid(uuid));
        qDebug() << "    " << host->webSocketUrl();
        m_hosts.append(host);
        settings.endGroup();
    }

    settings.endGroup();
    endResetModel();
}

GuhHost *GuhHosts::get(const QString &webSocketUrl)
{
    foreach (GuhHost *host, m_hosts) {
        if (host->webSocketUrl() == webSocketUrl) {
            return host;
        }
    }
    return nullptr;
}

QList<GuhHost *> GuhHosts::hosts()
{
    return m_hosts;
}

int GuhHosts::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return m_hosts.count();
}

QVariant GuhHosts::data(const QModelIndex &index, int role) const
{
    if (index.row() < 0 || index.row() >= m_hosts.count())
        return QVariant();

    GuhHost *host = m_hosts.at(index.row());
    if (role == NameRole) {
        return host->name();
    } else if (role == HostAddressRole) {
        return host->hostAddress();
    } else if (role == WebSocketUrlRole) {
        return host->webSocketUrl();
    }
    return QVariant();
}

void GuhHosts::addHost(const QString &name, const QString &hostAddress, const QString &webSocketUrl)
{
    // check if we allready have added this connection
    foreach (GuhHost *host, m_hosts) {
        if (host->webSocketUrl() == webSocketUrl) {
            return;
        }
    }

    GuhHost *host = new GuhHost(this);
    host->setName(name);
    host->setHostAddress(hostAddress);
    host->setWebSocketUrl(webSocketUrl);
    host->setUuid(QUuid::createUuid());

    qDebug() << "GuhHosts: add connection" << host->webSocketUrl();
    beginInsertRows(QModelIndex(), m_hosts.count(), m_hosts.count());
    m_hosts.append(host);
    endInsertRows();

    QSettings settings;
    settings.beginGroup("Connections");
    settings.beginGroup(host->uuid().toString());
    settings.setValue("name", name);
    settings.setValue("hostAddress", hostAddress);
    settings.setValue("webSocketUrl", webSocketUrl);
    settings.endGroup();
    settings.endGroup();
    qDebug() << "Connections: saved connection" << settings.fileName();
}

void GuhHosts::removeHost(GuhHost *host)
{
    int index = m_hosts.indexOf(host);
    beginRemoveRows(QModelIndex(), index, index);
    qDebug() << "Connections: removed connection" << host->webSocketUrl();
    m_hosts.removeAt(index);

    QSettings settings;
    settings.beginGroup("Connections");
    settings.remove(host->uuid().toString());
    settings.endGroup();
    host->deleteLater();
    endRemoveRows();
}

void GuhHosts::clearModel()
{
    beginResetModel();
    qDebug() << "GuhHosts: delete all hosts";
    qDeleteAll(m_hosts);
    m_hosts.clear();
    endResetModel();
}

QHash<int, QByteArray> GuhHosts::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[NameRole] = "name";
    roles[HostAddressRole] = "hostAddress";
    roles[WebSocketUrlRole] = "webSocketUrl";
    return roles;
}

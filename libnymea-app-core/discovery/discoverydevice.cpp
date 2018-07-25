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
    QObject(parent)
{
    m_portConfigs = new PortConfigs(this);
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

PortConfigs* DiscoveryDevice::portConfigs() const
{
    return m_portConfigs;
}

QString DiscoveryDevice::toUrl(int portConfigIndex)
{
    PortConfig *pc = m_portConfigs->get(portConfigIndex);
    if (!pc) {
        qWarning() << "No portconfig for index" << portConfigIndex;
        return QString();
    }
    QString ret = pc->protocol() == PortConfig::ProtocolNymeaRpc ? "nymea" : "ws";
    ret += pc->sslEnabled() ? "s" : "";
    ret += "://";
    if (pc->hostAddress().protocol() == QAbstractSocket::IPv4Protocol) {
        ret += pc->hostAddress().toString();
    } else if (pc->hostAddress().protocol() == QAbstractSocket::IPv6Protocol){
        ret += "[" + pc->hostAddress().toString() + "]";
    }
    ret += ":";
    ret += QString::number(pc->port());
    return ret;
}

PortConfigs::PortConfigs(QObject *parent): QAbstractListModel(parent)
{

}

int PortConfigs::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return m_portConfigs.count();
}

QVariant PortConfigs::data(const QModelIndex &index, int role) const
{
    switch (role) {
    case RoleAddress:
        return m_portConfigs.at(index.row())->hostAddressString();
    case RolePort:
        return m_portConfigs.at(index.row())->port();
    case RoleProtocol:
        return m_portConfigs.at(index.row())->protocol();
    case RoleSSLEnabled:
        return m_portConfigs.at(index.row())->sslEnabled();
    }
    return QVariant();
}

PortConfig *PortConfigs::find(int port)
{
    foreach (PortConfig* pc, m_portConfigs) {
        if (pc->port() == port) {
            return pc;
        }
    }
    return nullptr;
}

void PortConfigs::insert(PortConfig *portConfig)
{
    portConfig->setParent(this);
    beginInsertRows(QModelIndex(), m_portConfigs.count(), m_portConfigs.count());
    m_portConfigs.append(portConfig);
    endInsertRows();
    emit countChanged();
}

PortConfig* PortConfigs::get(int index) const
{
    if (index < 0 || index >= m_portConfigs.count())
        return nullptr;

    return m_portConfigs.at(index);
}

QHash<int, QByteArray> PortConfigs::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles.insert(RoleAddress, "address");
    roles.insert(RolePort, "port");
    roles.insert(RoleProtocol, "protocol");
    roles.insert(RoleSSLEnabled, "sslEnabled");
    return roles;
}

PortConfig::PortConfig(const QHostAddress &hostAddress, int port, QObject *parent):
    QObject(parent),
    m_port(port),
    m_hostAddress(hostAddress)
{

}

int PortConfig::port() const
{
    return m_port;
}

PortConfig::Protocol PortConfig::protocol() const
{
    return m_protocol;
}

void PortConfig::setProtocol(PortConfig::Protocol protocol)
{
    if (m_protocol != protocol) {
        m_protocol = protocol;
        emit protocolChanged();
    }
}

QHostAddress PortConfig::hostAddress() const
{
    return m_hostAddress;
}

QString PortConfig::hostAddressString() const
{
    if (m_hostAddress.protocol() == QAbstractSocket::IPv6Protocol){
        return "[" + m_hostAddress.toString() + "]";
    }

    return m_hostAddress.toString();
}

bool PortConfig::sslEnabled() const
{
    return m_sslEnabled;
}

void PortConfig::setSslEnabled(bool sslEnabled)
{
    if (m_sslEnabled != sslEnabled) {
        m_sslEnabled = sslEnabled;
        emit sslEnabledChanged();
    }
}

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

#include "serverconfiguration.h"

ServerConfiguration::ServerConfiguration(const QString &id, const QString &address, int port, bool authEnabled, bool sslEnabled, QObject *parent):
    QObject(parent),
    m_id(id),
    m_hostAddress(address),
    m_port(port),
    m_authEnabled(authEnabled),
    m_sslEnabled(sslEnabled)
{

}

ServerConfiguration::~ServerConfiguration()
{
}

QString ServerConfiguration::id() const
{
    return m_id;
}

QString ServerConfiguration::address() const
{
    return m_hostAddress;
}

void ServerConfiguration::setAddress(const QString &address)
{
    if (m_hostAddress != address) {
        m_hostAddress = address;
        emit addressChanged();
    }
}

int ServerConfiguration::port() const
{
    return m_port;
}

void ServerConfiguration::setPort(int port)
{
    if (m_port != port) {
        m_port = port;
        emit portChanged();
    }
}

bool ServerConfiguration::authenticationEnabled() const
{
    return m_authEnabled;
}

void ServerConfiguration::setAuthenticationEnabled(bool authenticationEnabled)
{
    if (m_authEnabled != authenticationEnabled) {
        m_authEnabled = authenticationEnabled;
        emit authenticationEnabledChanged();
    }
}

bool ServerConfiguration::sslEnabled() const
{
    return m_sslEnabled;
}

void ServerConfiguration::setSslEnabled(bool sslEnabled)
{
    if (m_sslEnabled != sslEnabled) {
        m_sslEnabled = sslEnabled;
        emit sslEnabledChanged();
    }
}

ServerConfiguration *ServerConfiguration::clone() const
{
    ServerConfiguration *ret = new ServerConfiguration(m_id, m_hostAddress, m_port, m_authEnabled, m_sslEnabled);
    return ret;
}

QString WebServerConfiguration::publicFolder() const
{
    return m_publicFolder;
}

void WebServerConfiguration::setPublicFolder(const QString &publicFolder)
{
    if (m_publicFolder != publicFolder) {
        m_publicFolder = publicFolder;
        emit publicFolderChanged();
    }
}

ServerConfiguration *WebServerConfiguration::clone() const
{
    WebServerConfiguration *ret = new WebServerConfiguration(id(), address(), port(), authenticationEnabled(), sslEnabled());
    ret->setPublicFolder(m_publicFolder);
    return ret;
}

bool TunnelProxyServerConfiguration::ignoreSslErrors() const
{
    return m_ignoreSslErrors;
}

void TunnelProxyServerConfiguration::setIgnoreSslErrors(bool ignoreSslErrors)
{
    if (m_ignoreSslErrors != ignoreSslErrors) {
        m_ignoreSslErrors = ignoreSslErrors;
        emit ignoreSslErrorsChanged();
    }
}

ServerConfiguration *TunnelProxyServerConfiguration::clone() const
{
    TunnelProxyServerConfiguration *ret = new TunnelProxyServerConfiguration(id(), address(), port(), authenticationEnabled(), sslEnabled(), ignoreSslErrors());
    return ret;
}

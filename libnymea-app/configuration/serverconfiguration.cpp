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
    TunnelProxyServerConfiguration *ret = new TunnelProxyServerConfiguration(id(), address(), port(), authenticationEnabled(), ignoreSslErrors());
    return ret;
}

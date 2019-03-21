#include "serverconfiguration.h"

ServerConfiguration::ServerConfiguration(const QString &id, const QHostAddress &address, int port, bool authEnabled, bool sslEnabled, QObject *parent):
    QObject(parent),
    m_id(id),
    m_hostAddress(address),
    m_port(port),
    m_authEnabled(authEnabled),
    m_sslEnabled(sslEnabled)
{

}

QString ServerConfiguration::id() const
{
    return m_id;
}

QString ServerConfiguration::address() const
{
    return m_hostAddress.toString();
}

void ServerConfiguration::setAddress(const QString &address)
{
    if (m_hostAddress != QHostAddress(address)) {
        m_hostAddress = QHostAddress(address);
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
    WebServerConfiguration *ret = new WebServerConfiguration(id(), QHostAddress(address()), port(), authenticationEnabled(), sslEnabled());
    ret->setPublicFolder(m_publicFolder);
    return ret;
}

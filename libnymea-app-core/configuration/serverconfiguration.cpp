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

int ServerConfiguration::port() const
{
    return m_port;
}

bool ServerConfiguration::authenticationEnabled() const
{
    return m_authEnabled;
}

bool ServerConfiguration::sslEnabled() const
{
    return m_sslEnabled;
}

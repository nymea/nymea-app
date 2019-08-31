#include "zeroconfdiscovery.h"

#include <QUuid>

#include "../nymeahost.h"

ZeroconfDiscovery::ZeroconfDiscovery(NymeaHosts *nymeaHosts, QObject *parent) :
    QObject(parent),
    m_nymeaHosts(nymeaHosts)
{
#ifdef WITH_ZEROCONF
    // NOTE: There seem to be too many issues in QtZeroConf and IPv6.
    // See https://github.com/jbagg/QtZeroConf/issues/22
    // Limiting this to IPv4 for now...

    m_zeroconfJsonRPC = new QZeroConf(this);
    connect(m_zeroconfJsonRPC, &QZeroConf::serviceAdded, this, &ZeroconfDiscovery::serviceEntryAdded);
    connect(m_zeroconfJsonRPC, &QZeroConf::serviceUpdated, this, &ZeroconfDiscovery::serviceEntryAdded);
    connect(m_zeroconfJsonRPC, &QZeroConf::serviceRemoved, this, &ZeroconfDiscovery::serviceEntryRemoved);
    m_zeroconfJsonRPC->startBrowser("_jsonrpc._tcp", QAbstractSocket::IPv4Protocol);
    qDebug() << "ZeroConf: Created service browser for _jsonrpc._tcp:" << m_zeroconfJsonRPC->browserExists();

    m_zeroconfWebSocket = new QZeroConf(this);
    connect(m_zeroconfWebSocket, &QZeroConf::serviceAdded, this, &ZeroconfDiscovery::serviceEntryAdded);
    connect(m_zeroconfWebSocket, &QZeroConf::serviceUpdated, this, &ZeroconfDiscovery::serviceEntryAdded);
    connect(m_zeroconfWebSocket, &QZeroConf::serviceRemoved, this, &ZeroconfDiscovery::serviceEntryRemoved);
    m_zeroconfWebSocket->startBrowser("_ws._tcp", QAbstractSocket::IPv4Protocol);
    qDebug() << "ZeroConf: Created service browser for _ws._tcp:" << m_zeroconfWebSocket->browserExists();
#else
    qDebug() << "Zeroconf support not compiled in. Zeroconf will not be available.";
#endif
}

ZeroconfDiscovery::~ZeroconfDiscovery()
{
    qDebug() << "ZeroConf: Shutting down service browsers";
}

bool ZeroconfDiscovery::available() const
{
#ifdef WITH_ZEROCONF
    return m_zeroconfJsonRPC->browserExists() || m_zeroconfWebSocket->browserExists();
#else
    return false;
#endif
}

bool ZeroconfDiscovery::discovering() const
{
    return available();
}

#ifdef WITH_ZEROCONF
void ZeroconfDiscovery::serviceEntryAdded(const QZeroConfService &entry)
{
    if (!entry->name().startsWith("nymea")) {
        // Skip non-nymea services altogether
        qDebug() << "Skipping Avahi entry:" << entry << entry->ip() << entry->txt() << entry->type();
        return;
    }
    if (entry->ip().isNull()) {
        // Skip entries that don't have an ip address at all for some reason
        qDebug() << "Skipping Avahi entry:" << entry << entry->ip() << entry->txt() << entry->type();
        return;
    }
    if (entry->ip().toString().startsWith("fe80")) {
        // Skip link-local-IPv6 results
        qDebug() << "Skipping Avahi entry:" << entry << entry->ip() << entry->txt() << entry->type();
        return;
    }

//    qDebug() << "zeroconf service discovered" << entry->type() << entry->name() << " IP:" << entry->ip().toString() << entry->txt();

    QString uuid;
    bool sslEnabled = false;
    QString serverName;
    QString version;
    foreach (const QByteArray &key, entry->txt().keys()) {
        QPair<QString, QString> txtRecord = qMakePair<QString, QString>(key, entry->txt().value(key));
        if (!sslEnabled && txtRecord.first == "sslEnabled") {
            sslEnabled = (txtRecord.second == "true");
        }
        if (txtRecord.first == "uuid") {
            uuid = txtRecord.second;
        }
        if (txtRecord.first == "name") {
            serverName = txtRecord.second;
        }
        if (txtRecord.first == "serverVersion") {
            version = txtRecord.second;
        }
    }
//    qDebug() << "avahi service entry added" << serverName << uuid << sslEnabled;


    NymeaHost* host = m_nymeaHosts->find(uuid);
    if (!host) {
        host = new NymeaHost(m_nymeaHosts);
        host->setUuid(uuid);
//        qDebug() << "ZeroConf: Adding new host:" << serverName << uuid;
        m_nymeaHosts->addHost(host);
    }
    host->setName(serverName);
    host->setVersion(version);
    QUrl url;
    // NOTE: On linux this is "_jsonrpc._tcp" while on apple systems this is "_jsonrpc._tcp."
    if (entry->type().startsWith("_jsonrpc._tcp")) {
        url.setScheme(sslEnabled ? "nymeas" : "nymea");
    } else if (entry->type().startsWith("_ws._tcp")) {
        url.setScheme(sslEnabled ? "wss" : "ws");
    }
    url.setHost(entry->ip().toString());
    url.setPort(entry->port());
    Connection *connection = host->connections()->find(url);
    if (!connection) {
//        qDebug() << "Zeroconf: Adding new connection to host:" << host->name() << url.toString();
        QString displayName = QString("%1:%2").arg(url.host()).arg(url.port());
        Connection::BearerType bearerType = QHostAddress(url.host()).isLoopback() ? Connection::BearerTypeLoopback : Connection::BearerTypeLan;
        connection = new Connection(url, bearerType, sslEnabled, displayName);
        connection->setOnline(true);
        host->connections()->addConnection(connection);
    } else {
//        qDebug() << "Zeroconf: Setting connection online:" << host->name() << url.toString();
        connection->setOnline(true);
    }
}

void ZeroconfDiscovery::serviceEntryRemoved(const QZeroConfService &entry)
{
    if (!entry->name().startsWith("nymea") || entry->ip().isNull()) {
        return;
    }

    QString uuid;
    bool sslEnabled = false;
    QString serverName;
    QString version;
    foreach (const QByteArray &key, entry->txt().keys()) {
        QPair<QString, QString> txtRecord = qMakePair<QString, QString>(key, entry->txt().value(key));
        if (!sslEnabled && txtRecord.first == "sslEnabled") {
            sslEnabled = (txtRecord.second == "true");
        }
        if (txtRecord.first == "uuid") {
            uuid = txtRecord.second;
        }
        if (txtRecord.first == "name") {
            serverName = txtRecord.second;
        }
        if (txtRecord.first == "serverVersion") {
            version = txtRecord.second;
        }
    }

//    qDebug() << "Zeroconf: Service entry removed" << entry->name();

    NymeaHost* host = m_nymeaHosts->find(uuid);
    if (!host) {
        // Nothing to do...
        return;
    }

    QUrl url;
    if (entry->type() == "_jsonrpc._tcp") {
        url.setScheme(sslEnabled ? "nymeas" : "nymea");
    } else {
        url.setScheme(sslEnabled ? "wss" : "ws");
    }
    url.setHost(entry->ip().toString());
    url.setPort(entry->port());
    Connection *connection = host->connections()->find(url);
    if (!connection){
        // Connection url not found...
        return;
    }

//    qDebug() << "Zeroconf: Setting connection offline:" << host->name() << url.toString();
    connection->setOnline(false);
}
#endif

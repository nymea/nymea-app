#include "zeroconfdiscovery.h"

#include <QUuid>

#include "discoverydevice.h"

ZeroconfDiscovery::ZeroconfDiscovery(DiscoveryModel *discoveryModel, QObject *parent) :
    QObject(parent),
    m_discoveryModel(discoveryModel)
{
#ifdef WITH_ZEROCONF
    m_zeroconfJsonRPC = new QZeroConf(this);
    connect(m_zeroconfJsonRPC, &QZeroConf::serviceAdded, this, &ZeroconfDiscovery::serviceEntryAdded);
    connect(m_zeroconfJsonRPC, &QZeroConf::serviceUpdated, this, &ZeroconfDiscovery::serviceEntryAdded);
    connect(m_zeroconfJsonRPC, &QZeroConf::serviceRemoved, this, &ZeroconfDiscovery::serviceEntryRemoved);
    m_zeroconfJsonRPC->startBrowser("_jsonrpc._tcp", QAbstractSocket::AnyIPProtocol);
    qDebug() << "ZeroConf: Created service browser for _jsonrpc._tcp:" << m_zeroconfJsonRPC->browserExists();

    m_zeroconfWebSocket = new QZeroConf(this);
    connect(m_zeroconfWebSocket, &QZeroConf::serviceAdded, this, &ZeroconfDiscovery::serviceEntryAdded);
    connect(m_zeroconfWebSocket, &QZeroConf::serviceUpdated, this, &ZeroconfDiscovery::serviceEntryAdded);
    connect(m_zeroconfWebSocket, &QZeroConf::serviceRemoved, this, &ZeroconfDiscovery::serviceEntryRemoved);
    m_zeroconfWebSocket->startBrowser("_ws._tcp", QAbstractSocket::AnyIPProtocol);
    qDebug() << "TeroConf: Created service browser for _ws._tcp:" << m_zeroconfWebSocket->browserExists();
#else
    qDebug() << "Zeroconf support not compiled in. Zeroconf will not be available.";
#endif
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
    if (!entry.name().startsWith("nymea")) {
        // Skip non-nymea services altogether
        return;
    }
    if (entry.ip().isNull() && entry.ipv6().isNull()) {
        // Skip entries that don't have an ip address at all for some reason
        return;
    }
    if (entry.ipv6().toString().startsWith("fe80")) {
        // Skip link-local IPv6 addresses
        return;
    }

//    qDebug() << "zeroconf service discovered" << entry << entry.ip() << entry.ipv6() << entry.txt() << entry.type();

    QString uuid;
    bool sslEnabled = false;
    QString serverName;
    QString version;
    foreach (const QByteArray &key, entry.txt().keys()) {
        QPair<QString, QString> txtRecord = qMakePair<QString, QString>(key, entry.txt().value(key));
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


    DiscoveryDevice* device = m_discoveryModel->find(uuid);
    if (!device) {
        device = new DiscoveryDevice(m_discoveryModel);
        device->setUuid(uuid);
        qDebug() << "ZeroConf: Adding new host:" << serverName << uuid;
        m_discoveryModel->addDevice(device);
    }
    device->setName(serverName);
    device->setVersion(version);
    QUrl url;
    if (entry.type() == "_jsonrpc._tcp") {
        url.setScheme(sslEnabled ? "nymeas" : "nymea");
    } else {
        url.setScheme(sslEnabled ? "wss" : "ws");
    }
    url.setHost(!entry.ip().isNull() ? entry.ip().toString() : entry.ipv6().toString());
    url.setPort(entry.port());
    if (!device->connections()->find(url)){
        qDebug() << "Zeroconf: Adding new connection to host:" << device->name() << url.toString();
        QString displayName = QString("%1:%2").arg(url.host()).arg(url.port());
        Connection *connection = new Connection(url, Connection::BearerTypeWifi, sslEnabled, displayName);
        connection->setOnline(true);
        device->connections()->addConnection(connection);
    }
}

void ZeroconfDiscovery::serviceEntryRemoved(const QZeroConfService &entry)
{
    if (!entry.name().startsWith("nymea") || (entry.ip().isNull() && entry.ipv6().isNull())) {
        return;
    }

    QString uuid;
    bool sslEnabled = false;
    QString serverName;
    QString version;
    foreach (const QByteArray &key, entry.txt().keys()) {
        QPair<QString, QString> txtRecord = qMakePair<QString, QString>(key, entry.txt().value(key));
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

//    qDebug() << "Zeroconf: Service entry removed" << entry.name();

    DiscoveryDevice* device = m_discoveryModel->find(uuid);
    if (!device) {
        // Nothing to do...
        return;
    }

    QUrl url;
    if (entry.type() == "_jsonrpc._tcp") {
        url.setScheme(sslEnabled ? "nymeas" : "nymea");
    } else {
        url.setScheme(sslEnabled ? "wss" : "ws");
    }
    url.setHost(!entry.ip().isNull() ? entry.ip().toString() : entry.ipv6().toString());
    url.setPort(entry.port());
    Connection *connection = device->connections()->find(url);
    if (!connection){
        // Connection url not found...
        return;
    }

    // Ok, now we need to remove it
    device->connections()->removeConnection(connection);

    // And if there aren't any connections left, remove the entire device
    if (device->connections()->rowCount() == 0) {
        qDebug() << "Zeroconf: Removing connection from host:" << device->name() << url.toString();
        m_discoveryModel->removeDevice(device);
    }
}
#endif

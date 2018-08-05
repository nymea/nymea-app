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
    m_zeroconfJsonRPC->startBrowser("_jsonrpc._tcp", QAbstractSocket::AnyIPProtocol);
    qDebug() << "ZeroConf: Created service browser for _jsonrpc._tcp:" << m_zeroconfJsonRPC->browserExists();

    m_zeroconfWebSocket = new QZeroConf(this);
    connect(m_zeroconfWebSocket, &QZeroConf::serviceAdded, this, &ZeroconfDiscovery::serviceEntryAdded);
    connect(m_zeroconfWebSocket, &QZeroConf::serviceUpdated, this, &ZeroconfDiscovery::serviceEntryAdded);
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
    if (!entry.name().startsWith("nymea") || (entry.ip().isNull() && entry.ipv6().isNull())) {
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
//    entry
    url.setHost(!entry.ip().isNull() ? entry.ip().toString() : entry.ipv6().toString());
    url.setPort(entry.port());
    if (!device->connections()->find(url)){
        qDebug() << "Zeroconf: Adding new connection to host:" << device->name() << url.toString();
        QString displayName = QString("%1:%2").arg(url.host()).arg(url.port());
        Connection *connection = new Connection(url, Connection::BearerTypeWifi, sslEnabled, displayName);
        device->connections()->addConnection(connection);
    }
}
#endif

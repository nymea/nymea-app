#include "zeroconfdiscovery.h"

#include <QUuid>


ZeroconfDiscovery::ZeroconfDiscovery(DiscoveryModel *discoveryModel, QObject *parent) :
    QObject(parent),
    m_discoveryModel(discoveryModel)
{
#ifdef WITH_ZEROCONF
    m_zeroconfJsonRPC = new QZeroConf(this);
    connect(m_zeroconfJsonRPC, &QZeroConf::serviceAdded, this, &ZeroconfDiscovery::serviceEntryAdded);
    connect(m_zeroconfJsonRPC, &QZeroConf::serviceUpdated, this, &ZeroconfDiscovery::serviceEntryAdded);
    m_zeroconfJsonRPC->startBrowser("_jsonrpc._tcp");
    qDebug() << "created service browser for _jsonrpc._tcp:" << m_zeroconfJsonRPC->browserExists();

    m_zeroconfWebSocket = new QZeroConf(this);
    connect(m_zeroconfWebSocket, &QZeroConf::serviceAdded, this, &ZeroconfDiscovery::serviceEntryAdded);
    connect(m_zeroconfWebSocket, &QZeroConf::serviceUpdated, this, &ZeroconfDiscovery::serviceEntryAdded);
    m_zeroconfWebSocket->startBrowser("_ws._tcp");
    qDebug() << "created service browser for _ws._tcp:" << m_zeroconfWebSocket->browserExists();
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
    if (!entry.name().startsWith("nymea") || entry.ip().isNull()) {
        return;
    }
    qDebug() << "zeroconf service discovered" << entry << entry.txt() << entry.type();

    QString uuid;
    bool sslEnabled = false;
    QString serverName;
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
    }
    qDebug() << "avahi service entry added" << serverName << uuid << sslEnabled;

    DiscoveryDevice dev = m_discoveryModel->find(entry.ip());
    if (dev.uuid() == uuid && dev.nymeaRpcUrl().startsWith("nymeas") && !sslEnabled) {
        // We already have this host and with a more secure configuration... skip this one...
        return;
    }
    qDebug() << "Adding new found entry:" << entry.name() << entry.ip();
    dev.setUuid(uuid);
    dev.setHostAddress(entry.ip());
    dev.setPort(entry.port());
    dev.setFriendlyName(serverName + " on " + entry.ip().toString());
    QHostAddress address = entry.ip();
    QString addressString;
    if (address.protocol() == QAbstractSocket::IPv6Protocol) {
        addressString = "[" + address.toString() + "]";
    } else {
        addressString = address.toString();
    }
    if (entry.type() == "_ws._tcp") {
        dev.setWebSocketUrl(QString("%1://%2:%3").arg(sslEnabled ? "wss" : "ws").arg(addressString).arg(entry.port()));
    } else {
        dev.setNymeaRpcUrl(QString("%1://%2:%3").arg(sslEnabled ? "nymeas" : "nymea").arg(addressString).arg(entry.port()));
    }
    m_discoveryModel->addDevice(dev);

//    DiscoveryDevice *dev = new DiscoveryDevice();
//    dev->setFriendlyName(entry.hostName());
}
#endif

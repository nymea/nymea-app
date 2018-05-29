#include "zeroconfdiscovery.h"

#include <QUuid>


ZeroconfDiscovery::ZeroconfDiscovery(DiscoveryModel *discoveryModel, QObject *parent) :
    QObject(parent),
    m_discoveryModel(discoveryModel)
{
#ifdef WITH_AVAHI
    m_serviceBrowser = new QtAvahiServiceBrowser(this);
    connect(m_serviceBrowser, &QtAvahiServiceBrowser::serviceEntryAdded, this, &ZeroconfDiscovery::serviceEntryAdded);
    m_serviceBrowser->enable();
#endif
}

bool ZeroconfDiscovery::available() const
{
#ifdef WITH_AVAHI
    return true;
#else
    return false;
#endif
}

bool ZeroconfDiscovery::discovering() const
{
    return true;
}

#ifdef WITH_AVAHI
void ZeroconfDiscovery::serviceEntryAdded(const AvahiServiceEntry &entry)
{
    if (!entry.name().startsWith("nymea") || entry.serviceType() != "_jsonrpc._tcp" || entry.hostAddress().protocol() == QAbstractSocket::IPv6Protocol) {
        return;
    }
    qDebug() << "avahi service entry added" << entry.name() << entry.hostAddress() << entry.port() << entry.txt() << entry.serviceType();

    QString uuid;
    bool sslEnabled = false;
    QString serverName;
    foreach (const QString &txt, entry.txt()) {
        QPair<QString, QString> txtRecord = qMakePair<QString, QString>(txt.split("=").first(), txt.split("=").at(1));
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

    DiscoveryDevice dev = m_discoveryModel->find(entry.hostAddress());
    if (dev.uuid() == uuid && dev.nymeaRpcUrl().startsWith("nymeas") && !sslEnabled) {
        // We already have this host and with a more secure configuration... skip this one...
        return;
    }
    dev.setUuid(uuid);
    dev.setHostAddress(entry.hostAddress());
    dev.setPort(entry.port());
    dev.setFriendlyName(serverName + " on " + entry.hostName());
    QHostAddress address = entry.hostAddress();
    QString addressString;
    if (address.protocol() == QAbstractSocket::IPv6Protocol) {
        addressString = "[" + address.toString() + "]";
    } else {
        addressString = address.toString();
    }
    dev.setNymeaRpcUrl(QString("%1://%2:%3").arg(sslEnabled ? "nymeas" : "nymea").arg(addressString).arg(entry.port()));
    m_discoveryModel->addDevice(dev);

//    DiscoveryDevice *dev = new DiscoveryDevice();
//    dev->setFriendlyName(entry.hostName());
}
#endif

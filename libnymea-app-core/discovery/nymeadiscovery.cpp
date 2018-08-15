#include "nymeadiscovery.h"
#include "engine.h"
#include "upnpdiscovery.h"
#include "zeroconfdiscovery.h"
#include "bluetoothservicediscovery.h"
#include "connection/awsclient.h"

#include <QUuid>
#include <QBluetoothUuid>
#include <QUrlQuery>

NymeaDiscovery::NymeaDiscovery(QObject *parent) : QObject(parent)
{
    m_discoveryModel = new DiscoveryModel(this);

    m_upnp = new UpnpDiscovery(m_discoveryModel, this);
    m_zeroConf = new ZeroconfDiscovery(m_discoveryModel, this);

#ifndef Q_OS_IOS
    m_bluetooth = new BluetoothServiceDiscovery(m_discoveryModel, this);
#endif

    connect(Engine::instance()->awsClient(), &AWSClient::devicesFetched, this, &NymeaDiscovery::cloudDevicesFetched);
}

bool NymeaDiscovery::discovering() const
{
    return m_discovering;
}

void NymeaDiscovery::setDiscovering(bool discovering)
{
    if (m_discovering == discovering)
        return;

    m_discovering = discovering;
    // For zeroconf we'll ignore it as zeroconf doesn't do active discovery but just listens for changes in the net all the time
    if (discovering) {
        m_upnp->discover();
        if (m_bluetooth) {
            m_bluetooth->discover();
        }
        if (Engine::instance()->awsClient()->isLoggedIn()) {
            Engine::instance()->awsClient()->fetchDevices();
        }
    } else {
        m_upnp->stopDiscovery();
        if (m_bluetooth) {
            m_bluetooth->stopDiscovery();
        }
    }

    emit discoveringChanged();
}

DiscoveryModel *NymeaDiscovery::discoveryModel() const
{
    return m_discoveryModel;
}

void NymeaDiscovery::cloudDevicesFetched(const QList<AWSDevice> &devices)
{
    qDebug() << "Cloud devices fetched";
    foreach (const AWSDevice &d, devices) {
        DiscoveryDevice *device = m_discoveryModel->find(d.id);
        if (!device) {
            device = new DiscoveryDevice();
            device->setUuid(d.id);
            device->setName(d.name);
            m_discoveryModel->addDevice(device);
        }
        QUrl url;
        url.setScheme("cloud");
        url.setHost(d.id);
        if (!device->connections()->find(url)) {
            Connection *conn = new Connection(url, Connection::BearerTypeCloud, true, d.id);
            device->connections()->addConnection(conn);
        }
    }
}

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

    m_cloudPollTimer.setInterval(5000);
    connect(&m_cloudPollTimer, &QTimer::timeout, this, [](){
        if (Engine::instance()->awsClient()->isLoggedIn()) {
            Engine::instance()->awsClient()->fetchDevices();
        }
    });
    connect(Engine::instance()->awsClient(), &AWSClient::devicesFetched, this, &NymeaDiscovery::syncCloudDevices);
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
    // If we have zeroconf skip upnp. ZeroConf will not do an active discovery and if it's available it'll always have good data
    if (!m_zeroConf->available()) {
        if (discovering) {
            m_upnp->discover();
        } else {
            m_upnp->stopDiscovery();
        }
    }
    if (discovering) {
        // If there's no Zeroconf, use UPnP instead
        if (!m_zeroConf->available()) {
            m_upnp->discover();
        }

        // Always start Bluetooth discovery if HW is available
        if (m_bluetooth) {
            m_bluetooth->discover();
        }

        // start polling cloud
        m_cloudPollTimer.start();
        // If we're logged in, poll right away
        if (Engine::instance()->awsClient()->isLoggedIn()) {
            syncCloudDevices();
            Engine::instance()->awsClient()->fetchDevices();
        }
    } else {
        if (!m_zeroConf->available()) {
            m_upnp->stopDiscovery();
        }

        if (m_bluetooth) {
            m_bluetooth->stopDiscovery();
        }

        m_cloudPollTimer.stop();
    }

    emit discoveringChanged();
}

DiscoveryModel *NymeaDiscovery::discoveryModel() const
{
    return m_discoveryModel;
}

void NymeaDiscovery::syncCloudDevices()
{
    qDebug() << "Cloud devices fetched";
    for (int i = 0; i < Engine::instance()->awsClient()->awsDevices()->rowCount(); i++) {
        AWSDevice *d = Engine::instance()->awsClient()->awsDevices()->get(i);
        DiscoveryDevice *device = m_discoveryModel->find(d->id());
        if (!device) {
            device = new DiscoveryDevice();
            device->setUuid(d->id());
            device->setName(d->name());
            m_discoveryModel->addDevice(device);
        }
        QUrl url;
        url.setScheme("cloud");
        url.setHost(d->id());
        Connection *conn = device->connections()->find(url);
        if (!conn) {
            conn = new Connection(url, Connection::BearerTypeCloud, true, d->id());
            device->connections()->addConnection(conn);
        }
        conn->setOnline(d->online());
    }

    QList<DiscoveryDevice*> devicesToRemove;
    for (int i = 0; i < m_discoveryModel->rowCount(); i++) {
        DiscoveryDevice *device = m_discoveryModel->get(i);
        for (int j = 0; j < device->connections()->rowCount(); j++) {
            if (device->connections()->get(j)->bearerType() == Connection::BearerTypeCloud) {
                if (Engine::instance()->awsClient()->awsDevices()->getDevice(device->uuid().toString()) == nullptr) {
                    device->connections()->removeConnection(j);
                    break;
                }
            }
        }
        if (device->connections()->rowCount() == 0) {
            devicesToRemove.append(device);
        }
    }
    while (!devicesToRemove.isEmpty()) {
        m_discoveryModel->removeDevice(devicesToRemove.takeFirst());
    }
}


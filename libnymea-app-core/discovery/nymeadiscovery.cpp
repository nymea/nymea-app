#include "nymeadiscovery.h"

#include "upnpdiscovery.h"
#include "zeroconfdiscovery.h"
#include "bluetoothservicediscovery.h"

#include <QUuid>
#include <QBluetoothUuid>

NymeaDiscovery::NymeaDiscovery(QObject *parent) : QObject(parent)
{
    m_discoveryModel = new DiscoveryModel(this);

    m_upnp = new UpnpDiscovery(m_discoveryModel, this);
    m_zeroConf = new ZeroconfDiscovery(m_discoveryModel, this);
    m_bluetooth = new BluetoothServiceDiscovery(m_discoveryModel, this);
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
        // Note: this is the nymea uuid
        m_bluetooth->discover();
    } else {
        m_upnp->stopDiscovery();
        m_bluetooth->stopDiscovery();
    }
    emit discoveringChanged();
}

DiscoveryModel *NymeaDiscovery::discoveryModel() const
{
    return m_discoveryModel;
}

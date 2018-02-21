#include "guhdiscovery.h"

#include "upnpdiscovery.h"
#include "zeroconfdiscovery.h"

GuhDiscovery::GuhDiscovery(QObject *parent) : QObject(parent)
{
    m_discoveryModel = new DiscoveryModel(this);

    m_upnp = new UpnpDiscovery(m_discoveryModel, this);
    m_zeroConf = new ZeroconfDiscovery(m_discoveryModel, this);
}

bool GuhDiscovery::discovering() const
{
    return m_discovering;
}

void GuhDiscovery::setDiscovering(bool discovering)
{
    if (m_discovering != discovering) {
        m_discovering = discovering;
        // For zeroconf we'll ignore it as zeroconf doesn't do active discovery but just listens for changes in the net all the time
        // If we don't have zeroconf available, start an active upnp discovery
        if (!m_zeroConf->available()) {
            if (discovering) {
                m_upnp->discover();
            } else {
                m_upnp->stopDiscovery();
            }
        }
        emit discoveringChanged();
    }
}

DiscoveryModel *GuhDiscovery::discoveryModel() const
{
    return m_discoveryModel;
}

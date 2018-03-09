#ifndef NYMEADISCOVERY_H
#define NYMEADISCOVERY_H

#include <QObject>

class DiscoveryModel;
class UpnpDiscovery;
class ZeroconfDiscovery;

class NymeaDiscovery : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool discovering READ discovering WRITE setDiscovering NOTIFY discoveringChanged)
    Q_PROPERTY(DiscoveryModel *discoveryModel READ discoveryModel CONSTANT)

public:
    explicit NymeaDiscovery(QObject *parent = nullptr);

    bool discovering() const;
    void setDiscovering(bool discovering);

    DiscoveryModel *discoveryModel() const;

signals:
    void discoveringChanged();

private:
    bool m_discovering = false;
    DiscoveryModel *m_discoveryModel = nullptr;

    UpnpDiscovery *m_upnp = nullptr;
    ZeroconfDiscovery *m_zeroConf = nullptr;
};

#endif // NYMEADISCOVERY_H

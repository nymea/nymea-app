#ifndef NYMEADISCOVERY_H
#define NYMEADISCOVERY_H

#include <QObject>
#include <QTimer>

#include "connection/awsclient.h"

class DiscoveryModel;
class UpnpDiscovery;
class ZeroconfDiscovery;
class BluetoothServiceDiscovery;


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

private slots:
    void syncCloudDevices();

private:
    bool m_discovering = false;
    DiscoveryModel *m_discoveryModel = nullptr;

    UpnpDiscovery *m_upnp = nullptr;
    ZeroconfDiscovery *m_zeroConf = nullptr;
    BluetoothServiceDiscovery *m_bluetooth = nullptr;

    QTimer m_cloudPollTimer;

};

#endif // NYMEADISCOVERY_H

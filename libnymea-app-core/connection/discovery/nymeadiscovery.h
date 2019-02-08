#ifndef NYMEADISCOVERY_H
#define NYMEADISCOVERY_H

#include <QObject>
#include <QTimer>
#include <QUuid>

#include "connection/awsclient.h"
#include "connection/nymeahost.h"

class NymeaHosts;
class UpnpDiscovery;
class ZeroconfDiscovery;
class BluetoothServiceDiscovery;


class NymeaDiscovery : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool discovering READ discovering WRITE setDiscovering NOTIFY discoveringChanged)
    Q_PROPERTY(AWSClient* awsClient READ awsClient WRITE setAwsClient NOTIFY awsClientChanged)

    Q_PROPERTY(NymeaHosts* nymeaHosts READ nymeaHosts CONSTANT)

public:
    explicit NymeaDiscovery(QObject *parent = nullptr);
    ~NymeaDiscovery();

    bool discovering() const;
    void setDiscovering(bool discovering);

    NymeaHosts *nymeaHosts() const;

    AWSClient* awsClient() const;
    void setAwsClient(AWSClient *awsClient);

    Q_INVOKABLE void cacheHost(NymeaHost* host);

signals:
    void discoveringChanged();
    void awsClientChanged();

    void serverUuidResolved(const QUuid &uuid, const QString &url);

private slots:
    void syncCloudDevices();

    void loadFromDisk();

    void updateActiveBearers();

private:
    bool m_discovering = false;
    NymeaHosts *m_nymeaHosts = nullptr;

    AWSClient *m_awsClient = nullptr;

    UpnpDiscovery *m_upnp = nullptr;
    ZeroconfDiscovery *m_zeroConf = nullptr;
    BluetoothServiceDiscovery *m_bluetooth = nullptr;

    QTimer m_cloudPollTimer;

    QList<QUuid> m_pendingHostResolutions;

};

#endif // NYMEADISCOVERY_H

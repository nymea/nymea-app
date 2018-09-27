#ifndef ZEROCONFDISCOVERY_H
#define ZEROCONFDISCOVERY_H

#ifdef WITH_ZEROCONF
#include "qzeroconf.h"
#endif

#include "discoverymodel.h"

#include <QObject>

class ZeroconfDiscovery : public QObject
{
    Q_OBJECT

public:
    explicit ZeroconfDiscovery(DiscoveryModel *discoveryModel, QObject *parent = nullptr);
    ~ZeroconfDiscovery();

    bool available() const;
    bool discovering() const;

private:
    DiscoveryModel *m_discoveryModel;

#ifdef WITH_ZEROCONF
    QZeroConf *m_zeroconfJsonRPC = nullptr;
    QZeroConf *m_zeroconfWebSocket = nullptr;

private slots:
    void serviceEntryAdded(const QZeroConfService &entry);
    void serviceEntryRemoved(const QZeroConfService &entry);
#endif
};

#endif // ZEROCONFDISCOVERY_H

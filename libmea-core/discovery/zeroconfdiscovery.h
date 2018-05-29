#ifndef ZEROCONFDISCOVERY_H
#define ZEROCONFDISCOVERY_H

#ifdef WITH_AVAHI
#include "avahi/qtavahiservicebrowser.h"
#endif

#include "discoverymodel.h"

#include <QObject>

class ZeroconfDiscovery : public QObject
{
    Q_OBJECT

public:
    explicit ZeroconfDiscovery(DiscoveryModel *discoveryModel, QObject *parent = nullptr);

    bool available() const;
    bool discovering() const;

private:
    DiscoveryModel *m_discoveryModel;

#ifdef WITH_AVAHI
    QtAvahiServiceBrowser *m_serviceBrowser;

private slots:
    void serviceEntryAdded(const AvahiServiceEntry &entry);

#endif

};

#endif // ZEROCONFDISCOVERY_H

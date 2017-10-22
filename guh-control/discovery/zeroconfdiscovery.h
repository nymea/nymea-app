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
    Q_PROPERTY(bool discovering READ discovering NOTIFY discoveringChanged)
    Q_PROPERTY(bool available READ available CONSTANT)
    Q_PROPERTY(DiscoveryModel* discoveryModel READ discoveryModel CONSTANT)

public:
    explicit ZeroconfDiscovery(QObject *parent = nullptr);

    bool available() const;
    bool discovering() const;

    DiscoveryModel* discoveryModel() const;

signals:
    void discoveringChanged();

public slots:

private:
    DiscoveryModel *m_discoveryModel;

#ifdef WITH_AVAHI
    QtAvahiServiceBrowser *m_serviceBrowser;

private slots:
    void serviceEntryAdded(const AvahiServiceEntry &entry);

#endif

};

#endif // ZEROCONFDISCOVERY_H

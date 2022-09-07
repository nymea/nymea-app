#ifndef NETWORKREACHABILITYMONITOR_H
#define NETWORKREACHABILITYMONITOR_H

#include <QObject>
#include <QNetworkConfigurationManager>

#include "nymeaconnection.h"

#ifdef Q_OS_IOS
#import <SystemConfiguration/SystemConfiguration.h>
#endif

class NetworkReachabilityMonitor : public QObject
{
    Q_OBJECT
    Q_PROPERTY(NymeaConnection::BearerTypes availableBearerTypes READ availableBearerTypes NOTIFY availableBearerTypesChanged)
public:
    explicit NetworkReachabilityMonitor(QObject *parent = nullptr);
    ~NetworkReachabilityMonitor();

    NymeaConnection::BearerTypes availableBearerTypes() const;

signals:
    void availableBearerTypesChanged();
    void availableBearerTypesUpdated(); // Does not necessarily mean they changed, but they're reasonably up to date now.

private slots:
    void updateActiveBearers();

private:
    QNetworkConfigurationManager *m_networkConfigManager = nullptr;
    NymeaConnection::BearerTypes m_availableBearerTypes = NymeaConnection::BearerTypeNone;

    static NymeaConnection::BearerType qBearerTypeToNymeaBearerType(QNetworkConfiguration::BearerType type);

#ifdef Q_OS_IOS
    void setupIOS();
    void teardownIOS();
    SCNetworkReachabilityRef m_internetReachabilityRef = nullptr;
    SCNetworkReachabilityRef m_lanReachabilityRef = nullptr;
    static void ReachabilityCallback(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags flags, void* info);
#endif
};

#endif // NETWORKREACHABILITYMONITOR_H

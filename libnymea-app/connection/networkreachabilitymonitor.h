#ifndef NETWORKREACHABILITYMONITOR_H
#define NETWORKREACHABILITYMONITOR_H

#include <QObject>

#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
#include <QNetworkConfigurationManager>
#else
#include <QNetworkInformation>
#endif

#ifdef Q_OS_IOS
#import <SystemConfiguration/SystemConfiguration.h>
#endif

#include "nymeaconnection.h"

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
    NymeaConnection::BearerTypes m_availableBearerTypes = NymeaConnection::BearerTypeNone;

#if QT_VERSION >= QT_VERSION_CHECK(6, 2, 0)
    QNetworkInformation *m_networkInformation = nullptr;
    static NymeaConnection::BearerType qBearerTypeToNymeaBearerType(QNetworkInformation::TransportMedium type);
#else
    QNetworkConfigurationManager *m_networkConfigManager = nullptr;
    static NymeaConnection::BearerType qBearerTypeToNymeaBearerType(QNetworkConfiguration::BearerType type);
#endif


#ifdef Q_OS_IOS
    void setupIOS();
    void teardownIOS();
    SCNetworkReachabilityRef m_internetReachabilityRef = nullptr;
    SCNetworkReachabilityRef m_lanReachabilityRef = nullptr;
    static void ReachabilityCallback(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags flags, void* info);
#endif
};

#endif // NETWORKREACHABILITYMONITOR_H

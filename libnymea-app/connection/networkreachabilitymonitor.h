#ifndef NETWORKREACHABILITYMONITOR_H
#define NETWORKREACHABILITYMONITOR_H

#include <QObject>
#include <QNetworkConfigurationManager>

#include "nymeaconnection.h"

class NetworkReachabilityMonitor : public QObject
{
    Q_OBJECT
    Q_PROPERTY(NymeaConnection::BearerTypes availableBearerTypes READ availableBearerTypes NOTIFY availableBearerTypesChanged)
public:
    explicit NetworkReachabilityMonitor(QObject *parent = nullptr);

    NymeaConnection::BearerTypes availableBearerTypes() const;

signals:
    void availableBearerTypesChanged();
    void availableBearerTypesUpdated(); // Does not necessarily mean they changed, but they're reasonably up to date now.

private slots:
    void updateActiveBearers();

private:
    NymeaConnection::BearerType qBearerTypeToNymeaBearerType(QNetworkConfiguration::BearerType type) const;

private:
    QNetworkConfigurationManager *m_networkConfigManager = nullptr;
    NymeaConnection::BearerTypes m_availableBearerTypes = NymeaConnection::BearerTypeNone;

};

#endif // NETWORKREACHABILITYMONITOR_H

// SPDX-License-Identifier: LGPL-3.0-or-later

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
* Copyright (C) 2013 - 2024, nymea GmbH
* Copyright (C) 2024 - 2025, chargebyte austria GmbH
*
* This file is part of libnymea-app.
*
* libnymea-app is free software: you can redistribute it and/or
* modify it under the terms of the GNU Lesser General Public License
* as published by the Free Software Foundation, either version 3
* of the License, or (at your option) any later version.
*
* libnymea-app is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
* GNU Lesser General Public License for more details.
*
* You should have received a copy of the GNU Lesser General Public License
* along with libnymea-app. If not, see <https://www.gnu.org/licenses/>.
*
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

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

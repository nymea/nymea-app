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

#include "networkreachabilitymonitor.h"

#include <QGuiApplication>
#include <QLoggingCategory>

Q_DECLARE_LOGGING_CATEGORY(dcNymeaConnection)

NetworkReachabilityMonitor::NetworkReachabilityMonitor(QObject *parent)
    : QObject{parent}
{
    // NOTE: The Qt API is not working at all on iOS, we're using the iOS reachability API instead.
    // See iOS implementation in .mm file
#if defined(Q_OS_IOS)
    setupIOS();
#endif

    m_networkConfigManager = new QNetworkConfigurationManager(this);

    QObject::connect(m_networkConfigManager, &QNetworkConfigurationManager::configurationAdded, this, [this](const QNetworkConfiguration &config){
        Q_UNUSED(config)
        qCDebug(dcNymeaConnection()) << "Network configuration added:" << config.name() << config.bearerTypeName() << config.purpose();
        updateActiveBearers();
    });
    QObject::connect(m_networkConfigManager, &QNetworkConfigurationManager::configurationRemoved, this, [this](const QNetworkConfiguration &config){
        Q_UNUSED(config)
        qCDebug(dcNymeaConnection()) << "Network configuration removed:" << config.name() << config.bearerTypeName() << config.purpose();
        updateActiveBearers();
    });

    QGuiApplication *app = static_cast<QGuiApplication*>(QGuiApplication::instance());
    QObject::connect(app, &QGuiApplication::applicationStateChanged, this, [this](Qt::ApplicationState state) {
        qCDebug(dcNymeaConnection()) << "Application state changed to:" << state;
        updateActiveBearers();
    });

    updateActiveBearers();

}

NetworkReachabilityMonitor::~NetworkReachabilityMonitor()
{
#ifdef Q_OS_IOS
    teardownIOS();
#endif
}

NymeaConnection::BearerTypes NetworkReachabilityMonitor::availableBearerTypes() const
{
    return m_availableBearerTypes;
}

void NetworkReachabilityMonitor::updateActiveBearers()
{
#if defined(Q_OS_IOS)
    return;
#endif

    NymeaConnection::BearerTypes availableBearerTypes;
    QList<QNetworkConfiguration> configs = m_networkConfigManager->allConfigurations(QNetworkConfiguration::Active);
    qCDebug(dcNymeaConnection()) << "Network configuations:" << configs.count();
    foreach (const QNetworkConfiguration &config, configs) {
        qCDebug(dcNymeaConnection()) << "Active network config:" << config.name() << config.bearerTypeFamily() << config.bearerTypeName();
        availableBearerTypes.setFlag(qBearerTypeToNymeaBearerType(config.bearerType()));
    }
    if (availableBearerTypes == NymeaConnection::BearerTypeNone) {
        // This is just debug info... On some platform bearer management seems a bit broken, so let's get some infos right away...
        qCDebug(dcNymeaConnection()) << "No active bearer available. Inactive bearers are:";
        QList<QNetworkConfiguration> configs = m_networkConfigManager->allConfigurations();
        foreach (const QNetworkConfiguration &config, configs) {
            qCDebug(dcNymeaConnection()) << "Inactive network config:" << config.name() << config.bearerTypeFamily() << config.bearerTypeName();
        }

        qCDebug(dcNymeaConnection()) << "Updating network manager";
        m_networkConfigManager->updateConfigurations();
    }

    if (m_availableBearerTypes != availableBearerTypes) {
        qCInfo(dcNymeaConnection()) << "Available Bearer Types changed to:" << availableBearerTypes;
        m_availableBearerTypes = availableBearerTypes;
        emit availableBearerTypesChanged();
    } else {
        qCDebug(dcNymeaConnection()) << "Available Bearer Types:" << availableBearerTypes;
    }

    emit availableBearerTypesUpdated();
}

NymeaConnection::BearerType NetworkReachabilityMonitor::qBearerTypeToNymeaBearerType(QNetworkConfiguration::BearerType type)
{
    switch (type) {
    case QNetworkConfiguration::BearerUnknown:
        // Unable to determine the connection type. Assume it's something we can establish any connection type on
        return NymeaConnection::BearerTypeAll;
    case QNetworkConfiguration::BearerEthernet:
        return NymeaConnection::BearerTypeEthernet;
    case QNetworkConfiguration::BearerWLAN:
        return NymeaConnection::BearerTypeWiFi;
    case QNetworkConfiguration::Bearer2G:
    case QNetworkConfiguration::BearerCDMA2000:
    case QNetworkConfiguration::BearerWCDMA:
    case QNetworkConfiguration::BearerHSPA:
    case QNetworkConfiguration::BearerWiMAX:
    case QNetworkConfiguration::BearerEVDO:
    case QNetworkConfiguration::BearerLTE:
    case QNetworkConfiguration::Bearer3G:
    case QNetworkConfiguration::Bearer4G:
        return NymeaConnection::BearerTypeMobileData;
    case QNetworkConfiguration::BearerBluetooth:
    // Note: Do not confuse this with the Bluetooth transport... For Qt, this means IP over BT, not RFCOMM as we do it.
        return NymeaConnection::BearerTypeNone;
    }
    return NymeaConnection::BearerTypeAll;

}

// SPDX-License-Identifier: LGPL-3.0-or-later

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
* Copyright (C) 2024 - 2026, chargebyte austria GmbH
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

#include "networkinfo.h"
#include "networkinterfaces.h"

#include "engine.h"
#include "jsonrpc/jsonrpcclient.h"

#include "logging.h"

NYMEA_LOGGING_CATEGORY(dcNetworkInfo, "NetworkInfo")

NetworkInfo::NetworkInfo(QObject *parent):
    QObject(parent),
    m_interfaces(new NetworkInterfaces(this))
{
}

NetworkInfo::~NetworkInfo()
{
    if (m_engine) {
        m_engine->jsonRpcClient()->unregisterNotificationHandler(this);
    }
}

void NetworkInfo::setEngine(Engine *engine)
{
    if (m_engine == engine) {
        return;
    }

    if (m_engine) {
        m_engine->jsonRpcClient()->unregisterNotificationHandler(this);
        disconnect(m_engine->jsonRpcClient(), nullptr, this, nullptr);
    }

    m_engine = engine;
    emit engineChanged();

    if (!m_engine) {
        init();
        return;
    }

    m_engine->jsonRpcClient()->registerNotificationHandler(this, "Network", "notificationReceived");
    connect(m_engine->jsonRpcClient(), &JsonRpcClient::connectedChanged, this, &NetworkInfo::init);
    init();
}

Engine *NetworkInfo::engine() const
{
    return m_engine;
}

bool NetworkInfo::loading() const
{
    return m_loading;
}

bool NetworkInfo::supported() const
{
    return m_supported;
}

QString NetworkInfo::backend() const
{
    return m_backend;
}

bool NetworkInfo::backendAvailable() const
{
    return m_backendAvailable;
}

QStringList NetworkInfo::features() const
{
    return m_features;
}

NetworkInterfaces *NetworkInfo::interfaces() const
{
    return m_interfaces;
}

void NetworkInfo::init()
{
    // Drop everything from a previous connection, replies to old requests are ignored
    m_backendInfoRequest = -1;
    m_interfacesRequest = -1;
    const bool connected = m_engine && m_engine->jsonRpcClient()->connected();
    // Set loading first so the legacy page does not flash while supported drops to false
    setLoading(connected);
    m_interfaces->clear();
    setBackendInfo(QVariantMap());
    setSupported(false);

    if (!connected) {
        return;
    }

    // Older servers reply with an error for unknown methods, which tells us the API is not available
    m_backendInfoRequest = m_engine->jsonRpcClient()->sendCommand("Network.GetBackendInfo", QVariantMap(), this, "getBackendInfoResponse");
}

void NetworkInfo::getBackendInfoResponse(int commandId, const QVariantMap &params)
{
    if (commandId != m_backendInfoRequest) {
        return;
    }
    m_backendInfoRequest = -1;

    if (!params.contains("backendInfo")) {
        qCInfo(dcNetworkInfo()) << "The server does not support the Network API.";
        setSupported(false);
        setLoading(false);
        return;
    }

    setSupported(true);
    setBackendInfo(params.value("backendInfo").toMap());
    m_interfacesRequest = m_engine->jsonRpcClient()->sendCommand("Network.GetInterfaces", QVariantMap(), this, "getInterfacesResponse");
}

void NetworkInfo::getInterfacesResponse(int commandId, const QVariantMap &params)
{
    if (commandId != m_interfacesRequest) {
        return;
    }
    m_interfacesRequest = -1;

    if (!params.contains("interfaces")) {
        qCWarning(dcNetworkInfo()) << "Failed to fetch network interfaces.";
    } else {
        m_interfaces->applySnapshot(params.value("interfaces").toList());
    }
    setLoading(false);
}

void NetworkInfo::notificationReceived(const QVariantMap &data)
{
    const QString notification = data.value("notification").toString();
    const QVariantMap params = data.value("params").toMap();

    if (notification == "Network.BackendInfoChanged") {
        setBackendInfo(params.value("backendInfo").toMap());
    } else if (notification == "Network.InterfacesChanged") {
        m_interfaces->applySnapshot(params.value("interfaces").toList());
    } else {
        qCDebug(dcNetworkInfo()) << "Unhandled notification" << notification;
    }
}

void NetworkInfo::setLoading(bool loading)
{
    if (m_loading != loading) {
        m_loading = loading;
        emit loadingChanged();
    }
}

void NetworkInfo::setSupported(bool supported)
{
    if (m_supported != supported) {
        m_supported = supported;
        emit supportedChanged();
    }
}

void NetworkInfo::setBackendInfo(const QVariantMap &backendInfo)
{
    const QString backend = backendInfo.value("backend").toString();
    const bool available = backendInfo.value("available").toBool();
    const QStringList features = backendInfo.value("features").toStringList();
    if (m_backend == backend && m_backendAvailable == available && m_features == features) {
        return;
    }

    m_backend = backend;
    m_backendAvailable = available;
    m_features = features;
    emit backendInfoChanged();
}

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

#ifndef NETWORKINFO_H
#define NETWORKINFO_H

#include <QObject>
#include <QPointer>
#include <QStringList>

#include "engine.h"
#include "networkinterfaces.h"

// Backend independent network interface reporting (Network.* API)
class NetworkInfo : public QObject
{
    Q_OBJECT
    Q_PROPERTY(Engine *engine READ engine WRITE setEngine NOTIFY engineChanged)

    Q_PROPERTY(bool loading READ loading NOTIFY loadingChanged)
    Q_PROPERTY(bool supported READ supported NOTIFY supportedChanged)

    Q_PROPERTY(QString backend READ backend NOTIFY backendInfoChanged)
    Q_PROPERTY(bool backendAvailable READ backendAvailable NOTIFY backendInfoChanged)
    Q_PROPERTY(QStringList features READ features NOTIFY backendInfoChanged)

    Q_PROPERTY(NetworkInterfaces *interfaces READ interfaces CONSTANT)

public:
    explicit NetworkInfo(QObject *parent = nullptr);
    ~NetworkInfo();

    void setEngine(Engine *engine);
    Engine *engine() const;

    bool loading() const;
    bool supported() const;

    QString backend() const;
    bool backendAvailable() const;
    QStringList features() const;

    NetworkInterfaces *interfaces() const;

signals:
    void engineChanged();
    void loadingChanged();
    void supportedChanged();
    void backendInfoChanged();

private slots:
    void init();

    void getBackendInfoResponse(int commandId, const QVariantMap &params);
    void getInterfacesResponse(int commandId, const QVariantMap &params);

    void notificationReceived(const QVariantMap &data);

private:
    void setLoading(bool loading);
    void setSupported(bool supported);
    void setBackendInfo(const QVariantMap &backendInfo);

    QPointer<Engine> m_engine;
    bool m_loading = false;
    bool m_supported = false;

    QString m_backend;
    bool m_backendAvailable = false;
    QStringList m_features;

    NetworkInterfaces *m_interfaces = nullptr;

    int m_backendInfoRequest = -1;
    int m_interfacesRequest = -1;
};

#endif // NETWORKINFO_H

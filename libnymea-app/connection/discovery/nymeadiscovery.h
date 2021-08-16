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

#ifndef NYMEADISCOVERY_H
#define NYMEADISCOVERY_H

#include <QObject>
#include <QTimer>
#include <QUuid>

#include "connection/nymeahost.h"
#include "connection/nymeahosts.h"

class UpnpDiscovery;
class ZeroconfDiscovery;
class BluetoothServiceDiscovery;


class NymeaDiscovery : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool discovering READ discovering WRITE setDiscovering NOTIFY discoveringChanged)
    Q_PROPERTY(bool bluetoothDiscoveryEnabled READ bluetoothDiscoveryEnabled WRITE setBluetoothDiscoveryEnabled NOTIFY bluetoothDiscoveryEnabledChanged)
    Q_PROPERTY(bool zeroconfDiscoveryEnabled READ zeroconfDiscoveryEnable WRITE setZeroconfDiscoveryEnabled NOTIFY zeroconfDiscoveryEnabledChanged)
    Q_PROPERTY(bool upnpDiscoveryEnabled READ upnpDiscoveryEnabled WRITE setUpnpDiscoveryEnabled NOTIFY upnpDiscoveryEnabledChanged)

    Q_PROPERTY(NymeaHosts* nymeaHosts READ nymeaHosts CONSTANT)

public:
    explicit NymeaDiscovery(QObject *parent = nullptr);
    ~NymeaDiscovery();

    bool discovering() const;
    void setDiscovering(bool discovering);

    NymeaHosts *nymeaHosts() const;

    Q_INVOKABLE void cacheHost(NymeaHost* host);

    bool zeroconfDiscoveryEnable() const;
    bool bluetoothDiscoveryEnabled() const;
    bool upnpDiscoveryEnabled() const;

public slots:
    void setZeroconfDiscoveryEnabled(bool zeroconfDiscoveryEnabled);
    void setBluetoothDiscoveryEnabled(bool bluetoothDiscoveryEnabled);
    void setUpnpDiscoveryEnabled(bool upnpDiscoveryEnabled);

signals:
    void discoveringChanged();

    void serverUuidResolved(const QUuid &uuid, const QString &url);

    void zeroconfDiscoveryEnabledChanged(bool zeroconfDiscoveryEnabled);
    void bluetoothDiscoveryEnabledChanged(bool bluetoothDiscoveryEnabled);
    void upnpDiscoveryEnabledChanged(bool upnpDiscoveryEnabled);

private slots:
    void loadFromDisk();

    void updateActiveBearers();

private:
    bool m_discovering = false;
    NymeaHosts *m_nymeaHosts = nullptr;

    UpnpDiscovery *m_upnp = nullptr;
    ZeroconfDiscovery *m_zeroConf = nullptr;
    BluetoothServiceDiscovery *m_bluetooth = nullptr;

    QList<QUuid> m_pendingHostResolutions;

    bool m_zeroconfDiscoveryEnabled = true;
    bool m_bluetoothDiscoveryEnabled = true;
    bool m_upnpDiscoveryEnabled = true;
};

#endif // NYMEADISCOVERY_H

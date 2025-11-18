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

#ifndef BLUETOOTHSERVICEDISCOVERY_H
#define BLUETOOTHSERVICEDISCOVERY_H

#include <QObject>
#include <QBluetoothUuid>
#include <QBluetoothLocalDevice>
#include <QBluetoothServiceDiscoveryAgent>

class NymeaHosts;

class BluetoothServiceDiscovery : public QObject
{
    Q_OBJECT
public:
    explicit BluetoothServiceDiscovery(NymeaHosts *nymeaHosts, QObject *parent = nullptr);

    bool discovering() const;
    bool available() const;

    Q_INVOKABLE void discover();
    Q_INVOKABLE void stopDiscovery();

private:
    NymeaHosts *m_nymeaHosts = nullptr;
    QBluetoothLocalDevice *m_localDevice = nullptr;
    QBluetoothServiceDiscoveryAgent *m_serviceDiscovery = nullptr;
    QBluetoothUuid m_nymeaServiceUuid;

    bool m_enabed = false;
    bool m_discovering = false;
    bool m_available = false;

    void setDiscovering(const bool &discovering);

signals:
    void discoveringChanged(bool discovering);

private slots:
    void onHostModeChanged(const QBluetoothLocalDevice::HostMode &mode);

    void onServiceDiscovered(const QBluetoothServiceInfo &serviceInfo);
    void onServiceDiscoveryFinished();

};

#endif // BLUETOOTHSERVICEDISCOVERY_H

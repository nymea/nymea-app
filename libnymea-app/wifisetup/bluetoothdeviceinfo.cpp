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

#include "bluetoothdeviceinfo.h"

#include <QBluetoothUuid>

BluetoothDeviceInfo::BluetoothDeviceInfo()
{
}

BluetoothDeviceInfo::BluetoothDeviceInfo(const QBluetoothDeviceInfo &deviceInfo)
{
    m_deviceInfo = deviceInfo;
}

BluetoothDeviceInfo::~BluetoothDeviceInfo()
{
    qDebug() << "~BluetoothDeviceInfo";
}

QString BluetoothDeviceInfo::address() const
{
    return m_deviceInfo.address().toString();
}

QString BluetoothDeviceInfo::name() const
{
    return m_deviceInfo.name();
}

bool BluetoothDeviceInfo::isLowEnergy() const
{
    return m_deviceInfo.coreConfigurations() & QBluetoothDeviceInfo::LowEnergyCoreConfiguration;
}

int BluetoothDeviceInfo::signalStrength() const
{
    return (m_deviceInfo.rssi() + 100) * 2;
}

QBluetoothDeviceInfo BluetoothDeviceInfo::bluetoothDeviceInfo() const
{
    return m_deviceInfo;
}

void BluetoothDeviceInfo::setBluetoothDeviceInfo(const QBluetoothDeviceInfo &deviceInfo)
{
    m_deviceInfo = QBluetoothDeviceInfo(deviceInfo);
    emit deviceChanged();
}

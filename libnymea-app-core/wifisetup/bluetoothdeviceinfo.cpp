/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *                                                                         *
 *  Copyright (C) 2018 Simon Stuerz <simon.stuerz@guh.io>                  *
 *                                                                         *
 *  This file is part of nymea:app                                         *
 *                                                                         *
 *  This library is free software; you can redistribute it and/or          *
 *  modify it under the terms of the GNU Lesser General Public             *
 *  License as published by the Free Software Foundation; either           *
 *  version 2.1 of the License, or (at your option) any later version.     *
 *                                                                         *
 *  This library is distributed in the hope that it will be useful,        *
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of         *
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU      *
 *  Lesser General Public License for more details.                        *
 *                                                                         *
 *  You should have received a copy of the GNU Lesser General Public       *
 *  License along with this library; If not, see                           *
 *  <http://www.gnu.org/licenses/>.                                        *
 *                                                                         *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#include "bluetoothdeviceinfo.h"

BluetoothDeviceInfo::BluetoothDeviceInfo()
{
}

BluetoothDeviceInfo::BluetoothDeviceInfo(const QBluetoothDeviceInfo &deviceInfo)
{
    m_deviceInfo = deviceInfo;
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

QBluetoothDeviceInfo BluetoothDeviceInfo::getBluetoothDeviceInfo() const
{
    return m_deviceInfo;
}

void BluetoothDeviceInfo::setBluetoothDeviceInfo(const QBluetoothDeviceInfo &deviceInfo)
{
    m_deviceInfo = QBluetoothDeviceInfo(deviceInfo);
    emit deviceChanged();
}

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

#include "bluetoothdiscovery.h"

#include <QDebug>
#include <QBluetoothLocalDevice>

BluetoothDiscovery::BluetoothDiscovery(QObject *parent) :
    QObject(parent),
    m_deviceInfos(new BluetoothDeviceInfos(this))
{

    // Check if bluetooth is available
    QBluetoothLocalDevice localDevice;
    if (!localDevice.isValid()) {
        qWarning() << "BluetoothDiscovery: there is no bluetooth device available.";
        setBluetoothAvailable(false);
        return;
    }

    setBluetoothAvailable(true);

    if (localDevice.allDevices().count() > 1) {
        // FIXME: check the device with the most capabilities and check if low energy is available
    } else {
        QBluetoothHostInfo adapterHostInfo = localDevice.allDevices().first();
        qDebug() << "BluetoothDiscovery: using bluetooth adapter" << adapterHostInfo.name() << adapterHostInfo.address().toString();
        m_localDevice = new QBluetoothLocalDevice(adapterHostInfo.address(), this);
        connect(m_localDevice, &QBluetoothLocalDevice::hostModeStateChanged, this, &BluetoothDiscovery::onBluetoothHostModeChanged);
        onBluetoothHostModeChanged(m_localDevice->hostMode());
    }

    m_discoveryAgent = new QBluetoothDeviceDiscoveryAgent(m_localDevice->address(), this);
    connect(m_discoveryAgent, &QBluetoothDeviceDiscoveryAgent::deviceDiscovered, this, &BluetoothDiscovery::deviceDiscovered);
    connect(m_discoveryAgent, &QBluetoothDeviceDiscoveryAgent::finished, this, &BluetoothDiscovery::discoveryFinished);
    connect(m_discoveryAgent, SIGNAL(error(QBluetoothDeviceDiscoveryAgent::Error)), this, SLOT(onError(QBluetoothDeviceDiscoveryAgent::Error)));
}

bool BluetoothDiscovery::bluetoothAvailable() const
{
    return m_bluetoothAvailable;
}

bool BluetoothDiscovery::bluetoothEnabled() const
{
    return m_bluetoothEnabled;
}

void BluetoothDiscovery::setBluetoothEnabled(bool enabled)
{
    if (enabled) {
        m_localDevice->powerOn();
    } else {
        m_localDevice->setHostMode(QBluetoothLocalDevice::HostPoweredOff);
    }
}

bool BluetoothDiscovery::discovering() const
{
    return m_discovering;
}

BluetoothDeviceInfos *BluetoothDiscovery::deviceInfos()
{
    return m_deviceInfos;
}

void BluetoothDiscovery::setBluetoothAvailable(bool available)
{
    if (m_bluetoothAvailable == available)
        return;

    m_bluetoothAvailable = available;
    emit bluetoothAvailableChanged(m_bluetoothAvailable);
}

void BluetoothDiscovery::setDiscovering(bool discovering)
{
    if (m_discovering == discovering)
        return;

    m_discovering = discovering;
    emit discoveringChanged(m_discovering);
}

void BluetoothDiscovery::onBluetoothHostModeChanged(const QBluetoothLocalDevice::HostMode &hostMode)
{
    qDebug() << "BluetoothDiscovery: host mode changed" << hostMode;
    switch (hostMode) {
    case QBluetoothLocalDevice::HostPoweredOff:
        setBluetoothEnabled(false);
        break;
    default:
        // Note: discovery works in all other modes
        setBluetoothEnabled(true);
        break;
    }
}

void BluetoothDiscovery::deviceDiscovered(const QBluetoothDeviceInfo &deviceInfo)
{
    qDebug() << "BluetoothDiscovery: [+]" << deviceInfo.name() << "(" << deviceInfo.address().toString() << ")" << (deviceInfo.coreConfigurations() & QBluetoothDeviceInfo::LowEnergyCoreConfiguration ? "LE" : "");
    m_deviceInfos->addBluetoothDeviceInfo(new BluetoothDeviceInfo(deviceInfo));
}

void BluetoothDiscovery::discoveryFinished()
{
    qDebug() << "BluetoothDiscovery: Discovery finished";
    setDiscovering(false);
}

void BluetoothDiscovery::onError(const QBluetoothDeviceDiscoveryAgent::Error &error)
{
    qWarning() << "BluetoothDiscovery: Discovery error:" << error << m_discoveryAgent->errorString();
    setDiscovering(false);
}

void BluetoothDiscovery::start()
{
    if (m_discoveryAgent->isActive())
        m_discoveryAgent->stop();

    m_deviceInfos->clearModel();

    qDebug() << "BluetoothDiscovery: Start discovering.";
    m_discoveryAgent->start();
    setDiscovering(true);
}

void BluetoothDiscovery::stop()
{
    qDebug() << "BluetoothDiscovery: Stop discovering.";
    m_discoveryAgent->stop();
    setDiscovering(false);
}

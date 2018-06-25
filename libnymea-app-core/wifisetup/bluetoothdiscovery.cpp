/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *                                                                         *
 *  Copyright (C) 2018 Simon Stuerz <simon.stuerz@guh.io>                  *
 *                                                                         *
 *  This file is part of nymea:app                                               *
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

BluetoothDiscovery::BluetoothDiscovery(QObject *parent) :
    QObject(parent),
    m_discoveryAgent(new QBluetoothDeviceDiscoveryAgent(this)),
    m_deviceInfos(new BluetoothDeviceInfos(this)),
    m_discovering(false)
{
    connect(m_discoveryAgent, &QBluetoothDeviceDiscoveryAgent::deviceDiscovered, this, &BluetoothDiscovery::deviceDiscovered);
    connect(m_discoveryAgent, &QBluetoothDeviceDiscoveryAgent::finished, this, &BluetoothDiscovery::discoveryFinished);
    connect(m_discoveryAgent, SIGNAL(error(QBluetoothDeviceDiscoveryAgent::Error)), this, SLOT(onError(QBluetoothDeviceDiscoveryAgent::Error)));
}

bool BluetoothDiscovery::discovering() const
{
    return m_discovering;
}

BluetoothDeviceInfos *BluetoothDiscovery::deviceInfos()
{
    return m_deviceInfos;
}

void BluetoothDiscovery::setDiscovering(bool discovering)
{
    m_discovering = discovering;
    emit discoveringChanged();
}

void BluetoothDiscovery::deviceDiscovered(const QBluetoothDeviceInfo &deviceInfo)
{
    qDebug() << "Discovery: [+]" << deviceInfo.name() << "(" << deviceInfo.address().toString() << ")" << (deviceInfo.coreConfigurations() & QBluetoothDeviceInfo::LowEnergyCoreConfiguration ? "LE" : "");
    m_deviceInfos->addBluetoothDeviceInfo(new BluetoothDeviceInfo(deviceInfo));
}

void BluetoothDiscovery::discoveryFinished()
{
    qDebug() << "Discovery finished";
    setDiscovering(false);
}

void BluetoothDiscovery::onError(const QBluetoothDeviceDiscoveryAgent::Error &error)
{
    qWarning() << "Discovery error:" << error << m_discoveryAgent->errorString();
    setDiscovering(false);
}

void BluetoothDiscovery::start()
{
    if (m_discoveryAgent->isActive())
        m_discoveryAgent->stop();

    m_deviceInfos->clearModel();

    m_discoveryAgent->start();
    setDiscovering(true);
}

void BluetoothDiscovery::stop()
{
    m_discoveryAgent->stop();
    setDiscovering(false);
}

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

#include "bluetoothdevice.h"

BluetoothDevice::BluetoothDevice(const QBluetoothDeviceInfo &deviceInfo, QObject *parent) :
    QObject(parent),
    m_deviceInfo(deviceInfo),
    m_connected(false)
{
    m_controller = new QLowEnergyController(deviceInfo.address(), this);
    m_controller->setRemoteAddressType(QLowEnergyController::PublicAddress);

    connect(m_controller, &QLowEnergyController::connected, this, &BluetoothDevice::onConnected);
    connect(m_controller, &QLowEnergyController::disconnected, this, &BluetoothDevice::onDisconnected);
    connect(m_controller, &QLowEnergyController::stateChanged, this, &BluetoothDevice::onDeviceStateChanged);
    connect(m_controller, SIGNAL(error(QLowEnergyController::Error)), this, SLOT(onDeviceError(QLowEnergyController::Error)));

    connect(m_controller, SIGNAL(discoveryFinished()), this, SIGNAL(serviceDiscoveryFinished()));
}

QString BluetoothDevice::name() const
{
    return m_deviceInfo.name();
}

QBluetoothAddress BluetoothDevice::address() const
{
    return m_deviceInfo.address();
}

bool BluetoothDevice::connected() const
{
    return m_connected;
}

QString BluetoothDevice::statusText() const
{
    return m_statusText;
}

void BluetoothDevice::connectDevice()
{
    m_controller->connectToDevice();
}

void BluetoothDevice::disconnectDevice()
{
    m_controller->disconnectFromDevice();
}

void BluetoothDevice::setConnected(const bool &connected)
{
    m_connected = connected;
    emit connectedChanged();
}

void BluetoothDevice::setStatusText(const QString &statusText)
{
    m_statusText = statusText;
    emit statusTextChanged();
}

QLowEnergyController *BluetoothDevice::controller()
{
    return m_controller;
}

void BluetoothDevice::onConnected()
{
    qDebug() << "BluetoothDevice: Connected to" << name() << address().toString();
    m_controller->discoverServices();
}

void BluetoothDevice::onDisconnected()
{
    qWarning() << "BluetoothDevice: Disconnected from" << name() << address().toString();
    setConnected(false);
    setStatusText("Disconnected from " +  name());
}

void BluetoothDevice::onDeviceError(const QLowEnergyController::Error &error)
{
    qWarning() << "BluetoothDevice: Error" << name() << address().toString() << ": " << error << m_controller->errorString();
    setConnected(false);
}

void BluetoothDevice::onDeviceStateChanged(const QLowEnergyController::ControllerState &state)
{
    switch (state) {
    case QLowEnergyController::ConnectingState:
        qDebug() << "BluetoothDevice: Connecting...";
        setStatusText(QString(tr("Connecting to %1...").arg(name())));
        break;
    case QLowEnergyController::ConnectedState:
        qDebug() << "BluetoothDevice: Connected!";
        setStatusText(QString(tr("Connected to %1").arg(name())));
        break;
    case QLowEnergyController::ClosingState:
        qDebug() << "BluetoothDevice: Connection: Closing...";
        setStatusText(QString(tr("Disconnecting from %1...").arg(name())));
        break;
    case QLowEnergyController::DiscoveringState:
        qDebug() << "BluetoothDevice: Discovering...";
        setStatusText(QString(tr("Discovering services of %1...").arg(name())));
        break;
    case QLowEnergyController::DiscoveredState:
        qDebug() << "BluetoothDevice: Discovered!";
        setStatusText(QString(tr("%1 connected and discovered.").arg(name())));
        setConnected(true);
        break;
    case QLowEnergyController::UnconnectedState:
        qDebug() << "BluetoothDevice: Not connected.";
        setStatusText(QString(tr("%1 disconnected.").arg(name())));
        break;
    default:
        break;
    }
}

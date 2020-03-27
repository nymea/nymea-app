/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
* Copyright 2013 - 2020, nymea GmbH
* Contact: contact@nymea.io
*
* This file is part of nymea.
* This project including source code and documentation is protected by
* copyright law, and remains the property of nymea GmbH. All rights, including
* reproduction, publication, editing and translation, are reserved. The use of
* this project is subject to the terms of a license agreement to be concluded
* with nymea GmbH in accordance with the terms of use of nymea GmbH, available
* under https://nymea.io/license
*
* GNU General Public License Usage
* Alternatively, this project may be redistributed and/or modified under the
* terms of the GNU General Public License as published by the Free Software
* Foundation, GNU version 3. This project is distributed in the hope that it
* will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty
* of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
* Public License for more details.
*
* You should have received a copy of the GNU General Public License along with
* this project. If not, see <https://www.gnu.org/licenses/>.
*
* For any further details and any questions please contact us under
* contact@nymea.io or see our FAQ/Licensing Information on
* https://nymea.io/license/faq
*
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#include "bluetoothservicediscovery.h"

#include "../nymeahosts.h"
#include "../nymeahost.h"

#include <QTimer>

BluetoothServiceDiscovery::BluetoothServiceDiscovery(NymeaHosts *nymeaHosts, QObject *parent) :
    QObject(parent),
    m_nymeaHosts(nymeaHosts)
{
    m_nymeaServiceUuid = QBluetoothUuid(QUuid("997936b5-d2cd-4c57-b41b-c6048320cd2b"));

    m_localDevice = new QBluetoothLocalDevice(this);
    connect(m_localDevice, &QBluetoothLocalDevice::hostModeStateChanged, this, &BluetoothServiceDiscovery::onHostModeChanged);

    m_serviceDiscovery = new QBluetoothServiceDiscoveryAgent(m_localDevice->address());
    connect(m_serviceDiscovery, &QBluetoothServiceDiscoveryAgent::serviceDiscovered, this, &BluetoothServiceDiscovery::onServiceDiscovered);
    connect(m_serviceDiscovery, &QBluetoothServiceDiscoveryAgent::finished, this, &BluetoothServiceDiscovery::onServiceDiscoveryFinished);
}

bool BluetoothServiceDiscovery::discovering() const
{
    return m_discovering;
}

bool BluetoothServiceDiscovery::available() const
{
    if (!m_localDevice)
        return false;

    return m_localDevice->isValid() && m_localDevice->hostMode() != QBluetoothLocalDevice::HostPoweredOff;
}

void BluetoothServiceDiscovery::discover()
{
    m_enabed = true;
    if (!m_localDevice->isValid() || m_localDevice->hostMode() == QBluetoothLocalDevice::HostPoweredOff) {
        qWarning() << "BluetoothServiceDiscovery: Bluetooth device not available. Not starting discovery.";
        return;
    }

    m_serviceDiscovery->setUuidFilter(m_nymeaServiceUuid);

    if (m_discovering)
        return;

//    qDebug() << "BluetoothServiceDiscovery: Service scan started for service: " << m_nymeaServiceUuid.toString();
    setDiscovering(true);
    m_serviceDiscovery->setUuidFilter(m_nymeaServiceUuid);

    // Delay restarting as Bluez might not be ready just yet
    QTimer::singleShot(500, this, [this]() {
        m_serviceDiscovery->start(QBluetoothServiceDiscoveryAgent::FullDiscovery);
    });
}

void BluetoothServiceDiscovery::stopDiscovery()
{
    m_enabed = false;
    setDiscovering(false);
    m_serviceDiscovery->stop();
}

void BluetoothServiceDiscovery::setDiscovering(const bool &discovering)
{
    if (m_discovering == discovering)
        return;

    m_discovering = discovering;
    emit discoveringChanged(m_discovering);
}

void BluetoothServiceDiscovery::onHostModeChanged(const QBluetoothLocalDevice::HostMode &mode)
{
    if (mode != QBluetoothLocalDevice::HostPoweredOff && m_enabed) {
        qDebug() << "BluetoothServiceDiscovery: Bluetooth device available. Starting discovery.";
        discover();
    }

    if (mode == QBluetoothLocalDevice::HostPoweredOff) {
        qDebug() << "BluetoothServiceDiscovery: Bluetooth adapter disabled. Stopping discovering";
        m_serviceDiscovery->stop();
    }
}

void BluetoothServiceDiscovery::onServiceDiscovered(const QBluetoothServiceInfo &serviceInfo)
{
    qDebug() << "BluetoothServiceDiscovery: Discovered service on" << serviceInfo.device().name() << serviceInfo.device().address().toString();
    qDebug() << "\tDevive name:" << serviceInfo.device().name();
    qDebug() << "\tService name:" << serviceInfo.serviceName();
    qDebug() << "\tDescription:" << serviceInfo.attribute(QBluetoothServiceInfo::ServiceDescription).toString();
    qDebug() << "\tProvider:" << serviceInfo.attribute(QBluetoothServiceInfo::ServiceProvider).toString();
    qDebug() << "\tDocumentation:" << serviceInfo.attribute(QBluetoothServiceInfo::DocumentationUrl).toString();
    qDebug() << "\tL2CAP protocol service multiplexer:" << serviceInfo.protocolServiceMultiplexer();
    qDebug() << "\tRFCOMM server channel:" << serviceInfo.serverChannel();

    if (serviceInfo.serviceClassUuids().isEmpty())
        return;

    if (serviceInfo.serviceClassUuids().first() == QBluetoothUuid(QUuid("997936b5-d2cd-4c57-b41b-c6048320cd2b"))) {
        qDebug() << "BluetoothServiceDiscovery: Found nymea rfcom service!";

//        NymeaHost* host = m_nymeaHosts->find(serviceInfo.device().address());
//        if (!host) {
//            host = new DiscoveryDevice(DiscoveryDevice::DeviceTypeBluetooth, this);
//            qDebug() << "BluetoothServiceDiscovery: Adding new bluetooth host to model";
//            host->setName(QString("%1 (%2)").arg(serviceInfo.serviceName()).arg(serviceInfo.device().name()));
////            device->setBluetoothAddress(serviceInfo.device().address());
//            PortConfig pc;

//            m_nymeaHosts->addHost(device);
//        }
    }
}

void BluetoothServiceDiscovery::onServiceDiscoveryFinished()
{
//    qDebug() << "BluetoothServiceDiscovery: Service discovery finished.";
    setDiscovering(false);

    foreach (const QBluetoothServiceInfo &serviceInfo, m_serviceDiscovery->discoveredServices()) {
        onServiceDiscovered(serviceInfo);
    }

    // If discover was called, but never stopDiscover, continue discovery
    if (m_enabed) {
        if (!m_localDevice->isValid() || m_localDevice->hostMode() == QBluetoothLocalDevice::HostPoweredOff) {
            qWarning() << "BluetoothServiceDiscovery: Not restarting discovery, the bluetooth adapter is not available.";
            return;
        }

//        qDebug() << "BluetoothServiceDiscovery: Restart service discovery";
        discover();
    }
}

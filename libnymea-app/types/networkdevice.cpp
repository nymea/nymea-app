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

#include "networkdevice.h"

#include "wirelessaccesspoints.h"
#include "wirelessaccesspoint.h"

NetworkDevice::NetworkDevice(const QString &macAddress, const QString &interface, QObject *parent):
    QObject (parent),
    m_macAddress(macAddress),
    m_interface(interface)
{

}

QString NetworkDevice::macAddress() const
{
    return m_macAddress;
}

QStringList NetworkDevice::ipv4Addresses() const
{
    return m_ipv4Addresses;
}

QStringList NetworkDevice::ipv6Addresses() const
{
    return m_ipv6Addresses;
}

QString NetworkDevice::interface() const
{
    return m_interface;
}

void NetworkDevice::setIpv4Addresses(const QStringList &ipAddresses)
{
    if (m_ipv4Addresses != ipAddresses) {
        m_ipv4Addresses = ipAddresses;
        emit ipv4AddressesChanged();
    }
}

void NetworkDevice::setIpv6Addresses(const QStringList &ipAddresses)
{
    if (m_ipv6Addresses != ipAddresses) {
        m_ipv6Addresses = ipAddresses;
        emit ipv6AddressesChanged();
    }
}

QString NetworkDevice::bitRate() const
{
    return m_bitRate;
}

void NetworkDevice::setBitRate(const QString &bitRate)
{
    if (m_bitRate != bitRate) {
        m_bitRate = bitRate;
        emit bitRateChanged();
    }
}

NetworkDevice::NetworkDeviceState NetworkDevice::state() const
{
    return m_state;
}

void NetworkDevice::setState(NetworkDevice::NetworkDeviceState state)
{
    if (m_state != state) {
        m_state = state;
        emit stateChanged();
    }
}

WiredNetworkDevice::WiredNetworkDevice(const QString &macAddress, const QString &interface, QObject *parent):
    NetworkDevice (macAddress, interface, parent)
{

}

bool WiredNetworkDevice::pluggedIn() const
{
    return m_pluggedIn;
}

void WiredNetworkDevice::setPluggedIn(bool pluggedIn)
{
    if (m_pluggedIn != pluggedIn) {
        m_pluggedIn = pluggedIn;
        emit pluggedInChanged();
    }
}

WirelessNetworkDevice::WirelessNetworkDevice(const QString &macAddress, const QString &interface, QObject *parent):
    NetworkDevice (macAddress, interface, parent)
{
    m_accessPoints = new WirelessAccessPoints(this);
    m_currentAccessPoint = new WirelessAccessPoint(this);
}

WirelessNetworkDevice::WirelessCapabilities WirelessNetworkDevice::wirelessCapabilities() const
{
    return m_wirelessCapabilities;
}

WirelessNetworkDevice::WirelessMode WirelessNetworkDevice::wirelessMode() const
{
    return m_wirelessMode;
}

WirelessAccessPoints *WirelessNetworkDevice::accessPoints() const
{
    return m_accessPoints;
}

WirelessAccessPoint *WirelessNetworkDevice::currentAccessPoint() const
{
    return m_currentAccessPoint;
}

void WirelessNetworkDevice::setWirelessCapabilities(WirelessCapabilities wirelessCapabilities)
{
    if (m_wirelessCapabilities != wirelessCapabilities) {
        m_wirelessCapabilities = wirelessCapabilities;
        emit wirelessCapabilitiesChanged();
    }
}

void WirelessNetworkDevice::setWirelessMode(WirelessNetworkDevice::WirelessMode wirelessMode)
{
    if (m_wirelessMode != wirelessMode) {
        m_wirelessMode = wirelessMode;
        emit wirelessModeChanged();
    }
}

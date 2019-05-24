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

QString NetworkDevice::interface() const
{
    return m_interface;
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

WirelessAccessPoints *WirelessNetworkDevice::accessPoints() const
{
    return m_accessPoints;
}

WirelessAccessPoint *WirelessNetworkDevice::currentAccessPoint() const
{
    return m_currentAccessPoint;
}

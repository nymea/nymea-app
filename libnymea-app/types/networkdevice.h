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

#ifndef NETWORKDEVICE_H
#define NETWORKDEVICE_H

#include <QObject>

#include "wirelessaccesspoint.h"
#include "wirelessaccesspoints.h"

class NetworkDevice : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString macAddress READ macAddress CONSTANT)
    Q_PROPERTY(QStringList ipv4Addresses READ ipv4Addresses NOTIFY ipv4AddressesChanged)
    Q_PROPERTY(QStringList ipv6Addresses READ ipv6Addresses NOTIFY ipv6AddressesChanged)
    Q_PROPERTY(QString interface READ interface CONSTANT)
    Q_PROPERTY(QString bitRate READ bitRate NOTIFY bitRateChanged)
    Q_PROPERTY(NetworkDeviceState state READ state NOTIFY stateChanged)

public:
    enum NetworkDeviceState {
        NetworkDeviceStateUnknown = 0,
        NetworkDeviceStateUnmanaged = 10,
        NetworkDeviceStateUnavailable = 20,
        NetworkDeviceStateDisconnected = 30,
        NetworkDeviceStatePrepare = 40,
        NetworkDeviceStateConfig = 50,
        NetworkDeviceStateNeedAuth = 60,
        NetworkDeviceStateIpConfig = 70,
        NetworkDeviceStateIpCheck = 80,
        NetworkDeviceStateSecondaries = 90,
        NetworkDeviceStateActivated = 100,
        NetworkDeviceStateDeactivating = 110,
        NetworkDeviceStateFailed = 120
    };
    Q_ENUM(NetworkDeviceState)

    explicit NetworkDevice(const QString &macAddress, const QString &interface, QObject *parent = nullptr);
    virtual ~NetworkDevice() = default;

    QString interface() const;
    QString macAddress() const;
    QStringList ipv4Addresses() const;
    QStringList ipv6Addresses() const;

    void setIpv4Addresses(const QStringList &ipv4Addresses);
    void setIpv6Addresses(const QStringList &ipv6Addresses);

    QString bitRate() const;
    void setBitRate(const QString &bitRate);

    NetworkDeviceState state() const;
    void setState(NetworkDeviceState state);

signals:
    void bitRateChanged();
    void stateChanged();
    void ipv4AddressesChanged();
    void ipv6AddressesChanged();

private:
    QString m_macAddress;
    QStringList m_ipv4Addresses;
    QStringList m_ipv6Addresses;
    QString m_interface;
    QString m_bitRate;
    NetworkDeviceState m_state;
};

class WiredNetworkDevice: public NetworkDevice {
    Q_OBJECT
    Q_PROPERTY(bool pluggedIn READ pluggedIn NOTIFY pluggedInChanged)

public:
    explicit WiredNetworkDevice(const QString &macAddress, const QString &interface, QObject *parent = nullptr);

    bool pluggedIn() const;
    void setPluggedIn(bool pluggedIn);

signals:
    void pluggedInChanged();

private:
    bool m_pluggedIn = false;
};

class WirelessNetworkDevice: public NetworkDevice
{
    Q_OBJECT
    Q_PROPERTY(WirelessCapabilities wirelessCapabilities READ wirelessCapabilities NOTIFY wirelessCapabilitiesChanged)
    Q_PROPERTY(WirelessMode wirelessMode READ wirelessMode NOTIFY wirelessModeChanged)
    Q_PROPERTY(WirelessAccessPoints* accessPoints READ accessPoints CONSTANT)
    Q_PROPERTY(WirelessAccessPoint* currentAccessPoint READ currentAccessPoint CONSTANT)

public:
    enum WirelessMode {
        WirelessModeUnknown          = 0,
        WirelessModeAdhoc            = 1,
        WirelessModeInfrastructure   = 2,
        WirelessModeAccessPoint      = 3
    };
    Q_ENUM(WirelessMode)

    enum WirelessCapability {
        WirelessCapabilityNone = 0x0000,
        WirelessCapabilityCipherWEP40 = 0x0001,
        WirelessCapabilityCipherWEP104 = 0x0002,
        WirelessCapabilityCipherTKIP = 0x0004,
        WirelessCapabilityCipherCCMP = 0x0008,
        WirelessCapabilityWPA = 0x0010,
        WirelessCapabilityRSN = 0x0020,
        WirelessCapabilityAP = 0x0040,
        WirelessCapabilityAdHoc = 0x0080,
        WirelessCapabilityFreqValid = 0x0100,
        WirelessCapability2Ghz = 0x0200,
        WirelessCapability5Ghz = 0x0400,
    };
    Q_ENUM(WirelessCapability)
    Q_DECLARE_FLAGS(WirelessCapabilities, WirelessCapability)
    Q_FLAG(WirelessCapabilities)

    explicit WirelessNetworkDevice(const QString &macAddress, const QString &interface, QObject *parent = nullptr);

    WirelessCapabilities wirelessCapabilities() const;
    WirelessMode wirelessMode() const;
    WirelessAccessPoints* accessPoints() const;
    WirelessAccessPoint* currentAccessPoint() const;

    void setWirelessCapabilities(WirelessCapabilities wirelessCapabilities);
    void setWirelessMode(WirelessMode wirelessMode);

signals:
    void wirelessCapabilitiesChanged();
    void wirelessModeChanged();

private:
    WirelessCapabilities m_wirelessCapabilities = WirelessCapabilityNone;
    WirelessMode m_wirelessMode = WirelessModeUnknown;
    WirelessAccessPoints *m_accessPoints = nullptr;
    WirelessAccessPoint *m_currentAccessPoint = nullptr;

};
#endif // NETWORKDEVICE_H

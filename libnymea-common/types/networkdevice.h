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

#ifndef NETWORKDEVICE_H
#define NETWORKDEVICE_H

#include <QObject>

class WirelessAccessPoint;
class WirelessAccessPoints;

class NetworkDevice : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString macAddress READ macAddress CONSTANT)
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

    QString macAddress() const;
    QString interface() const;

    QString bitRate() const;
    void setBitRate(const QString &bitRate);

    NetworkDeviceState state() const;
    void setState(NetworkDeviceState state);

signals:
    void bitRateChanged();
    void stateChanged();

private:
    QString m_macAddress;
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
    Q_PROPERTY(WirelessAccessPoints* accessPoints READ accessPoints CONSTANT)
    Q_PROPERTY(WirelessAccessPoint* currentAccessPoint READ currentAccessPoint CONSTANT)

public:
    explicit WirelessNetworkDevice(const QString &macAddress, const QString &interface, QObject *parent = nullptr);

    WirelessAccessPoints* accessPoints() const;
    WirelessAccessPoint* currentAccessPoint() const;

private:
    WirelessAccessPoints *m_accessPoints = nullptr;
    WirelessAccessPoint *m_currentAccessPoint = nullptr;
};
#endif // NETWORKDEVICE_H

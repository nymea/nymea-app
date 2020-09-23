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

#ifndef BLUETOOTHDISCOVERY_H
#define BLUETOOTHDISCOVERY_H

#ifndef NO_BLUETOOTH

#include <QObject>
#include <QBluetoothLocalDevice>
#include <QBluetoothDeviceDiscoveryAgent>

#include "bluetoothdeviceinfos.h"

class BluetoothDiscovery : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool bluetoothAvailable READ bluetoothAvailable NOTIFY bluetoothAvailableChanged)
    Q_PROPERTY(bool bluetoothEnabled READ bluetoothEnabled WRITE setBluetoothEnabled NOTIFY bluetoothEnabledChanged)
    Q_PROPERTY(bool discoveryEnabled READ discoveryEnabled WRITE setDiscoveryEnabled NOTIFY discoveryEnabledChanged)
    Q_PROPERTY(bool discovering READ discovering NOTIFY discoveringChanged)
    Q_PROPERTY(BluetoothDeviceInfos *deviceInfos READ deviceInfos CONSTANT)

public:
    explicit BluetoothDiscovery(QObject *parent = nullptr);

    bool bluetoothAvailable() const;
    bool bluetoothEnabled() const;
    void setBluetoothEnabled(bool bluetoothEnabled);

    bool discoveryEnabled() const;
    void setDiscoveryEnabled(bool discoveryEnabled);

    bool discovering() const;

    BluetoothDeviceInfos *deviceInfos();

signals:
    void bluetoothAvailableChanged(bool bluetoothAvailable);
    void bluetoothEnabledChanged(bool bluetoothEnabled);
    void discoveryEnabledChanged(bool discoveryEnabled);
    void discoveringChanged();

private slots:
    void onBluetoothHostModeChanged(const QBluetoothLocalDevice::HostMode &hostMode);
    void deviceDiscovered(const QBluetoothDeviceInfo &deviceInfo);
    void discoveryFinished();
    void discoveryCancelled();
    void onError(const QBluetoothDeviceDiscoveryAgent::Error &error);

private slots:
    void start();
    void stop();

private:
    QBluetoothLocalDevice *m_localDevice = nullptr;
    QBluetoothDeviceDiscoveryAgent *m_discoveryAgent  = nullptr;
    BluetoothDeviceInfos *m_deviceInfos;

    bool m_bluetoothAvailable = false;
#ifdef Q_OS_IOS
    bool m_bluetoothEnabled = false;
#endif
    bool m_discoveryEnabled = false;
};

#endif // NO_BLUETOOTH

#endif // BLUETOOTHDISCOVERY_H

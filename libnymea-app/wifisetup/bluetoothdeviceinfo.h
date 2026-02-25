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

#ifndef BLUETOOTHDEVICEINFO_H
#define BLUETOOTHDEVICEINFO_H

#include <QList>
#include <QObject>
#include <QBluetoothAddress>
#include <QBluetoothDeviceInfo>

class BluetoothDeviceInfo : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString name READ name NOTIFY deviceChanged)
    Q_PROPERTY(QString address READ address NOTIFY deviceChanged)
    Q_PROPERTY(int signalStrength READ signalStrength NOTIFY deviceChanged)

public:
    BluetoothDeviceInfo();
    BluetoothDeviceInfo(const QBluetoothDeviceInfo &deviceInfo);
    ~BluetoothDeviceInfo();

    QString address() const;
    QString name() const;
    bool isLowEnergy() const;
    int signalStrength() const;

    QBluetoothDeviceInfo bluetoothDeviceInfo() const;
    void setBluetoothDeviceInfo(const QBluetoothDeviceInfo &deviceInfo);

signals:
    void deviceChanged();

private:
    QBluetoothDeviceInfo m_deviceInfo;

};

#endif // BLUETOOTHDEVICEINFO_H

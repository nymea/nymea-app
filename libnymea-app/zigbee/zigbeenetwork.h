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

#ifndef ZIGBEENETWORK_H
#define ZIGBEENETWORK_H

#include <QUuid>
#include <QObject>
#include <QTimer>

#include "zigbeenodes.h"
#include "zigbeeadapter.h"

class ZigbeeNetwork : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QUuid networkUuid READ networkUuid NOTIFY networkUuidChanged)
    Q_PROPERTY(bool enabled READ enabled NOTIFY enabledChanged)
    Q_PROPERTY(QString serialPort READ serialPort NOTIFY serialPortChanged)
    Q_PROPERTY(uint baudRate READ baudRate NOTIFY baudRateChanged)
    Q_PROPERTY(QString macAddress READ macAddress NOTIFY macAddressChanged)
    Q_PROPERTY(QString firmwareVersion READ firmwareVersion NOTIFY firmwareVersionChanged)
    Q_PROPERTY(uint panId READ panId NOTIFY panIdChanged)
    Q_PROPERTY(uint channel READ channel NOTIFY channelChanged)
    Q_PROPERTY(uint channelMask READ channelMask NOTIFY channelMaskChanged)
    Q_PROPERTY(bool permitJoiningEnabled READ permitJoiningEnabled NOTIFY permitJoiningEnabledChanged)
    Q_PROPERTY(uint permitJoiningDuration READ permitJoiningDuration NOTIFY permitJoiningDurationChanged)
    Q_PROPERTY(uint permitJoiningRemaining READ permitJoiningRemaining NOTIFY permitJoiningRemainingChanged)
    Q_PROPERTY(QString backend READ backend NOTIFY backendChanged)
    Q_PROPERTY(ZigbeeNetworkState networkState READ networkState NOTIFY networkStateChanged)
    Q_PROPERTY(ZigbeeNodes *nodes READ nodes CONSTANT)

    // Internal properties

public:
    enum ZigbeeNetworkState {
        ZigbeeNetworkStateOffline,
        ZigbeeNetworkStateStarting,
        ZigbeeNetworkStateUpdating,
        ZigbeeNetworkStateOnline,
        ZigbeeNetworkStateError
    };
    Q_ENUM(ZigbeeNetworkState)

    explicit ZigbeeNetwork(QObject *parent = nullptr);

    ZigbeeNodes *nodes() const;

    QUuid networkUuid() const;
    void setNetworkUuid(const QUuid &networkUuid);

    bool enabled() const;
    void setEnabled(bool enabled);

    QString serialPort() const;
    void setSerialPort(const QString &serialPort);

    uint baudRate() const;
    void setBaudRate(uint baudRate);

    QString macAddress() const;
    void setMacAddress(const QString &macAddress);

    QString firmwareVersion() const;
    void setFirmwareVersion(const QString &firmwareVersion);

    uint panId() const;
    void setPanId(uint panId);

    uint channel() const;
    void setChannel(uint channel);

    uint channelMask() const;
    void setChannelMask(uint channelMask);

    bool permitJoiningEnabled() const;
    void setPermitJoiningEnabled(bool permitJoiningEnabled);

    uint permitJoiningDuration() const;
    void setPermitJoiningDuration(uint permitJoiningDuration);

    uint permitJoiningRemaining() const;
    void setPermitJoiningRemaining(uint permitJoiningRemaining);

    QString backend() const;
    void setBackend(const QString &backend);

    ZigbeeNetworkState networkState() const;
    void setNetworkState(ZigbeeNetworkState networkState);

signals:
    void networkUuidChanged();
    void enabledChanged();
    void serialPortChanged();
    void baudRateChanged();
    void macAddressChanged();
    void firmwareVersionChanged();
    void panIdChanged();
    void channelChanged();
    void channelMaskChanged();
    void permitJoiningEnabledChanged();
    void permitJoiningDurationChanged();
    void permitJoiningRemainingChanged();
    void backendChanged();
    void networkStateChanged();

private:
    QUuid m_networkUuid;
    bool m_enabled;
    QString m_serialPort;
    uint m_baudRate;
    QString m_macAddress;
    QString m_firmwareVersion;
    uint m_panId;
    uint m_channel;
    uint m_channelMask;
    bool m_permitJoiningEnabled;
    uint m_permitJoiningDuration;
    uint m_permitJoiningRemaining;
    QString m_backend;
    ZigbeeNetworkState m_networkState;

    ZigbeeNodes *m_nodes = nullptr;

    QTimer *m_permitJoinTimer = nullptr;
};

#endif // ZIGBEENETWORK_H

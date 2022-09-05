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

#include "zigbeenetwork.h"

ZigbeeNetwork::ZigbeeNetwork(QObject *parent) :
    QObject(parent),
    m_nodes(new ZigbeeNodes(this))
{
    m_permitJoinTimer = new QTimer(this);
    m_permitJoinTimer->setInterval(1000);
    m_permitJoinTimer->setSingleShot(true);
    connect(m_permitJoinTimer, &QTimer::timeout, this, [this](){
        setPermitJoiningRemaining(m_permitJoiningRemaining - 1);
        if (m_permitJoiningRemaining <= 0) {
            m_permitJoinTimer->stop();
        }
    });
}


ZigbeeNodes *ZigbeeNetwork::nodes() const
{
    return m_nodes;
}

QUuid ZigbeeNetwork::networkUuid() const
{
    return m_networkUuid;
}

void ZigbeeNetwork::setNetworkUuid(const QUuid &networkUuid)
{
    if (m_networkUuid == networkUuid)
        return;

    m_networkUuid = networkUuid;
    emit networkUuidChanged();
}

bool ZigbeeNetwork::enabled() const
{
    return m_enabled;
}

void ZigbeeNetwork::setEnabled(bool enabled)
{
    if (m_enabled == enabled)
        return;

    m_enabled = enabled;
    emit enabledChanged();
}

QString ZigbeeNetwork::serialPort() const
{
    return m_serialPort;
}

void ZigbeeNetwork::setSerialPort(const QString &serialPort)
{
    if (m_serialPort == serialPort)
        return;

    m_serialPort = serialPort;
    emit serialPortChanged();
}

uint ZigbeeNetwork::baudRate() const
{
    return m_baudRate;
}

void ZigbeeNetwork::setBaudRate(uint baudRate)
{
    if (m_baudRate == baudRate)
        return;

    m_baudRate = baudRate;
    emit baudRateChanged();
}

QString ZigbeeNetwork::macAddress() const
{
    return m_macAddress;
}

void ZigbeeNetwork::setMacAddress(const QString &macAddress)
{
    if (m_macAddress == macAddress)
        return;

    m_macAddress = macAddress;
    emit macAddressChanged();
}

QString ZigbeeNetwork::firmwareVersion() const
{
    return m_firmwareVersion;
}

void ZigbeeNetwork::setFirmwareVersion(const QString &firmwareVersion)
{
    if (m_firmwareVersion == firmwareVersion)
        return;

    m_firmwareVersion = firmwareVersion;
    emit firmwareVersionChanged();
}

uint ZigbeeNetwork::panId() const
{
    return m_panId;
}

void ZigbeeNetwork::setPanId(uint panId)
{
    if (m_panId == panId)
        return;

    m_panId = panId;
    emit panIdChanged();
}

uint ZigbeeNetwork::channel() const
{
    return m_channel;
}

void ZigbeeNetwork::setChannel(uint channel)
{
    if (m_channel == channel)
        return;

    m_channel = channel;
    emit channelChanged();
}

uint ZigbeeNetwork::channelMask() const
{
    return m_channelMask;
}

void ZigbeeNetwork::setChannelMask(uint channelMask)
{
    if (m_channelMask == channelMask)
        return;

    m_channelMask = channelMask;
    emit channelMaskChanged();
}

bool ZigbeeNetwork::permitJoiningEnabled() const
{
    return m_permitJoiningEnabled;
}

void ZigbeeNetwork::setPermitJoiningEnabled(bool permitJoiningEnabled)
{
    if (m_permitJoiningEnabled == permitJoiningEnabled)
        return;

    m_permitJoiningEnabled = permitJoiningEnabled;
    emit permitJoiningEnabledChanged();
}

uint ZigbeeNetwork::permitJoiningDuration() const
{
    return m_permitJoiningDuration;
}

void ZigbeeNetwork::setPermitJoiningDuration(uint permitJoiningDuration)
{
    if (m_permitJoiningDuration == permitJoiningDuration)
        return;

    m_permitJoiningDuration = permitJoiningDuration;
    emit permitJoiningDurationChanged();
}

uint ZigbeeNetwork::permitJoiningRemaining() const
{
    return m_permitJoiningRemaining;
}

void ZigbeeNetwork::setPermitJoiningRemaining(uint permitJoiningRemaining)
{
    if (m_permitJoiningRemaining == permitJoiningRemaining)
        return;

    m_permitJoiningRemaining = permitJoiningRemaining;
    emit permitJoiningRemainingChanged();    

    if (m_permitJoinTimer->isActive())
        m_permitJoinTimer->stop();

    if (m_permitJoiningRemaining != 0) {
        m_permitJoinTimer->start();
    }
}

QString ZigbeeNetwork::backend() const
{
    return m_backend;
}

void ZigbeeNetwork::setBackend(const QString &backend)
{
    if (m_backend == backend)
        return;

    m_backend = backend;
    emit backendChanged();
}

ZigbeeNetwork::ZigbeeNetworkState ZigbeeNetwork::networkState() const
{
    return m_networkState;
}

void ZigbeeNetwork::setNetworkState(ZigbeeNetwork::ZigbeeNetworkState networkState)
{
    if (m_networkState == networkState)
        return;

    m_networkState = networkState;
    emit networkStateChanged();
}

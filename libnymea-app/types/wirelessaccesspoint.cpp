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

#include "wirelessaccesspoint.h"

#include <QDebug>

WirelessAccessPoint::WirelessAccessPoint(QObject *parent):
    QObject(parent)
{

}

QString WirelessAccessPoint::ssid() const
{
    return m_ssid;
}

void WirelessAccessPoint::setSsid(const QString ssid)
{
    if (m_ssid == ssid)
        return;

    m_ssid = ssid;
    emit ssidChanged(m_ssid);
}

QString WirelessAccessPoint::macAddress() const
{
    return m_macAddress;
}

void WirelessAccessPoint::setMacAddress(const QString &macAddress)
{
    if (m_macAddress == macAddress)
        return;

    m_macAddress = macAddress;
    emit macAddressChanged(m_macAddress);
}

QString WirelessAccessPoint::hostAddress() const
{
    return m_hostAddress;
}

void WirelessAccessPoint::setHostAddress(const QString &hostAddress)
{
    if (m_hostAddress == hostAddress)
        return;

    m_hostAddress = hostAddress;
    emit hostAddressChanged(m_hostAddress);
}

int WirelessAccessPoint::signalStrength() const
{
    return m_signalStrength;
}

void WirelessAccessPoint::setSignalStrength(int signalStrength)
{
    if (m_signalStrength == signalStrength)
        return;

    m_signalStrength = signalStrength;
    emit signalStrengthChanged(m_signalStrength);
}

bool WirelessAccessPoint::isProtected() const
{
    return m_isProtected;
}

void WirelessAccessPoint::setProtected(bool isProtected)
{
    if (m_isProtected == isProtected)
        return;

    m_isProtected = isProtected;
    emit isProtectedChanged(m_isProtected);

}

double WirelessAccessPoint::frequency() const
{
    return m_frequency;
}

void WirelessAccessPoint::setFrequency(double frequency)
{
    if (!qFuzzyCompare(m_frequency,frequency)) {
        m_frequency = frequency;
        emit frequencyChanged();
    }
}

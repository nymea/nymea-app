/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *                                                                         *
 *  Copyright (C) 2018 Simon Stuerz <simon.stuerz@guh.io>                  *
 *                                                                         *
 *  This file is part of mea                                               *
 *                                                                         *
 *  This library is free software; you can redistribute it and/or          *
 *  modify it under the terms of the GNU Lesser General Public             *
 *  License as published by the Free Software Foundation; either           *
 *  version 2.1 of the License, or (at your option) any later version.     *
 *                                                                         *
 *  This library is distributed in the hope that it will be useful,        *
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of         *
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU      *
 *  Lesser General Public License for more details.                        *
 *                                                                         *
 *  You should have received a copy of the GNU Lesser General Public       *
 *  License along with this library; If not, see                           *
 *  <http://www.gnu.org/licenses/>.                                        *
 *                                                                         *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#include "wirelessaccesspoint.h"

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
    m_ssid = ssid;
}

QString WirelessAccessPoint::macAddress() const
{
    return m_macAddress;
}

void WirelessAccessPoint::setMacAddress(const QString &macAddress)
{
    m_macAddress = macAddress;
}

int WirelessAccessPoint::signalStrength() const
{
    return m_signalStrength;
}

void WirelessAccessPoint::setSignalStrength(const int &signalStrength)
{
    m_signalStrength = signalStrength;
}

bool WirelessAccessPoint::isProtected() const
{
    return m_isProtected;
}

void WirelessAccessPoint::setProtected(const bool &isProtected)
{
    m_isProtected = isProtected;
}

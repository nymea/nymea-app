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

#ifndef WIRELESSACCESSPOINT_H
#define WIRELESSACCESSPOINT_H

#include <QObject>
#include <QString>

class WirelessAccessPoint : public QObject
{
    Q_OBJECT

public:
    WirelessAccessPoint(QObject *parent = 0);

    QString ssid() const;
    void setSsid(const QString ssid);

    QString macAddress() const;
    void setMacAddress(const QString &macAddress);

    int signalStrength() const;
    void setSignalStrength(const int &signalStrength);

    bool isProtected() const;
    void setProtected(const bool &isProtected);

    bool selectedNetwork() const;
    void setSelectedNetwork(bool selected);

private:
    QString m_ssid;
    QString m_macAddress;
    int m_signalStrength;
    bool m_isProtected;
    bool m_selectedNetwork;

};

#endif // WIRELESSACCESSPOINT_H

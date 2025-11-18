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

#ifndef WIRELESSACCESSPOINT_H
#define WIRELESSACCESSPOINT_H

#include <QObject>
#include <QString>

class WirelessAccessPoint : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString ssid READ ssid NOTIFY ssidChanged)
    Q_PROPERTY(QString macAddress READ macAddress NOTIFY macAddressChanged)
    Q_PROPERTY(QString hostAddress READ hostAddress NOTIFY hostAddressChanged)
    Q_PROPERTY(int signalStrength READ signalStrength NOTIFY signalStrengthChanged)
    Q_PROPERTY(bool isProtected READ isProtected NOTIFY isProtectedChanged)
    Q_PROPERTY(double frequency READ frequency NOTIFY frequencyChanged)

public:
    WirelessAccessPoint(QObject *parent = nullptr);

    QString ssid() const;
    void setSsid(const QString ssid);

    QString macAddress() const;
    void setMacAddress(const QString &macAddress);

    QString hostAddress() const;
    void setHostAddress(const QString &hostAddress);

    int signalStrength() const;
    void setSignalStrength(int signalStrength);

    bool isProtected() const;
    void setProtected(bool isProtected);

    double frequency() const;
    void setFrequency(double frequency);

signals:
    void ssidChanged(const QString &ssid);
    void macAddressChanged(const QString &macAddress);
    void hostAddressChanged(const QString &hostAddress);
    void signalStrengthChanged(int signalStrength);
    void isProtectedChanged(bool isProtected);
    void frequencyChanged();

private:
    QString m_ssid;
    QString m_macAddress;
    QString m_hostAddress;
    int m_signalStrength = 0;
    bool m_isProtected = false;
    double m_frequency = 0;
};

#endif // WIRELESSACCESSPOINT_H

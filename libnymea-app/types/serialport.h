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

#ifndef SERIALPORT_H
#define SERIALPORT_H

#include <QObject>
#include <QVariant>

class SerialPort : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString systemLocation READ systemLocation CONSTANT)
    Q_PROPERTY(QString manufacturer READ manufacturer CONSTANT)
    Q_PROPERTY(QString description READ description CONSTANT)
    Q_PROPERTY(QString serialNumber READ serialNumber CONSTANT)

public:
    enum SerialPortParity {
        SerialPortParityNoParity = 0,
        SerialPortParityEvenParity = 2,
        SerialPortParityOddParity = 3,
        SerialPortParitySpaceParity = 4,
        SerialPortParityMarkParity = 5,
        SerialPortParityUnknownParity = -1
    };
    Q_ENUM(SerialPortParity)

    enum SerialPortDataBits {
        SerialPortDataBitsData5 = 5,
        SerialPortDataBitsData6 = 6,
        SerialPortDataBitsData7 = 7,
        SerialPortDataBitsData8 = 8,
        SerialPortDataBitsUnknownDataBits = -1
    };
    Q_ENUM(SerialPortDataBits)

    enum SerialPortStopBits {
        SerialPortStopBitsOneStop = 1,
        SerialPortStopBitsOneAndHalfStop = 3,
        SerialPortStopBitsTwoStop = 2,
        SerialPortStopBitsUnknownStopBits = -1
    };
    Q_ENUM(SerialPortStopBits)

    explicit SerialPort(const QString &systemLocation, const QString &manufacturer, const QString &description, const QString &serialNumber, QObject *parent = nullptr);

    QString systemLocation() const;
    QString manufacturer() const;
    QString description() const;
    QString serialNumber() const;

    static SerialPort *unpackSerialPort(const QVariantMap &serialPortMap, QObject *parent);
    static SerialPort::SerialPortParity stringToSerialPortParity(const QString &parityString);
    static SerialPort::SerialPortDataBits stringToSerialPortDataBits(const QString &dataBitsString);
    static SerialPort::SerialPortStopBits stringToSerialPortStopBits(const QString &stopBitsString);

private:
    QString m_systemLocation;
    QString m_manufacturer;
    QString m_description;
    QString m_serialNumber;

};

#endif // SERIALPORT_H

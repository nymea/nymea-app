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

#include "serialport.h"

SerialPort::SerialPort(const QString &systemLocation, const QString &manufacturer, const QString &description, const QString &serialNumber, QObject *parent) :
    QObject(parent),
    m_systemLocation(systemLocation),
    m_manufacturer(manufacturer),
    m_description(description),
    m_serialNumber(serialNumber)
{

}

QString SerialPort::systemLocation() const
{
    return m_systemLocation;
}

QString SerialPort::manufacturer() const
{
    return m_manufacturer;
}

QString SerialPort::description() const
{
    return m_description;
}

QString SerialPort::serialNumber() const
{
    return m_serialNumber;
}

SerialPort *SerialPort::unpackSerialPort(const QVariantMap &serialPortMap, QObject *parent)
{
    return new SerialPort(serialPortMap.value("systemLocation").toString(),
                          serialPortMap.value("manufacturer").toString(),
                          serialPortMap.value("description").toString(),
                          serialPortMap.value("serialNumber").toString(), parent);
}

SerialPort::SerialPortParity SerialPort::stringToSerialPortParity(const QString &parityString)
{
    if (parityString == "SerialPortParityNoParity") {
        return SerialPort::SerialPortParityNoParity;
    } else if (parityString == "SerialPortParityEvenParity") {
        return SerialPort::SerialPortParityEvenParity;
    } else if (parityString == "SerialPortParityOddParity") {
        return SerialPort::SerialPortParityOddParity;
    } else if (parityString == "SerialPortParitySpaceParity") {
        return SerialPort::SerialPortParitySpaceParity;
    } else if (parityString == "SerialPortParityMarkParity") {
        return SerialPort::SerialPortParityMarkParity;
    }

    return SerialPort::SerialPortParityUnknownParity;
}

SerialPort::SerialPortDataBits SerialPort::stringToSerialPortDataBits(const QString &dataBitsString)
{
    if (dataBitsString == "SerialPortDataBitsData5") {
        return SerialPort::SerialPortDataBitsData5;
    } else if (dataBitsString == "SerialPortDataBitsData6") {
        return SerialPort::SerialPortDataBitsData6;
    } else if (dataBitsString == "SerialPortDataBitsData7") {
        return SerialPort::SerialPortDataBitsData7;
    } else if (dataBitsString == "SerialPortDataBitsData8") {
        return SerialPort::SerialPortDataBitsData8;
    }

    return SerialPort::SerialPortDataBitsUnknownDataBits;
}

SerialPort::SerialPortStopBits SerialPort::stringToSerialPortStopBits(const QString &stopBitsString)
{
    if (stopBitsString == "SerialPortStopBitsOneStop") {
        return SerialPort::SerialPortStopBitsOneStop;
    } else if (stopBitsString == "SerialPortStopBitsOneAndHalfStop") {
        return SerialPort::SerialPortStopBitsOneAndHalfStop;
    } else if (stopBitsString == "SerialPortStopBitsTwoStop") {
        return SerialPort::SerialPortStopBitsTwoStop;
    }

    return SerialPort::SerialPortStopBitsUnknownStopBits;
}

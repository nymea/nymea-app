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

#include "modbusrtumaster.h"

ModbusRtuMaster::ModbusRtuMaster(QObject *parent) : QObject(parent)
{

}

QUuid ModbusRtuMaster::modbusUuid() const
{
    return m_modbusUuid;
}

void ModbusRtuMaster::setModbusUuid(const QUuid &modbusUuid)
{
    m_modbusUuid = modbusUuid;
}

QString ModbusRtuMaster::serialPort() const
{
    return m_serialPort;
}

void ModbusRtuMaster::setSerialPort(const QString &serialPort)
{
    if (m_serialPort == serialPort)
        return;

    m_serialPort = serialPort;
    emit serialPortChanged(m_serialPort);
}

qint32 ModbusRtuMaster::baudrate() const
{
    return m_baudrate;
}

void ModbusRtuMaster::setBaudrate(qint32 baudrate)
{
    if (m_baudrate == baudrate)
        return;

    m_baudrate = baudrate;
    emit baudrateChanged(m_baudrate);
}

SerialPort::SerialPortParity ModbusRtuMaster::parity() const
{
    return m_parity;
}

void ModbusRtuMaster::setParity(SerialPort::SerialPortParity parity)
{
    if (m_parity == parity)
        return;

    m_parity = parity;
    emit parityChanged(m_parity);
}

SerialPort::SerialPortDataBits ModbusRtuMaster::dataBits() const
{
    return m_dataBits;
}

void ModbusRtuMaster::setDataBits(SerialPort::SerialPortDataBits dataBits)
{
    if (m_dataBits == dataBits)
        return;

    m_dataBits = dataBits;
    emit dataBitsChanged(m_dataBits);
}

SerialPort::SerialPortStopBits ModbusRtuMaster::stopBits() const
{
    return m_stopBits;
}

void ModbusRtuMaster::setStopBits(SerialPort::SerialPortStopBits stopBits)
{
    if (m_stopBits == stopBits)
        return;

    m_stopBits = stopBits;
    emit stopBitsChanged(m_stopBits);
}

uint ModbusRtuMaster::numberOfRetries() const
{
    return m_numberOfRetries;
}

void ModbusRtuMaster::setNumberOfRetries(uint numberOfRetries)
{
    if (m_numberOfRetries == numberOfRetries)
        return;

    m_numberOfRetries = numberOfRetries;
    emit numberOfRetriesChanged(m_numberOfRetries);
}

uint ModbusRtuMaster::timeout() const
{
    return m_timeout;
}

void ModbusRtuMaster::setTimeout(uint timeout)
{
    if (m_timeout == timeout)
        return;

    m_timeout = timeout;
    emit timeoutChanged(m_timeout);
}

bool ModbusRtuMaster::connected() const
{
    return m_connected;
}

void ModbusRtuMaster::setConnected(bool connected)
{
    if (m_connected == connected)
        return;

    m_connected = connected;
    emit connectedChanged(m_connected);
}

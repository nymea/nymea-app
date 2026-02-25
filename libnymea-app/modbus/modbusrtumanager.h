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

#ifndef MODBUSRTUMANAGER_H
#define MODBUSRTUMANAGER_H

#include <QObject>

#include "types/serialports.h"

#include "engine.h"
#include "modbusrtumasters.h"

class ModbusRtuMaster;

class ModbusRtuManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(Engine *engine READ engine WRITE setEngine NOTIFY engineChanged)
    Q_PROPERTY(SerialPorts *serialPorts READ serialPorts CONSTANT)
    Q_PROPERTY(ModbusRtuMasters *modbusRtuMasters READ modbusRtuMasters CONSTANT)
    Q_PROPERTY(bool supported READ supported NOTIFY supportedChanged)

public:
    explicit ModbusRtuManager(QObject *parent = nullptr);
    ~ModbusRtuManager();

    Engine *engine() const;
    void setEngine(Engine *engine);

    bool supported() const;

    SerialPorts *serialPorts() const;
    ModbusRtuMasters *modbusRtuMasters() const;

    Q_INVOKABLE int addModbusRtuMaster(const QString &serialPort, qint32 baudrate, SerialPort::SerialPortParity parity, SerialPort::SerialPortDataBits dataBits, SerialPort::SerialPortStopBits stopBits, int numberOfRetries, int timeout);
    Q_INVOKABLE int removeModbusRtuMaster(const QUuid &modbusUuid);
    Q_INVOKABLE int reconfigureModbusRtuMaster(const QUuid &modbusUuid, const QString &serialPort, qint32 baudrate, SerialPort::SerialPortParity parity, SerialPort::SerialPortDataBits dataBits, SerialPort::SerialPortStopBits stopBits, int numberOfRetries, int timeout);

signals:
    void engineChanged();
    void supportedChanged(bool supported);
    void addModbusRtuMasterReply(int commandId, const QString &error, const QUuid &modbusUuid);
    void removeModbusRtuMasterReply(int commandId, const QString &error);
    void reconfigureModbusRtuMasterReply(int commandId, const QString &error);

private:
    Engine* m_engine = nullptr;
    SerialPorts *m_serialPorts = nullptr;
    ModbusRtuMasters *m_modbusRtuMasters = nullptr;
    bool m_supported = false;

    void init();

    ModbusRtuMaster *unpackModbusRtuMaster(const QVariantMap &modbusRtuMasterMap);

    Q_INVOKABLE void notificationReceived(const QVariantMap &notification);

    Q_INVOKABLE void getSerialPortsResponse(int commandId, const QVariantMap &params);
    Q_INVOKABLE void getModbusRtuMastersResponse(int commandId, const QVariantMap &params);
    Q_INVOKABLE void addModbusRtuMasterResponse(int commandId, const QVariantMap &params);
    Q_INVOKABLE void removeModbusRtuMasterResponse(int commandId, const QVariantMap &params);
    Q_INVOKABLE void reconfigureModbusRtuMasterResponse(int commandId, const QVariantMap &params);


};

#endif // MODBUSRTUMANAGER_H

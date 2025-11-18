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

#include "modbusrtumanager.h"
#include "engine.h"
#include "modbusrtumaster.h"
#include "modbusrtumasters.h"

#include "jsonrpc/jsonrpcclient.h"

#include <QMetaEnum>

ModbusRtuManager::ModbusRtuManager(QObject *parent) :
    QObject(parent),
    m_serialPorts(new SerialPorts(this)),
    m_modbusRtuMasters(new ModbusRtuMasters(this))
{
    qRegisterMetaType<SerialPort::SerialPortParity>();
    qRegisterMetaType<SerialPort::SerialPortDataBits>();
    qRegisterMetaType<SerialPort::SerialPortStopBits>();
}

ModbusRtuManager::~ModbusRtuManager()
{
    if (m_engine) {
        m_engine->jsonRpcClient()->unregisterNotificationHandler(this);
    }
}

Engine *ModbusRtuManager::engine() const
{
    return m_engine;
}

void ModbusRtuManager::setEngine(Engine *engine)
{
    if (m_engine == engine)
        return;

    if (m_engine) {
        m_engine->jsonRpcClient()->unregisterNotificationHandler(this);
    }

    m_engine = engine;
    emit engineChanged();

    if (m_engine) {
        init();
    }
}

bool ModbusRtuManager::supported() const
{
    return m_supported;
}

SerialPorts *ModbusRtuManager::serialPorts() const
{
    return m_serialPorts;
}

ModbusRtuMasters *ModbusRtuManager::modbusRtuMasters() const
{
    return m_modbusRtuMasters;
}

int ModbusRtuManager::addModbusRtuMaster(const QString &serialPort, qint32 baudrate, SerialPort::SerialPortParity parity, SerialPort::SerialPortDataBits dataBits, SerialPort::SerialPortStopBits stopBits, int numberOfRetries, int timeout)
{
    QVariantMap params;
    params.insert("serialPort", serialPort);
    params.insert("baudrate", baudrate);
    params.insert("parity", QMetaEnum::fromType<SerialPort::SerialPortParity>().valueToKey(parity));
    params.insert("dataBits", QMetaEnum::fromType<SerialPort::SerialPortDataBits>().valueToKey(dataBits));
    params.insert("stopBits", QMetaEnum::fromType<SerialPort::SerialPortStopBits>().valueToKey(stopBits));
    params.insert("numberOfRetries", numberOfRetries);
    params.insert("timeout", timeout);

    return m_engine->jsonRpcClient()->sendCommand("ModbusRtu.AddModbusRtuMaster", params, this, "addModbusRtuMasterResponse");
}

int ModbusRtuManager::removeModbusRtuMaster(const QUuid &modbusUuid)
{
    QVariantMap params;
    params.insert("modbusUuid", modbusUuid);
    return m_engine->jsonRpcClient()->sendCommand("ModbusRtu.RemoveModbusRtuMaster", params, this, "removeModbusRtuMasterResponse");
}

int ModbusRtuManager::reconfigureModbusRtuMaster(const QUuid &modbusUuid, const QString &serialPort, qint32 baudrate, SerialPort::SerialPortParity parity, SerialPort::SerialPortDataBits dataBits, SerialPort::SerialPortStopBits stopBits, int numberOfRetries, int timeout)
{
    QVariantMap params;
    params.insert("modbusUuid", modbusUuid);
    params.insert("serialPort", serialPort);
    params.insert("baudrate", baudrate);
    params.insert("parity", QMetaEnum::fromType<SerialPort::SerialPortParity>().valueToKey(parity));
    params.insert("dataBits", QMetaEnum::fromType<SerialPort::SerialPortDataBits>().valueToKey(dataBits));
    params.insert("stopBits", QMetaEnum::fromType<SerialPort::SerialPortStopBits>().valueToKey(stopBits));
    params.insert("numberOfRetries", numberOfRetries);
    params.insert("timeout", timeout);

    return m_engine->jsonRpcClient()->sendCommand("ModbusRtu.ReconfigureModbusRtuMaster", params, this, "reconfigureModbusRtuMasterResponse");
}

void ModbusRtuManager::init()
{
    m_serialPorts->clear();
    m_modbusRtuMasters->clear();

    m_engine->jsonRpcClient()->registerNotificationHandler(this, "ModbusRtu", "notificationReceived");
    m_engine->jsonRpcClient()->sendCommand("ModbusRtu.GetModbusRtuMasters", this, "getModbusRtuMastersResponse");
}

ModbusRtuMaster *ModbusRtuManager::unpackModbusRtuMaster(const QVariantMap &modbusRtuMasterMap)
{
    ModbusRtuMaster *modbusMaster = new ModbusRtuMaster(this);
    modbusMaster->setModbusUuid(modbusRtuMasterMap.value("modbusUuid").toUuid());
    modbusMaster->setConnected(modbusRtuMasterMap.value("connected").toBool());
    modbusMaster->setSerialPort(modbusRtuMasterMap.value("serialPort").toString());
    modbusMaster->setBaudrate(modbusRtuMasterMap.value("baudrate").toInt());
    modbusMaster->setParity(SerialPort::stringToSerialPortParity(modbusRtuMasterMap.value("parity").toString()));
    modbusMaster->setStopBits(SerialPort::stringToSerialPortStopBits(modbusRtuMasterMap.value("stopBits").toString()));
    modbusMaster->setDataBits(SerialPort::stringToSerialPortDataBits(modbusRtuMasterMap.value("dataBits").toString()));
    modbusMaster->setNumberOfRetries(modbusRtuMasterMap.value("numberOfRetries").toUInt());
    modbusMaster->setTimeout(modbusRtuMasterMap.value("timeout").toUInt());
    return modbusMaster;
}

void ModbusRtuManager::notificationReceived(const QVariantMap &notification)
{
    QString notificationString = notification.value("notification").toString();
    qDebug() << "Received notification" << notificationString << endl << notification;
    if (notificationString == "ModbusRtu.SerialPortAdded") {
        QVariantMap serialPortMap = notification.value("params").toMap().value("serialPort").toMap();
        m_serialPorts->addSerialPort(SerialPort::unpackSerialPort(serialPortMap, m_serialPorts));
        return;
    }

    if (notificationString == "ModbusRtu.SerialPortRemoved") {
        QVariantMap serialPortMap = notification.value("params").toMap().value("serialPort").toMap();
        SerialPort *serialPort = SerialPort::unpackSerialPort(serialPortMap, this);
        m_serialPorts->removeSerialPort(serialPort->systemLocation());
        serialPort->deleteLater();
        return;
    }

    if (notificationString == "ModbusRtu.ModbusRtuMasterAdded") {
        QVariantMap modbusRtuMasterMap = notification.value("params").toMap().value("modbusRtuMaster").toMap();
        ModbusRtuMaster *modbusRtuMaster = unpackModbusRtuMaster(modbusRtuMasterMap);
        m_modbusRtuMasters->addModbusRtuMaster(modbusRtuMaster);
        return;
    }

    if (notificationString == "ModbusRtu.ModbusRtuMasterRemoved") {
        QUuid modbusUuid = notification.value("params").toMap().value("modbusUuid").toUuid();
        m_modbusRtuMasters->removeModbusRtuMaster(modbusUuid);
        return;
    }

    if (notificationString == "ModbusRtu.ModbusRtuMasterChanged") {
        QVariantMap modbusRtuMasterMap = notification.value("params").toMap().value("modbusRtuMaster").toMap();
        ModbusRtuMaster *modbusRtuMaster = unpackModbusRtuMaster(modbusRtuMasterMap);
        qDebug() << "Modbus master changed" << modbusRtuMaster;
        ModbusRtuMaster *currentModbusRtuMaster = m_modbusRtuMasters->getModbusRtuMaster(modbusRtuMaster->modbusUuid());
        if (!currentModbusRtuMaster) {
            qWarning() << "Got modbus changed signal but there is no such modbus interface. Ignoring notification";
            return;
        }

        qDebug() << "Update modbus values" << currentModbusRtuMaster;
        currentModbusRtuMaster->setSerialPort(modbusRtuMaster->serialPort());
        currentModbusRtuMaster->setBaudrate(modbusRtuMaster->baudrate());
        currentModbusRtuMaster->setParity(modbusRtuMaster->parity());
        currentModbusRtuMaster->setDataBits(modbusRtuMaster->dataBits());
        currentModbusRtuMaster->setStopBits(modbusRtuMaster->stopBits());
        currentModbusRtuMaster->setNumberOfRetries(modbusRtuMaster->numberOfRetries());
        currentModbusRtuMaster->setTimeout(modbusRtuMaster->timeout());
        currentModbusRtuMaster->setConnected(modbusRtuMaster->connected());
        modbusRtuMaster->deleteLater();
        return;
    }
}

void ModbusRtuManager::getSerialPortsResponse(int commandId, const QVariantMap &params)
{
    qDebug() << "Get serial ports response" << commandId << params;
    m_serialPorts->clear();

    foreach (const QVariant &serialPortVariant, params.value("serialPorts").toList()) {
        m_serialPorts->addSerialPort(SerialPort::unpackSerialPort(serialPortVariant.toMap(), m_serialPorts));
    }
}

void ModbusRtuManager::getModbusRtuMastersResponse(int commandId, const QVariantMap &params)
{
    qDebug() << "Get modbus RTU masters response" << commandId << params;

    QString error = params.value("modbusError").toString();
    if (error == "ModbusRtuErrorNoError") {
        m_supported = true;
        emit supportedChanged(m_supported);

        m_modbusRtuMasters->clear();
        foreach (const QVariant &modbusRtuMasterVariant, params.value("modbusRtuMasters").toList()) {
            m_modbusRtuMasters->addModbusRtuMaster(unpackModbusRtuMaster(modbusRtuMasterVariant.toMap()));
        }

        m_engine->jsonRpcClient()->sendCommand("ModbusRtu.GetSerialPorts", this, "getSerialPortsResponse");
    } else {
        qWarning() << "Modbus is not supported on this platform";
    }
}

void ModbusRtuManager::addModbusRtuMasterResponse(int commandId, const QVariantMap &params)
{
    qDebug() << "Add modbus RTU master response" << commandId << params;
    emit addModbusRtuMasterReply(commandId, params.value("modbusError").toString(), params.value("modbusUuid").toUuid());
}

void ModbusRtuManager::removeModbusRtuMasterResponse(int commandId, const QVariantMap &params)
{
    qDebug() << "Remove modbus RTU master response" << commandId << params;
    emit removeModbusRtuMasterReply(commandId, params.value("modbusError").toString());
}

void ModbusRtuManager::reconfigureModbusRtuMasterResponse(int commandId, const QVariantMap &params)
{
    qDebug() << "Reconfigure modbus RTU master response" << commandId << params;
    emit reconfigureModbusRtuMasterReply(commandId, params.value("modbusError").toString());
}

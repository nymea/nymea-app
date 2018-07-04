/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *                                                                         *
 *  Copyright (C) 2018 Simon Stuerz <simon.stuerz@guh.io>                  *
 *                                                                         *
 *  This file is part of nymea:app                                         *
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

#include "bluetoothinterface.h"

#include <QUrl>
#include <QDebug>

BluetoothInterface::BluetoothInterface(QObject *parent) :
    NymeaInterface(parent)
{
    m_socket = new QBluetoothSocket(QBluetoothServiceInfo::RfcommProtocol);

    QObject::connect(m_socket, &QBluetoothSocket::connected, this, &BluetoothInterface::onConnected);
    QObject::connect(m_socket, &QBluetoothSocket::disconnected, this, &BluetoothInterface::onDisconnected);
    QObject::connect(m_socket, &QBluetoothSocket::readyRead, this, &BluetoothInterface::onDataReady);
}

QStringList BluetoothInterface::supportedSchemes() const
{
    return {"rfcom"};
}

void BluetoothInterface::connect(const QUrl &url)
{
    if (url.scheme() != "rfcom") {
        qWarning() << "BluetoothInterface: Cannot connect. Invalid scheme in url" << url.toString();
        return;
    }

    QString macAddress = url.host();
    qDebug() << "Connecting to bluetooth server" << macAddress;
    m_socket->connectToService(QBluetoothAddress(macAddress), QBluetoothUuid(QUuid("997936b5-d2cd-4c57-b41b-c6048320cd2b")));
}

void BluetoothInterface::disconnect()
{
    m_socket->close();
}

NymeaInterface::ConnectionState BluetoothInterface::connectionState() const
{
    switch (m_socket->state()) {
    case QBluetoothSocket::ConnectedState:
        return NymeaInterface::ConnectionStateConnected;
    case QBluetoothSocket::ConnectingState:
    case QBluetoothSocket::ServiceLookupState:
        return NymeaInterface::ConnectionStateConnecting;
    default:
        return NymeaInterface::ConnectionStateDisconnected;
    }
}

void BluetoothInterface::sendData(const QByteArray &data)
{
    m_socket->write(data + '\n');
}

void BluetoothInterface::onServiceFound(const QBluetoothServiceInfo &service)
{
    m_service = service;
    if (m_socket->isOpen())
        return;

    qDebug() << "BluetoothInterface: Connecting to service"  << m_service.serviceName();
    m_socket->connectToService(m_service);
}

void BluetoothInterface::onConnected()
{
    qDebug() << "BluetoothInterface: connected" << m_socket->peerName() << m_socket->peerAddress();
    emit connected();
}

void BluetoothInterface::onDisconnected()
{
    qDebug() << "BluetoothInterface: disconnected" << m_socket->peerName() << m_socket->peerAddress();
    emit disconnected();
}

void BluetoothInterface::onDataReady()
{
    QByteArray message;
    while (m_socket->canReadLine()) {
        QByteArray dataLine = m_socket->readLine();
        message.append(dataLine);
        if (dataLine.endsWith('\n')) {
            emit dataReady(message);
            message.clear();
        }
    }
}

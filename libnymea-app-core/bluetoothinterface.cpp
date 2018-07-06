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
#include <QUrlQuery>

BluetoothInterface::BluetoothInterface(QObject *parent) :
    NymeaInterface(parent)
{
    m_socket = new QBluetoothSocket(QBluetoothServiceInfo::RfcommProtocol);

    QObject::connect(m_socket, &QBluetoothSocket::connected, this, &BluetoothInterface::onConnected);
    QObject::connect(m_socket, &QBluetoothSocket::disconnected, this, &BluetoothInterface::onDisconnected);
    QObject::connect(m_socket, &QBluetoothSocket::readyRead, this, &BluetoothInterface::onDataReady);
    QObject::connect(m_socket, &QBluetoothSocket::stateChanged, this, &BluetoothInterface::onDataReady);
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

    QUrlQuery query(url);
    QString macAddressString = query.queryItemValue("mac");
    QString name = query.queryItemValue("name");
    QBluetoothAddress macAddress = QBluetoothAddress(macAddressString);

    qDebug() << "Connecting to bluetooth server" << name << macAddress.toString();
    m_socket->connectToService(macAddress, QBluetoothUuid(QUuid("997936b5-d2cd-4c57-b41b-c6048320cd2b")));
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
    qDebug() << "BluetoothInterface: send data:" << qUtf8Printable(data);
    m_socket->write(data);
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

void BluetoothInterface::onStateChanged(const QBluetoothSocket::SocketState &state)
{
    qDebug() << "BluetoothInterface" << state;
}

void BluetoothInterface::onDataReady()
{
    QByteArray data = m_socket->readAll();
    qDebug() << "BluetoothInterface: recived data:" << qUtf8Printable(data);
    emit dataReady(data);
}

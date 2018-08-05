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

#include "bluetoothtransport.h"

#include <QUrl>
#include <QDebug>
#include <QUrlQuery>

BluetoothTransport::BluetoothTransport(QObject *parent) :
    NymeaTransportInterface(parent)
{
    m_socket = new QBluetoothSocket(QBluetoothServiceInfo::RfcommProtocol);

    QObject::connect(m_socket, &QBluetoothSocket::connected, this, &BluetoothTransport::onConnected);
    QObject::connect(m_socket, &QBluetoothSocket::disconnected, this, &BluetoothTransport::onDisconnected);
    QObject::connect(m_socket, &QBluetoothSocket::readyRead, this, &BluetoothTransport::onDataReady);
    QObject::connect(m_socket, &QBluetoothSocket::stateChanged, this, &BluetoothTransport::onDataReady);
}

QStringList BluetoothTransport::supportedSchemes() const
{
    return {"rfcom"};
}

void BluetoothTransport::connect(const QUrl &url)
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

void BluetoothTransport::disconnect()
{
    m_socket->close();
}

NymeaTransportInterface::ConnectionState BluetoothTransport::connectionState() const
{
    switch (m_socket->state()) {
    case QBluetoothSocket::ConnectedState:
        return NymeaTransportInterface::ConnectionStateConnected;
    case QBluetoothSocket::ConnectingState:
    case QBluetoothSocket::ServiceLookupState:
        return NymeaTransportInterface::ConnectionStateConnecting;
    default:
        return NymeaTransportInterface::ConnectionStateDisconnected;
    }
}

void BluetoothTransport::sendData(const QByteArray &data)
{
    qDebug() << "BluetoothInterface: send data:" << qUtf8Printable(data);
    m_socket->write(data);
}

void BluetoothTransport::onServiceFound(const QBluetoothServiceInfo &service)
{
    m_service = service;
    if (m_socket->isOpen())
        return;

    qDebug() << "BluetoothInterface: Connecting to service"  << m_service.serviceName();
    m_socket->connectToService(m_service);
}

void BluetoothTransport::onConnected()
{
    qDebug() << "BluetoothInterface: connected" << m_socket->peerName() << m_socket->peerAddress();
    emit connected();
}

void BluetoothTransport::onDisconnected()
{
    qDebug() << "BluetoothInterface: disconnected" << m_socket->peerName() << m_socket->peerAddress();
    emit disconnected();
}

void BluetoothTransport::onStateChanged(const QBluetoothSocket::SocketState &state)
{
    qDebug() << "BluetoothInterface" << state;
}

void BluetoothTransport::onDataReady()
{
    QByteArray data = m_socket->readAll();
    qDebug() << "BluetoothInterface: recived data:" << qUtf8Printable(data);
    emit dataReady(data);
}

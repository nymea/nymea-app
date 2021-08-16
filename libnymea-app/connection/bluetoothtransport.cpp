/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
* Copyright 2013 - 2020, nymea GmbH
* Contact: contact@nymea.io
*
* This file is part of nymea.
* This project including source code and documentation is protected by
* copyright law, and remains the property of nymea GmbH. All rights, including
* reproduction, publication, editing and translation, are reserved. The use of
* this project is subject to the terms of a license agreement to be concluded
* with nymea GmbH in accordance with the terms of use of nymea GmbH, available
* under https://nymea.io/license
*
* GNU General Public License Usage
* Alternatively, this project may be redistributed and/or modified under the
* terms of the GNU General Public License as published by the Free Software
* Foundation, GNU version 3. This project is distributed in the hope that it
* will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty
* of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
* Public License for more details.
*
* You should have received a copy of the GNU General Public License along with
* this project. If not, see <https://www.gnu.org/licenses/>.
*
* For any further details and any questions please contact us under
* contact@nymea.io or see our FAQ/Licensing Information on
* https://nymea.io/license/faq
*
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

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

bool BluetoothTransport::connect(const QUrl &url)
{
    if (url.scheme() != "rfcom") {
        qWarning() << "BluetoothInterface: Cannot connect. Invalid scheme in url" << url.toString();
        return false;
    }
    m_url = url;

    QUrlQuery query(url);
    QString macAddressString = query.queryItemValue("mac");
    QString name = query.queryItemValue("name");
    QBluetoothAddress macAddress = QBluetoothAddress(macAddressString);

    qDebug() << "Connecting to bluetooth server" << name << macAddress.toString();
    m_socket->connectToService(macAddress, QBluetoothUuid(QUuid("997936b5-d2cd-4c57-b41b-c6048320cd2b")));
    return true;
}

QUrl BluetoothTransport::url() const
{
    return m_url;
}

void BluetoothTransport::disconnect()
{
    m_socket->close();
}

NymeaTransportInterface::ConnectionState BluetoothTransport::connectionState() const
{
    switch (m_socket->state()) {
    case QBluetoothSocket::SocketState::ConnectedState:
        return NymeaTransportInterface::ConnectionStateConnected;
    case QBluetoothSocket::SocketState::ConnectingState:
    case QBluetoothSocket::SocketState::ServiceLookupState:
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


NymeaTransportInterface *BluetoothTransportFactoy::createTransport(QObject *parent) const
{
    return new BluetoothTransport(parent);
}

QStringList BluetoothTransportFactoy::supportedSchemes() const
{
    return {"rfcom"};
}

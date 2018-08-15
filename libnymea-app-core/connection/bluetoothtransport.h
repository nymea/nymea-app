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

#ifndef BLUETOOTHTRANSPORT_H
#define BLUETOOTHTRANSPORT_H

#include <QObject>
#include <QBluetoothSocket>

#include "nymeatransportinterface.h"

class BluetoothTransport: public NymeaTransportInterface
{
    Q_OBJECT
public:
    explicit BluetoothTransport(QObject *parent = nullptr);

    QStringList supportedSchemes() const override;

    bool connect(const QUrl &url) override;
    void disconnect() override;
    ConnectionState connectionState() const override;
    void sendData(const QByteArray &data) override;

private:
    QBluetoothSocket *m_socket = nullptr;
    QBluetoothServiceInfo m_service;

private slots:
    void onServiceFound(const QBluetoothServiceInfo &service);
    void onConnected();
    void onDisconnected();
    void onStateChanged(const QBluetoothSocket::SocketState &state);
    void onDataReady();
};

#endif // BLUETOOTHTRANSPROT_H

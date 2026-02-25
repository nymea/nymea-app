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

#ifndef BLUETOOTHTRANSPORT_H
#define BLUETOOTHTRANSPORT_H

#include <QObject>
#include <QUrl>
#include <QBluetoothSocket>

#include "nymeatransportinterface.h"

class BluetoothTransportFactoy: public NymeaTransportInterfaceFactory
{
public:
    NymeaTransportInterface* createTransport(QObject *parent = nullptr) const override;
    QStringList supportedSchemes() const override;
};

class BluetoothTransport: public NymeaTransportInterface
{
    Q_OBJECT
public:
    explicit BluetoothTransport(QObject *parent = nullptr);

    bool connect(const QUrl &url) override;
    QUrl url() const override;
    void disconnect() override;
    ConnectionState connectionState() const override;
    void sendData(const QByteArray &data) override;

private:
    QUrl m_url;
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

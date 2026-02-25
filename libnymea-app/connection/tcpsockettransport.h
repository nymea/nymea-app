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

#ifndef TCPSOCKETTRANSPORT_H
#define TCPSOCKETTRANSPORT_H

#include "nymeatransportinterface.h"

#include <QObject>
#include <QSslSocket>
#include <QUrl>

class TcpSocketTransportFactory: public NymeaTransportInterfaceFactory
{
public:
    NymeaTransportInterface* createTransport(QObject *parent = nullptr) const override;
    QStringList supportedSchemes() const override;
};

class TcpSocketTransport: public NymeaTransportInterface
{
    Q_OBJECT
public:
    explicit TcpSocketTransport(QObject *parent = nullptr);

    bool connect(const QUrl &url) override;
    QUrl url() const override;
    ConnectionState connectionState() const override;
    void disconnect() override;
    void sendData(const QByteArray &data) override;
    void ignoreSslErrors(const QList<QSslError> &errors) override;
    bool isEncrypted() const override;
    QSslCertificate serverCertificate() const override;

private slots:
    void onConnected();
    void onEncrypted();
    void socketReadyRead();
    void onSocketStateChanged(const QAbstractSocket::SocketState &state);

private:
    QSslSocket m_socket;
    QUrl m_url;
};

#endif // TCPSOCKETTRANSPROT_H

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

#ifndef TUNNELPROXYTRANSPORT_H
#define TUNNELPROXYTRANSPORT_H

#include <QUrl>
#include <QObject>

#include "nymeatransportinterface.h"
#include "tunnelproxy/tunnelproxyremoteconnection.h"

class TunnelProxyTransportFactory: public NymeaTransportInterfaceFactory
{
public:
    NymeaTransportInterface* createTransport(QObject *parent = nullptr) const override;
    QStringList supportedSchemes() const override;
};


class TunnelProxyTransport : public NymeaTransportInterface
{
    Q_OBJECT
public:
    explicit TunnelProxyTransport(QObject *parent = nullptr);

    bool connect(const QUrl &url) override;
    QUrl url() const override;
    ConnectionState connectionState() const override;
    void disconnect() override;
    void sendData(const QByteArray &data) override;
    void ignoreSslErrors(const QList<QSslError> &errors) override;

    bool isEncrypted() const override;
    QSslCertificate serverCertificate() const override;

private slots:
    void onRemoteConnectionStateChanged(remoteproxyclient::TunnelProxyRemoteConnection::State state);
    void onRemoteConnectionErrorOccurred(QAbstractSocket::SocketError error);

private:
    QUrl m_url;
    remoteproxyclient::TunnelProxyRemoteConnection *m_remoteConnection = nullptr;

};

#endif // TUNNELPROXYTRANSPORT_H

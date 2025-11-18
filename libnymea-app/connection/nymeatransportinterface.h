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

#ifndef NYMEATRANSPORTINTERFACE_H
#define NYMEATRANSPORTINTERFACE_H

#include <QObject>
#include <QSslCertificate>
#include <QHostAddress>

class NymeaTransportInterface;

class NymeaTransportInterfaceFactory
{
public:
    virtual ~NymeaTransportInterfaceFactory() = default;
    virtual NymeaTransportInterface* createTransport(QObject* parent = nullptr) const = 0;

    virtual QStringList supportedSchemes() const = 0;
};

class NymeaTransportInterface : public QObject
{
    Q_OBJECT
public:
    enum ConnectionState {
        ConnectionStateDisconnected,
        ConnectionStateConnecting,
        ConnectionStateConnected
    };
    Q_ENUM(ConnectionState)

    explicit NymeaTransportInterface(QObject *parent = nullptr);
    virtual ~NymeaTransportInterface() = default;

    virtual bool connect(const QUrl &url) = 0;
    virtual QUrl url() const = 0;
    virtual void disconnect() = 0;
    virtual ConnectionState connectionState() const = 0;
    virtual void sendData(const QByteArray &data) = 0;
    virtual void ignoreSslErrors(const QList<QSslError> &errors) { Q_UNUSED(errors) }
    virtual bool isEncrypted() const { return false; }
    virtual QSslCertificate serverCertificate() const { return QSslCertificate(); }

signals:
    void connected();
    void disconnected();
    void error(QAbstractSocket::SocketError error);
    void sslErrors(const QList<QSslError> &errors);
    void dataReady(const QByteArray &data);
};

#endif // NYMEATRANSPORTINTERFACE_H

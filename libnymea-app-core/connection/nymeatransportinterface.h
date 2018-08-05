/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *                                                                         *
 *  Copyright (C) 2017 - 2018 Simon Stuerz <simon.stuerz@guh.io>           *
 *                                                                         *
 *  This file is part of nymea:app.                                        *
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

#ifndef NYMEATRANSPORTINTERFACE_H
#define NYMEATRANSPORTINTERFACE_H

#include <QObject>
#include <QSslCertificate>
#include <QHostAddress>

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

    virtual QStringList supportedSchemes() const = 0;

    virtual void connect(const QUrl &url) = 0;
    virtual void disconnect() = 0;
    virtual ConnectionState connectionState() const = 0;
    virtual void sendData(const QByteArray &data) = 0;
    virtual void ignoreSslErrors(const QList<QSslError> &errors) { Q_UNUSED(errors) }

signals:
    void connected();
    void disconnected();
    void error(QAbstractSocket::SocketError error);
    void sslErrors(const QList<QSslError> &errors);
    void dataReady(const QByteArray &data);
};

#endif // NYMEATRANSPORTINTERFACE_H

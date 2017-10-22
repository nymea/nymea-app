/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *                                                                         *
 *  Copyright (C) 2017 Simon Stuerz <simon.stuerz@guh.io>                  *
 *                                                                         *
 *  This file is part of guh-control.                                      *
 *                                                                         *
 *  guh-control is free software: you can redistribute it and/or modify    *
 *  it under the terms of the GNU General Public License as published by   *
 *  the Free Software Foundation, version 3 of the License.                *
 *                                                                         *
 *  guh-control is distributed in the hope that it will be useful,         *
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of         *
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the           *
 *  GNU General Public License for more details.                           *
 *                                                                         *
 *  You should have received a copy of the GNU General Public License      *
 *  along with guh-control. If not, see <http://www.gnu.org/licenses/>.    *
 *                                                                         *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#ifndef GUHINTERFACE_H
#define GUHINTERFACE_H

#include <QObject>
#include <QSslCertificate>
#include <QHostAddress>

class GuhInterface : public QObject
{
    Q_OBJECT
public:
    explicit GuhInterface(QObject *parent = 0);

    virtual QStringList supportedSchemes() const = 0;

    virtual void connect(const QUrl &url) = 0;
    virtual void disconnect() = 0;
    virtual bool isConnected() const = 0;
    virtual void sendData(const QByteArray &data) = 0;
    virtual void ignoreSslErrors(const QList<QSslError> &errors) = 0;

signals:
    void connected();
    void disconnected();
    void error(QAbstractSocket::SocketError error);
    void sslErrors(const QList<QSslError> &errors);
    void dataReady(const QByteArray &data);
};

#endif // GUHINTERFACE_H

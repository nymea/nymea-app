/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *                                                                         *
 *  Copyright (C) 2017 Simon Stuerz <simon.stuerz@guh.io>                  *
 *                                                                         *
 *  This file is part of mea.                                      *
 *                                                                         *
 *  mea is free software: you can redistribute it and/or modify    *
 *  it under the terms of the GNU General Public License as published by   *
 *  the Free Software Foundation, version 3 of the License.                *
 *                                                                         *
 *  mea is distributed in the hope that it will be useful,         *
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of         *
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the           *
 *  GNU General Public License for more details.                           *
 *                                                                         *
 *  You should have received a copy of the GNU General Public License      *
 *  along with mea. If not, see <http://www.gnu.org/licenses/>.    *
 *                                                                         *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#ifndef NYMEAINTERFACE_H
#define NYMEAINTERFACE_H

#include <QObject>
#include <QSslCertificate>
#include <QHostAddress>

class NymeaInterface : public QObject
{
    Q_OBJECT
public:
    explicit NymeaInterface(QObject *parent = 0);

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

#endif // NYMEAINTERFACE_H

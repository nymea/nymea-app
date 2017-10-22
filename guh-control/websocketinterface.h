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

#ifndef WEBSOCKETINTERFACE_H
#define WEBSOCKETINTERFACE_H

#include <QObject>
#include <QWebSocket>

#include "guhinterface.h"

class WebsocketInterface : public GuhInterface
{
    Q_OBJECT
public:
    explicit WebsocketInterface(QObject *parent = 0);

    QStringList supportedSchemes() const override;

    void connect(const QUrl &url) override;
    bool isConnected() const override;
    void disconnect() override;
    void sendData(const QByteArray &data) override;
    void ignoreSslErrors(const QList<QSslError> &errors);

private:
    QWebSocket *m_socket;

private slots:
    void onTextMessageReceived(const QString &data);
};

#endif // WEBSOCKETINTERFACE_H

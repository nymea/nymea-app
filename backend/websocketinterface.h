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
    Q_PROPERTY(QString url READ url WRITE setUrl NOTIFY urlChanged)

public:
    explicit WebsocketInterface(QObject *parent = 0);

    void sendData(const QByteArray &data) override;
    void sendRequest(const QVariantMap &request) override;

    void setUrl(const QString &url);
    QString url() const;

private:
    QWebSocket *m_socket;
    QString m_urlString;

signals:
    void urlChanged();
    void disconnected();
    void connecting();
    void connectionFailed();
    void websocketError(const QString &errorString);

public slots:
    Q_INVOKABLE void enable() override;
    Q_INVOKABLE void disable() override;

private slots:
    void onConnected();
    void onDisconnected();
    void onTextMessageReceived(const QString &data);
    void onError(QAbstractSocket::SocketError error);
};

#endif // WEBSOCKETINTERFACE_H

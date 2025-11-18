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

#ifndef UPNPDISCOVERY_H
#define UPNPDISCOVERY_H

#include <QUdpSocket>
#include <QHostAddress>
#include <QNetworkReply>
#include <QNetworkAccessManager>
#include <QNetworkConfigurationManager>
#include <QTimer>

#include "../nymeahost.h"
#include "../nymeahosts.h"

class UpnpDiscovery : public QObject
{
    Q_OBJECT
public:
    explicit UpnpDiscovery(NymeaHosts *nymeaHosts, QObject *parent = nullptr);

    bool discovering() const;

    bool available() const;

    Q_INVOKABLE void discover();
    Q_INVOKABLE void stopDiscovery();

signals:
    void discoveringChanged();
    void availableChanged();
    void nymeaHostsChanged();

private slots:
    void updateInterfaces();
    void writeDiscoveryPacket();
    void error(QAbstractSocket::SocketError error);
    void readData();
    void networkReplyFinished(QNetworkReply *reply);

private:
    QHash<QHostAddress, QUdpSocket*> m_sockets;
    QNetworkAccessManager *m_networkAccessManager;
    QNetworkConfigurationManager *m_networkConfigurationManager;

    QTimer m_repeatTimer;

    NymeaHosts *m_nymeaHosts;

    QHash<QNetworkReply *, QHostAddress> m_runningReplies;
    QList<QUrl> m_foundDevices;

};

#endif // UPNPDISCOVERY_H

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *                                                                         *
 *  Copyright (C) 2015 Simon Stuerz <stuerz.simon@gmail.com>               *
 *                                                                         *
 *  This file is part of mea.                                       *
 *                                                                         *
 *  mea is free software: you can redistribute it and/or modify     *
 *  it under the terms of the GNU General Public License as published by   *
 *  the Free Software Foundation, version 3 of the License.                *
 *                                                                         *
 *  mea is distributed in the hope that it will be useful,          *
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of         *
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the           *
 *  GNU General Public License for more details.                           *
 *                                                                         *
 *  You should have received a copy of the GNU General Public License      *
 *  along with mea. If not, see <http://www.gnu.org/licenses/>.     *
 *                                                                         *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#ifndef UPNPDISCOVERY_H
#define UPNPDISCOVERY_H

#include <QUdpSocket>
#include <QHostAddress>
#include <QNetworkReply>
#include <QNetworkAccessManager>
#include <QTimer>

#include "discoverydevice.h"
#include "discoverymodel.h"

class UpnpDiscovery : public QObject
{
    Q_OBJECT
public:
    explicit UpnpDiscovery(DiscoveryModel *discoveryModel, QObject *parent = 0);

    bool discovering() const;

    bool available() const;

    Q_INVOKABLE void discover();
    Q_INVOKABLE void stopDiscovery();

private:
    QList<QUdpSocket*> m_sockets;
    QNetworkAccessManager *m_networkAccessManager;

    QTimer m_repeatTimer;

    DiscoveryModel *m_discoveryModel;

    QHash<QNetworkReply *, QHostAddress> m_runningReplies;
    QList<QUrl> m_foundDevices;

signals:
    void discoveringChanged();
    void availableChanged();
    void discoveryModelChanged();

private slots:
    void writeDiscoveryPacket();
    void error(QAbstractSocket::SocketError error);
    void readData();
    void networkReplyFinished(QNetworkReply *reply);
};

#endif // UPNPDISCOVERY_H

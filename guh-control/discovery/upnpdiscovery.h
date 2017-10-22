/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *                                                                         *
 *  Copyright (C) 2015 Simon Stuerz <stuerz.simon@gmail.com>               *
 *                                                                         *
 *  This file is part of guh-ubuntu.                                       *
 *                                                                         *
 *  guh-ubuntu is free software: you can redistribute it and/or modify     *
 *  it under the terms of the GNU General Public License as published by   *
 *  the Free Software Foundation, version 3 of the License.                *
 *                                                                         *
 *  guh-ubuntu is distributed in the hope that it will be useful,          *
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of         *
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the           *
 *  GNU General Public License for more details.                           *
 *                                                                         *
 *  You should have received a copy of the GNU General Public License      *
 *  along with guh-ubuntu. If not, see <http://www.gnu.org/licenses/>.     *
 *                                                                         *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#ifndef UPNPDISCOVERY_H
#define UPNPDISCOVERY_H

#include <QUdpSocket>
#include <QHostAddress>
#include <QNetworkReply>
#include <QNetworkAccessManager>
#include <QTimer>

#include "upnpdevice.h"
#include "upnpdiscoverymodel.h"

class UpnpDiscovery : public QUdpSocket
{
    Q_OBJECT
    Q_PROPERTY(bool discovering READ discovering NOTIFY discoveringChanged)
    Q_PROPERTY(bool available READ available NOTIFY availableChanged)
    Q_PROPERTY(UpnpDiscoveryModel *discoveryModel READ discoveryModel NOTIFY discoveryModelChanged)

public:
    explicit UpnpDiscovery(QObject *parent = 0);

    bool discovering() const;
    UpnpDiscoveryModel *discoveryModel();

    bool available() const;

    Q_INVOKABLE void discover();
    Q_INVOKABLE void stopDiscovery();

private:
    QNetworkAccessManager *m_networkAccessManager;

    QTimer *m_timer;

    QHostAddress m_host;
    qint16 m_port;

    UpnpDiscoveryModel *m_discoveryModel;

    bool m_discovering;
    bool m_available;
    QHash<QNetworkReply *, UpnpDevice> m_runningReplies;
    QList<QUrl> m_foundDevices;

    void setDiscovering(const bool &discovering);
    void setAvailable(const bool &available);

signals:
    void discoveringChanged();
    void availableChanged();
    void discoveryModelChanged();

private slots:
    void error(QAbstractSocket::SocketError error);
    void readData();
    void networkReplyFinished(QNetworkReply *reply);
    void onTimeout();

};

#endif // UPNPDISCOVERY_H

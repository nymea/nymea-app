/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *                                                                         *
 *  Copyright (C) 2015 Simon Stuerz <stuerz.simon@gmail.com>               *
 *                                                                         *
 *  This file is part of nymea:app.                                       *
 *                                                                         *
 *  nymea:app is free software: you can redistribute it and/or modify     *
 *  it under the terms of the GNU General Public License as published by   *
 *  the Free Software Foundation, version 3 of the License.                *
 *                                                                         *
 *  nymea:app is distributed in the hope that it will be useful,          *
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of         *
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the           *
 *  GNU General Public License for more details.                           *
 *                                                                         *
 *  You should have received a copy of the GNU General Public License      *
 *  along with nymea:app. If not, see <http://www.gnu.org/licenses/>.     *
 *                                                                         *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#include "upnpdiscovery.h"

#include <QDebug>
#include <QUrl>
#include <QXmlStreamReader>
#include <QNetworkInterface>

UpnpDiscovery::UpnpDiscovery(NymeaHosts *nymeaHosts, QObject *parent) :
    QObject(parent),
    m_nymeaHosts(nymeaHosts)
{
    m_networkAccessManager = new QNetworkAccessManager(this);
    connect(m_networkAccessManager, &QNetworkAccessManager::finished, this, &UpnpDiscovery::networkReplyFinished);

    m_repeatTimer.setInterval(500);
    connect(&m_repeatTimer, &QTimer::timeout, this, &UpnpDiscovery::writeDiscoveryPacket);

    foreach (const QNetworkInterface &iface, QNetworkInterface::allInterfaces()) {
        if (!iface.flags().testFlag(QNetworkInterface::CanMulticast)) {
            continue;
        }
        foreach (const QNetworkAddressEntry &netAddressEntry, iface.addressEntries()) {
            if (netAddressEntry.ip().protocol() == QAbstractSocket::IPv4Protocol) {
                QUdpSocket *socket = new QUdpSocket(this);
                int port = -1;
                for (int i = 49125; i < 65535; i++) {
                    if(socket->bind(netAddressEntry.ip(), i, QUdpSocket::DontShareAddress)){
                        port = i;
                        break;
                    }
                }
                if (port == 65535 || socket->state() != QUdpSocket::BoundState) {
                    socket->deleteLater();
                    qWarning() << "UPnP: Discovery could not bind to interface" << netAddressEntry.ip();
                    continue;
                }
                qDebug() << "UPnP: Discovering on" << netAddressEntry.ip() << port;
                m_sockets.append(socket);
                connect(socket, SIGNAL(error(QAbstractSocket::SocketError)), this, SLOT(error(QAbstractSocket::SocketError)));
                connect(socket, &QUdpSocket::readyRead, this, &UpnpDiscovery::readData);
            }
        }
    }
}

bool UpnpDiscovery::discovering() const
{
    return m_repeatTimer.isActive();
}

bool UpnpDiscovery::available() const
{
    return !m_sockets.isEmpty();
}

void UpnpDiscovery::discover()
{
    if (!available()) {
        qWarning() << "UPnP: UPnP not available. Discovery not started.";
        return;
    }

    qDebug() << "UPNP: Discovery started...";
    m_repeatTimer.start();
    m_foundDevices.clear();
    writeDiscoveryPacket();
    emit discoveringChanged();
}

void UpnpDiscovery::stopDiscovery()
{
    qDebug() << "UPNP: Discovery stopped.";
    m_repeatTimer.stop();
    emit discoveringChanged();
}

void UpnpDiscovery::writeDiscoveryPacket()
{
    QByteArray ssdpSearchMessage = QByteArray("M-SEARCH * HTTP/1.1\r\n"
                                              "HOST:239.255.255.250:1900\r\n"
                                              "MAN:\"ssdp:discover\"\r\n"
                                              "MX:2\r\n"
                                              "ST: ssdp:all\r\n\r\n");

//    qDebug() << "sending discovery package";
    foreach (QUdpSocket* socket, m_sockets) {
        qint64 ret = socket->writeDatagram(ssdpSearchMessage, QHostAddress("239.255.255.250"), 1900);
        if (ret != ssdpSearchMessage.length()) {
            qWarning() << "UPnP: Error sending SSDP query on socket" << socket->localAddress();
        }

    }
}

void UpnpDiscovery::error(QAbstractSocket::SocketError error)
{
    QUdpSocket* socket = static_cast<QUdpSocket*>(sender());
    qWarning() << "UPnP: Socket error:" << error << socket->errorString();
}

void UpnpDiscovery::readData()
{
    QUdpSocket* socket = static_cast<QUdpSocket*>(sender());
    QByteArray data;
    quint16 port;
    QHostAddress hostAddress;

    // read the answere from the multicast
    while (socket->hasPendingDatagrams()) {
        data.resize(socket->pendingDatagramSize());
        socket->readDatagram(data.data(), data.size(), &hostAddress, &port);
    }

    if (!discovering()) {
        return;
    }

//    qDebug() << "upnp packet" << data;

    // if the data contains the HTTP OK header...
    if (data.contains("HTTP/1.1 200 OK")) {
        QUrl location;
        bool isNymea = false;

        const QStringList lines = QString(data).split("\r\n");
        foreach (const QString& line, lines) {
            int separatorIndex = line.indexOf(':');
            QString key = line.left(separatorIndex).toUpper();
            QString value = line.mid(separatorIndex+1).trimmed();


            if (key.contains("Server") || key.contains("SERVER")) {
                if (value.contains("nymea")) {
                    isNymea = true;
                }
            }

            // get location
            if (key.contains("LOCATION") || key.contains("Location")) {
                location = QUrl(value);
            }
        }

        if (!m_foundDevices.contains(location) && isNymea) {
            m_foundDevices.append(location);
//            qDebug() << "Getting server data from:" << location;
            QNetworkReply *reply = m_networkAccessManager->get(QNetworkRequest(location));
            connect(reply, &QNetworkReply::sslErrors, [reply](const QList<QSslError> &errors){
                reply->ignoreSslErrors(errors);
            });
            m_runningReplies.insert(reply, hostAddress);
        }
    }
}

void UpnpDiscovery::networkReplyFinished(QNetworkReply *reply)
{
    reply->deleteLater();
    QHostAddress discoveredAddress = m_runningReplies.take(reply);

    int status = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();
    if (reply->error() != QNetworkReply::NoError || status != 200) {
        qWarning() << "UPnP: Error fetching discovery data:" << status << reply->error() << reply->errorString();
        return;
    }

    QByteArray data = reply->readAll();

    QString name;
    QString version;
    QUuid uuid;
    QList<QUrl> connections;

    // parse XML data
    QXmlStreamReader xml(data);
    while (!xml.atEnd() && !xml.hasError()) {
        xml.readNext();

        if (xml.isStartDocument())
            continue;


        if (xml.isStartElement()) {

            // Check for old style websocketURL and nymeaRpcURL
            if (xml.name().toString() == "websocketURL" ||
                xml.name().toString() == "nymeaRpcURL" ||
                xml.name().toString() == "guhRpcURL") {
                QUrl u(xml.readElementText());
                connections.append(u);
            }

            // But also for new style serviceList
            if (xml.name().toString() == "serviceList") {
                while (!(xml.isEndElement() && xml.name().toString() == "serviceList") && !xml.atEnd()) {
                    xml.readNext();
                    if (xml.name().toString() == "service") {
                        while (!(xml.isEndElement() && xml.name().toString() == "service") && !xml.atEnd()) {
                            xml.readNext();
                            if (xml.name().toString() == "SCPDURL") {
                                QUrl u(xml.readElementText());
                                connections.append(u);
                            }
                        }
                    }
                }
            }

            if (xml.name() == "friendlyName") {
                name = xml.readElementText();
            }
            if (xml.name() == "modelNumber") {
                version = xml.readElementText();
            }
            if (xml.name() == "UDN") {
                uuid = xml.readElementText().split(':').last();
            }
        }
    }

//    qDebug() << "discovered device" << uuid << name << discoveredAddress << version << connections << data;

    NymeaHost* device = m_nymeaHosts->find(uuid);
    if (!device) {
        device = new NymeaHost(m_nymeaHosts);
        device->setUuid(uuid);
        qDebug() << "UPnP: Adding new host to model";
        m_nymeaHosts->addHost(device);
    }
    device->setName(name);
    device->setVersion(version);
    foreach (const QUrl &url, connections) {
        if (!device->connections()->find(url)) {
            qDebug() << "UPnP: Adding new connection to host:" << device->name() << url;
            bool sslEnabled = url.scheme() == "nymeas" || url.scheme() == "wss";
            QString displayName = QString("%1:%2").arg(url.host()).arg(url.port());
            Connection::BearerType bearerType = QHostAddress(url.host()).isLoopback() ? Connection::BearerTypeLoopback : Connection::BearerTypeLan;
            Connection *conn = new Connection(url, bearerType, sslEnabled, displayName);
            conn->setOnline(true);
            device->connections()->addConnection(conn);
        }
    }
}

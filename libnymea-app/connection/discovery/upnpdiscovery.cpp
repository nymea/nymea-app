/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
* Copyright 2013 - 2020, nymea GmbH
* Contact: contact@nymea.io
*
* This file is part of nymea.
* This project including source code and documentation is protected by
* copyright law, and remains the property of nymea GmbH. All rights, including
* reproduction, publication, editing and translation, are reserved. The use of
* this project is subject to the terms of a license agreement to be concluded
* with nymea GmbH in accordance with the terms of use of nymea GmbH, available
* under https://nymea.io/license
*
* GNU General Public License Usage
* Alternatively, this project may be redistributed and/or modified under the
* terms of the GNU General Public License as published by the Free Software
* Foundation, GNU version 3. This project is distributed in the hope that it
* will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty
* of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
* Public License for more details.
*
* You should have received a copy of the GNU General Public License along with
* this project. If not, see <https://www.gnu.org/licenses/>.
*
* For any further details and any questions please contact us under
* contact@nymea.io or see our FAQ/Licensing Information on
* https://nymea.io/license/faq
*
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#include "upnpdiscovery.h"

#include <QDebug>
#include <QUrl>
#include <QXmlStreamReader>
#include <QNetworkInterface>
//#include <QNetworkConfigurationManager>

#include "logging.h"

NYMEA_LOGGING_CATEGORY(dcUPnP, "UPnP")

UpnpDiscovery::UpnpDiscovery(NymeaHosts *nymeaHosts, QObject *parent) :
    QObject(parent),
    m_nymeaHosts(nymeaHosts)
{
//    m_networkConfigurationManager = new QNetworkConfigurationManager(this);
    m_networkAccessManager = new QNetworkAccessManager(this);
    connect(m_networkAccessManager, &QNetworkAccessManager::finished, this, &UpnpDiscovery::networkReplyFinished);

    m_repeatTimer.setInterval(500);
    connect(&m_repeatTimer, &QTimer::timeout, this, &UpnpDiscovery::writeDiscoveryPacket);

//    connect(m_networkConfigurationManager, &QNetworkConfigurationManager::configurationAdded, this, &UpnpDiscovery::updateInterfaces);
//    connect(m_networkConfigurationManager, &QNetworkConfigurationManager::configurationChanged, this, &UpnpDiscovery::updateInterfaces);
//    connect(m_networkConfigurationManager, &QNetworkConfigurationManager::configurationRemoved, this, &UpnpDiscovery::updateInterfaces);

    updateInterfaces();
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
        qCWarning(dcUPnP()) << "UPnP not available. Discovery not started.";
        return;
    }

    qCInfo(dcUPnP()) << "Discovery started...";
    m_repeatTimer.start();
    m_foundDevices.clear();
    writeDiscoveryPacket();
    emit discoveringChanged();
}

void UpnpDiscovery::stopDiscovery()
{
    qCInfo(dcUPnP()) << "Discovery stopped.";
    m_repeatTimer.stop();
    emit discoveringChanged();
}

void UpnpDiscovery::updateInterfaces()
{
    QList<QHostAddress> existingSockets = m_sockets.keys();

    // Now add all the interfaces where we don't have a socket yet
    foreach (const QNetworkInterface &iface, QNetworkInterface::allInterfaces()) {
        if (!iface.flags().testFlag(QNetworkInterface::CanMulticast)) {
            continue;
        }
        foreach (const QNetworkAddressEntry &netAddressEntry, iface.addressEntries()) {
            if (netAddressEntry.ip().protocol() != QAbstractSocket::IPv4Protocol) {
                continue;
            }
            if (m_sockets.contains(netAddressEntry.ip())) {
                existingSockets.removeAll(netAddressEntry.ip());
                continue;
            }

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
                qCWarning(dcUPnP()) << "Discovery could not bind to interface" << netAddressEntry.ip();
                continue;
            }
            qCInfo(dcUPnP()) << "Discovering on" << netAddressEntry.ip() << port;
            m_sockets.insert(netAddressEntry.ip(), socket);
            connect(socket, SIGNAL(error(QAbstractSocket::SocketError)), this, SLOT(error(QAbstractSocket::SocketError)));
            connect(socket, &QUdpSocket::readyRead, this, &UpnpDiscovery::readData);
        }
    }

    // Remove remaining existing sockets, their interface has vanished
    foreach (const QHostAddress &address, existingSockets) {
        if (!QNetworkInterface::allAddresses().contains(address)) {
            QUdpSocket *socket = m_sockets.value(address);
            qCInfo(dcUPnP()) << "Removing discovery from vanished interface" << socket->localAddress();
            delete m_sockets.take(address);
        }
    }

}

void UpnpDiscovery::writeDiscoveryPacket()
{
    QByteArray ssdpSearchMessage = QByteArray("M-SEARCH * HTTP/1.1\r\n"
                                              "HOST:239.255.255.250:1900\r\n"
                                              "MAN:\"ssdp:discover\"\r\n"
                                              "MX:2\r\n"
                                              "ST: ssdp:all\r\n\r\n");

    foreach (QUdpSocket* socket, m_sockets) {
        qint64 ret = socket->writeDatagram(ssdpSearchMessage, QHostAddress("239.255.255.250"), 1900);
        if (ret != ssdpSearchMessage.length()) {
            // Leaving a debug message because this happens on many platforms and spams logs.
            qCDebug(dcUPnP()) << "Error sending SSDP query on socket" << socket->localAddress();
        }
    }
}

void UpnpDiscovery::error(QAbstractSocket::SocketError error)
{
    QUdpSocket* socket = static_cast<QUdpSocket*>(sender());
    qCDebug(dcUPnP()) << "UPnP: Socket error:" << error << socket->errorString();
}

void UpnpDiscovery::readData()
{
    QUdpSocket* socket = static_cast<QUdpSocket*>(sender());
    QByteArray data;
    quint16 port;
    QHostAddress hostAddress;

    // read the answers from the multicast
    while (socket->hasPendingDatagrams()) {
        data.resize(socket->pendingDatagramSize());
        socket->readDatagram(data.data(), data.size(), &hostAddress, &port);

        qCDebug(dcUPnP()) << "Received UPnP datagram:" << data;

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
                qCDebug(dcUPnP()) << "Getting server data from:" << location;
                QNetworkReply *reply = m_networkAccessManager->get(QNetworkRequest(location));
                connect(reply, &QNetworkReply::sslErrors, [reply](const QList<QSslError> &errors){
                    reply->ignoreSslErrors(errors);
                });
                m_runningReplies.insert(reply, hostAddress);
            }
        }
    }
}

void UpnpDiscovery::networkReplyFinished(QNetworkReply *reply)
{
    reply->deleteLater();
    QHostAddress discoveredAddress = m_runningReplies.take(reply);

    int status = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();
    if (reply->error() != QNetworkReply::NoError || status != 200) {
        qCWarning(dcUPnP()) << "UPnP: Error fetching discovery data:" << status << reply->error() << reply->errorString();
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

            if (xml.name() == QStringLiteral("friendlyName")) {
                name = xml.readElementText();
            }
            if (xml.name() == QStringLiteral("modelNumber")) {
                version = xml.readElementText();
            }
            if (xml.name() == QStringLiteral("UDN")) {
                uuid = QUuid(xml.readElementText().split(':').last());
            }
        }
    }

    qCDebug(dcUPnP()) << "Discovered device" << name << discoveredAddress << version << connections /*<< data*/;

    NymeaHost* device = m_nymeaHosts->find(uuid);
    if (!device) {
        device = new NymeaHost(m_nymeaHosts);
        device->setUuid(uuid);
        qCInfo(dcUPnP()) << "Adding new host to model" << device->name() << device->uuid();
        m_nymeaHosts->addHost(device);
    }
    device->setName(name);
    device->setVersion(version);
    foreach (const QUrl &url, connections) {
        Connection *connection = device->connections()->find(url);
        if (!connection) {
            bool sslEnabled = url.scheme() == "nymeas" || url.scheme() == "wss";
            Connection::BearerType bearerType = QHostAddress(url.host()).isLoopback() ? Connection::BearerTypeLoopback : Connection::BearerTypeLan;
            connection = new Connection(url, bearerType, sslEnabled, "UPnP");
            connection->setOnline(true);
            qCInfo(dcUPnP()) << "Adding new connection to host:" << device->name() << url << bearerType;
            device->connections()->addConnection(connection);
        } else {
            qCInfo(dcUPnP()) << "Setting connection online:" << device->name() << url.toString();
            connection->setOnline(true);
        }
    }
}

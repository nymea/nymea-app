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

#include "upnpdiscovery.h"

#include <QDebug>
#include <QUrl>
#include <QXmlStreamReader>

UpnpDiscovery::UpnpDiscovery(DiscoveryModel *discoveryModel, QObject *parent) :
    QUdpSocket(parent),
    m_discoveryModel(discoveryModel),
    m_discovering(false),
    m_available(false)
{
    m_networkAccessManager = new QNetworkAccessManager(this);
    connect(m_networkAccessManager, &QNetworkAccessManager::finished, this, &UpnpDiscovery::networkReplyFinished);

    m_repeatTimer.setInterval(500);
    connect(&m_repeatTimer, &QTimer::timeout, this, &UpnpDiscovery::writeDiscoveryPacket);

    // bind udp socket and join multicast group
    m_port = 1900;
    m_host = QHostAddress("239.255.255.250");

    setSocketOption(QAbstractSocket::MulticastTtlOption,QVariant(1));
    setSocketOption(QAbstractSocket::MulticastLoopbackOption,QVariant(1));

    if(!bind(QHostAddress::AnyIPv4, m_port, QUdpSocket::ShareAddress)){
        qWarning() << "UPnP discovery could not bind to port" << m_port;
        setAvailable(false);
        return;
    }

    if(!joinMulticastGroup(m_host)){
        qWarning() << "UPnP discovery could not join multicast group" << m_host;
        setAvailable(false);
        return;
    }

    connect(this, SIGNAL(error(QAbstractSocket::SocketError)), this, SLOT(error(QAbstractSocket::SocketError)));
    connect(this, &UpnpDiscovery::readyRead, this, &UpnpDiscovery::readData);
    setAvailable(true);
}

bool UpnpDiscovery::discovering() const
{
    return m_discovering;
}

bool UpnpDiscovery::available() const
{
    return m_available;
}

void UpnpDiscovery::discover()
{
    if (!m_available) {
        qWarning() << "Could not discover. UPnP not available.";
        return;
    }

    qDebug() << "start discovering...";
    m_repeatTimer.start();
//    m_discoveryModel->clearModel();
    m_foundDevices.clear();

    setDiscovering(true);

    writeDiscoveryPacket();
}

void UpnpDiscovery::stopDiscovery()
{
    qDebug() << "stop discovering";
    m_repeatTimer.stop();
    setDiscovering(false);
}

void UpnpDiscovery::setDiscovering(const bool &discovering)
{
    m_discovering = discovering;
    emit discoveringChanged();
}

void UpnpDiscovery::setAvailable(const bool &available)
{
    m_available = available;
    emit availableChanged();
}

void UpnpDiscovery::writeDiscoveryPacket()
{
    QByteArray ssdpSearchMessage = QByteArray("M-SEARCH * HTTP/1.1\r\n"
                                              "HOST:239.255.255.250:1900\r\n"
                                              "MAN:\"ssdp:discover\"\r\n"
                                              "MX:2\r\n"
                                              "ST: ssdp:all\r\n\r\n");

//    qDebug() << "sending discovery packet";
    writeDatagram(ssdpSearchMessage, m_host, m_port);
}

void UpnpDiscovery::error(QAbstractSocket::SocketError error)
{
    qWarning() << "UPnP socket error:" << error << errorString();
}

void UpnpDiscovery::readData()
{
    QByteArray data;
    quint16 port;
    QHostAddress hostAddress;

    // read the answere from the multicast
    while (hasPendingDatagrams()) {
        data.resize(pendingDatagramSize());
        readDatagram(data.data(), data.size(), &hostAddress, &port);
    }

    if (!discovering()) {
        return;
    }

    // if the data contains the HTTP OK header...
    if (data.contains("HTTP/1.1 200 OK") || data.contains("NOTIFY * HTTP/1.1")) {
        QUrl location;
        bool isNymea = false;

        const QStringList lines = QString(data).split("\r\n");
        foreach (const QString& line, lines) {
            int separatorIndex = line.indexOf(':');
            QString key = line.left(separatorIndex).toUpper();
            QString value = line.mid(separatorIndex+1).trimmed();


            if (key.contains("Server") || key.contains("SERVER")) {
                if (value.contains("nymea")) {
                    qDebug() << " --> " << key << value;
                    isNymea = true;
                }
            }

            // get location
            if (key.contains("LOCATION") || key.contains("Location")) {
                location = QUrl(value);
            }
        }

        if (isNymea) {
            qDebug() << "Found nymea device:" << location;
        }

        if (!m_foundDevices.contains(location) && isNymea) {
            m_foundDevices.append(location);
            qDebug() << "Getting server data from:" << location;
            QNetworkReply *reply = m_networkAccessManager->get(QNetworkRequest(location));
            connect(reply, &QNetworkReply::sslErrors, [this, reply](const QList<QSslError> &errors){
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
        qWarning() << "Error fetching UPnP discovery data:" << status << reply->error() << reply->errorString();
        return;
    }

    QByteArray data = reply->readAll();

    QString name;
    QString version;
    QUuid uuid;
    QList<PortConfig*> portConfigList;

    // parse XML data
    QXmlStreamReader xml(data);
    while (!xml.atEnd() && !xml.hasError()) {
        xml.readNext();

        if (xml.isStartDocument())
            continue;

        if (xml.isStartElement()) {
            if (xml.name().toString() == "websocketURL") {
                QUrl u(xml.readElementText());
                PortConfig *pc = new PortConfig(u.port());
                pc->setProtocol(PortConfig::ProtocolWebSocket);
                pc->setSslEnabled(u.scheme().endsWith('s'));
                portConfigList.append(pc);
            }
        }

        if (xml.isStartElement()) {
            if (xml.name().toString() == "nymeaRpcURL") {
                QUrl u(xml.readElementText());
                qDebug() << "have url" << u << u.scheme();
                PortConfig *pc = new PortConfig(u.port());
                pc->setProtocol(PortConfig::ProtocolNymeaRpc);
                pc->setSslEnabled(u.scheme().endsWith('s'));
                portConfigList.append(pc);
            }
        }

        if (xml.isStartElement()) {
            if (xml.name().toString() == "device") {
                while (!xml.atEnd()) {
                    if (xml.name() == "friendlyName" && xml.isStartElement()) {
                        name = xml.readElementText();
                    }
                    if (xml.name() == "modelNumber" && xml.isStartElement()) {
                        version = xml.readElementText();
                    }
                    if (xml.name() == "UDN" && xml.isStartElement()) {
                        uuid = xml.readElementText().split(':').last();
                    }
                    xml.readNext();
                }
                xml.readNext();
            }
        }
    }

    qDebug() << "discovered device" << uuid << name << discoveredAddress << version;

    DiscoveryDevice* device = m_discoveryModel->find(uuid);
    if (!device) {
        device = new DiscoveryDevice(m_discoveryModel);
        device->setUuid(uuid);
        qDebug() << "Adding new host to model";
        m_discoveryModel->addDevice(device);
    }
    device->setHostAddress(discoveredAddress);
    device->setName(name);
    device->setVersion(version);
    foreach (PortConfig *pc, portConfigList) {
        PortConfig *portConfig = device->portConfigs()->find(pc->port());
        if (portConfig) {
            qDebug() << "Updating port config" << portConfig->port() << portConfig->sslEnabled() << portConfig->protocol();
            portConfig->setProtocol(pc->protocol());
            portConfig->setSslEnabled(pc->sslEnabled());
            pc->deleteLater();
        } else {
            qDebug() << "adding new port config" << pc->port() << pc->sslEnabled() << pc->protocol();
            device->portConfigs()->insert(pc);
        }
    }
}

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

#include "upnpdevice.h"

#include <QUrl>

UpnpDevice::UpnpDevice()
{
}

QUrl UpnpDevice::location() const
{
    return m_location;
}

void UpnpDevice::setLocation(const QUrl &location)
{
    m_location = location;
}

QString UpnpDevice::webSocketUrl() const
{
    return m_webSocketUrl;
}

void UpnpDevice::setWebSocketUrl(const QString &webSocketUrl)
{
    m_webSocketUrl = webSocketUrl;
}

QString UpnpDevice::guhRpcUrl() const
{
    return m_guhRpcUrl;
}

void UpnpDevice::setGuhRpcUrl(const QString &guhRpcUrl)
{
    m_guhRpcUrl = guhRpcUrl;
}

QHostAddress UpnpDevice::hostAddress() const
{
    return m_hostAddress;
}

void UpnpDevice::setHostAddress(const QHostAddress &hostAddress)
{
    m_hostAddress = hostAddress;
}

int UpnpDevice::port() const
{
    return m_port;
}

void UpnpDevice::setPort(const int &port)
{
    m_port = port;
}

QString UpnpDevice::friendlyName() const
{
    return m_friendlyName;
}

void UpnpDevice::setFriendlyName(const QString &friendlyName)
{
    m_friendlyName = friendlyName;
}

QString UpnpDevice::manufacturer() const
{
    return m_manufacturer;
}

void UpnpDevice::setManufacturer(const QString &manufacturer)
{
    m_manufacturer = manufacturer;
}

QUrl UpnpDevice::manufacturerURL() const
{
    return m_manufacturerURL;
}

void UpnpDevice::setManufacturerURL(const QUrl &manufacturerURL)
{
    m_manufacturerURL = manufacturerURL;
}

QString UpnpDevice::modelDescription() const
{
    return m_modelDescription;
}

void UpnpDevice::setModelDescription(const QString &modelDescription)
{
    m_modelDescription = modelDescription;
}

QString UpnpDevice::modelName() const
{
    return m_modelName;
}

void UpnpDevice::setModelName(const QString &modelName)
{
    m_modelName = modelName;
}

QString UpnpDevice::modelNumber() const
{
    return m_modelNumber;
}

void UpnpDevice::setModelNumber(const QString &modelNumber)
{
    m_modelNumber = modelNumber;
}

QUrl UpnpDevice::modelURL() const
{
    return m_modelURL;
}

void UpnpDevice::setModelURL(const QUrl &modelURL)
{
    m_modelURL = modelURL;
}

QString UpnpDevice::uuid() const
{
    return m_uuid;
}

void UpnpDevice::setUuid(const QString &uuid)
{
    m_uuid = uuid;
}

QDebug operator<<(QDebug debug, const UpnpDevice &upnpDevice)
{
    debug << "----------------------------------------------\n";
    debug << "UPnP device on " << QString("%1:%2").arg(upnpDevice.hostAddress().toString()).arg(upnpDevice.port()) << "\n";
    debug << "location              | " << upnpDevice.location().toString() << "\n";
    debug << "websocket             | " << upnpDevice.webSocketUrl() << "\n";
    debug << "guhrpc                | " << upnpDevice.guhRpcUrl() << "\n";
    debug << "friendly name         | " << upnpDevice.friendlyName() << "\n";
    debug << "manufacturer          | " << upnpDevice.manufacturer() << "\n";
    debug << "manufacturer URL      | " << upnpDevice.manufacturerURL().toString() << "\n";
    debug << "model name            | " << upnpDevice.modelName() << "\n";
    debug << "model number          | " << upnpDevice.modelNumber() << "\n";
    debug << "model description     | " << upnpDevice.modelDescription() << "\n";
    debug << "model URL             | " << upnpDevice.modelURL().toString() << "\n";
    debug << "UUID                  | " << upnpDevice.uuid() << "\n";

    return debug;
}

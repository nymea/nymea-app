/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *                                                                         *
 *  Copyright (C) 2015 Simon Stuerz <stuerz.simon@gmail.com>               *
 *                                                                         *
 *  This file is part of mea.                                              *
 *                                                                         *
 *  mea is free software: you can redistribute it and/or modify            *
 *  it under the terms of the GNU General Public License as published by   *
 *  the Free Software Foundation, version 3 of the License.                *
 *                                                                         *
 *  mea is distributed in the hope that it will be useful,                 *
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of         *
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the           *
 *  GNU General Public License for more details.                           *
 *                                                                         *
 *  You should have received a copy of the GNU General Public License      *
 *  along with mea. If not, see <http://www.gnu.org/licenses/>.            *
 *                                                                         *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#include "discoverydevice.h"

#include <QUrl>

DiscoveryDevice::DiscoveryDevice()
{
}

QUrl DiscoveryDevice::location() const
{
    return m_location;
}

void DiscoveryDevice::setLocation(const QUrl &location)
{
    m_location = location;
}

QString DiscoveryDevice::webSocketUrl() const
{
    return m_webSocketUrl;
}

void DiscoveryDevice::setWebSocketUrl(const QString &webSocketUrl)
{
    m_webSocketUrl = webSocketUrl;
}

QString DiscoveryDevice::nymeaRpcUrl() const
{
    return m_nymeaRpcUrl;
}

void DiscoveryDevice::setNymeaRpcUrl(const QString &nymeaRpcUrl)
{
    m_nymeaRpcUrl = nymeaRpcUrl;
}

QHostAddress DiscoveryDevice::hostAddress() const
{
    return m_hostAddress;
}

void DiscoveryDevice::setHostAddress(const QHostAddress &hostAddress)
{
    m_hostAddress = hostAddress;
}

int DiscoveryDevice::port() const
{
    return m_port;
}

void DiscoveryDevice::setPort(const int &port)
{
    m_port = port;
}

QString DiscoveryDevice::friendlyName() const
{
    return m_friendlyName;
}

void DiscoveryDevice::setFriendlyName(const QString &friendlyName)
{
    m_friendlyName = friendlyName;
}

QString DiscoveryDevice::manufacturer() const
{
    return m_manufacturer;
}

void DiscoveryDevice::setManufacturer(const QString &manufacturer)
{
    m_manufacturer = manufacturer;
}

QUrl DiscoveryDevice::manufacturerURL() const
{
    return m_manufacturerURL;
}

void DiscoveryDevice::setManufacturerURL(const QUrl &manufacturerURL)
{
    m_manufacturerURL = manufacturerURL;
}

QString DiscoveryDevice::modelDescription() const
{
    return m_modelDescription;
}

void DiscoveryDevice::setModelDescription(const QString &modelDescription)
{
    m_modelDescription = modelDescription;
}

QString DiscoveryDevice::modelName() const
{
    return m_modelName;
}

void DiscoveryDevice::setModelName(const QString &modelName)
{
    m_modelName = modelName;
}

QString DiscoveryDevice::modelNumber() const
{
    return m_modelNumber;
}

void DiscoveryDevice::setModelNumber(const QString &modelNumber)
{
    m_modelNumber = modelNumber;
}

QUrl DiscoveryDevice::modelURL() const
{
    return m_modelURL;
}

void DiscoveryDevice::setModelURL(const QUrl &modelURL)
{
    m_modelURL = modelURL;
}

QString DiscoveryDevice::uuid() const
{
    return m_uuid;
}

void DiscoveryDevice::setUuid(const QString &uuid)
{
    m_uuid = uuid;
}

QDebug operator<<(QDebug debug, const DiscoveryDevice &DiscoveryDevice)
{
    debug << "----------------------------------------------\n";
    debug << "UPnP device on " << QString("%1:%2").arg(DiscoveryDevice.hostAddress().toString()).arg(DiscoveryDevice.port()) << "\n";
    debug << "location              | " << DiscoveryDevice.location().toString() << "\n";
    debug << "websocket             | " << DiscoveryDevice.webSocketUrl() << "\n";
    debug << "nymearpc              | " << DiscoveryDevice.nymeaRpcUrl() << "\n";
    debug << "friendly name         | " << DiscoveryDevice.friendlyName() << "\n";
    debug << "manufacturer          | " << DiscoveryDevice.manufacturer() << "\n";
    debug << "manufacturer URL      | " << DiscoveryDevice.manufacturerURL().toString() << "\n";
    debug << "model name            | " << DiscoveryDevice.modelName() << "\n";
    debug << "model number          | " << DiscoveryDevice.modelNumber() << "\n";
    debug << "model description     | " << DiscoveryDevice.modelDescription() << "\n";
    debug << "model URL             | " << DiscoveryDevice.modelURL().toString() << "\n";
    debug << "UUID                  | " << DiscoveryDevice.uuid() << "\n";

    return debug;
}

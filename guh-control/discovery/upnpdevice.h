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

#ifndef UPNPDEVICE_H
#define UPNPDEVICE_H

#include <QObject>
#include <QUrl>
#include <QHostAddress>

class UpnpDevice
{
public:
    explicit UpnpDevice();

    QUrl location() const;
    void setLocation(const QUrl &location);

    QString webSocketUrl() const;
    void setWebSocketUrl(const QString &webSocketUrl);

    QString guhRpcUrl() const;
    void setGuhRpcUrl(const QString &guhRpcUrl);

    QHostAddress hostAddress() const;
    void setHostAddress(const QHostAddress &hostAddress);

    int port() const;
    void setPort(const int &port);

    QString deviceType() const;
    void setDeviceType(const QString & deviceType);

    QString friendlyName() const;
    void setFriendlyName(const QString &friendlyName);

    QString manufacturer() const;
    void setManufacturer(const QString &manufacturer);

    QUrl manufacturerURL() const;
    void setManufacturerURL(const QUrl & manufacturerURL);

    QString modelDescription() const;
    void setModelDescription(const QString & modelDescription);

    QString modelName() const;
    void setModelName(const QString & modelName);

    QString modelNumber() const;
    void setModelNumber(const QString &modelNumber);

    QUrl modelURL() const;
    void setModelURL(const QUrl &modelURL);

    QString uuid() const;
    void setUuid(const QString &uuid);

private:
    QUrl m_location;
    QString m_webSocketUrl;
    QString m_guhRpcUrl;
    QHostAddress m_hostAddress;
    int m_port;
    QString m_friendlyName;
    QString m_manufacturer;
    QUrl m_manufacturerURL;
    QString m_modelDescription;
    QString m_modelName;
    QString m_modelNumber;
    QUrl m_modelURL;
    QString m_uuid;
};

QDebug operator<< (QDebug debug, const UpnpDevice &upnpDevice);

#endif // UPNPDEVICE_H

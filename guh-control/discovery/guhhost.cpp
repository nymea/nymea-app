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

#include "guhhost.h"

GuhHost::GuhHost(QObject *parent) :
    QObject(parent)
{
}

QString GuhHost::name() const
{
    return m_name;
}

void GuhHost::setName(const QString &name)
{
    m_name = name;
}

QString GuhHost::webSocketUrl() const
{
    return m_webSocketUrl;
}

void GuhHost::setWebSocketUrl(const QString &webSocketUrl)
{
    m_webSocketUrl = webSocketUrl;
}

QString GuhHost::hostAddress() const
{
    return m_hostAddress;
}

void GuhHost::setHostAddress(const QString &hostAddress)
{
    m_hostAddress = hostAddress;
}

QUuid GuhHost::uuid() const
{
    return m_uuid;
}

void GuhHost::setUuid(const QUuid &uuid)
{
    m_uuid = uuid;
}



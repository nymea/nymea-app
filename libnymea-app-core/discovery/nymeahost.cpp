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

#include "nymeahost.h"

NymeaHost::NymeaHost(QObject *parent) :
    QObject(parent)
{
}

QString NymeaHost::name() const
{
    return m_name;
}

void NymeaHost::setName(const QString &name)
{
    m_name = name;
}

QString NymeaHost::webSocketUrl() const
{
    return m_webSocketUrl;
}

void NymeaHost::setWebSocketUrl(const QString &webSocketUrl)
{
    m_webSocketUrl = webSocketUrl;
}

QString NymeaHost::hostAddress() const
{
    return m_hostAddress;
}

void NymeaHost::setHostAddress(const QString &hostAddress)
{
    m_hostAddress = hostAddress;
}

QUuid NymeaHost::uuid() const
{
    return m_uuid;
}

void NymeaHost::setUuid(const QUuid &uuid)
{
    m_uuid = uuid;
}



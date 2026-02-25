// SPDX-License-Identifier: LGPL-3.0-or-later

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
* Copyright (C) 2013 - 2024, nymea GmbH
* Copyright (C) 2024 - 2025, chargebyte austria GmbH
*
* This file is part of libnymea-app.
*
* libnymea-app is free software: you can redistribute it and/or
* modify it under the terms of the GNU Lesser General Public License
* as published by the Free Software Foundation, either version 3
* of the License, or (at your option) any later version.
*
* libnymea-app is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
* GNU Lesser General Public License for more details.
*
* You should have received a copy of the GNU Lesser General Public License
* along with libnymea-app. If not, see <https://www.gnu.org/licenses/>.
*
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#include "ioconnection.h"

IOConnection::IOConnection(const QUuid &id, const QUuid &inputThingId, const QUuid &inputStateTypeId, const QUuid &outputThingId, const QUuid &outputStateTypeId, bool inverted, QObject *parent):
    QObject(parent),
    m_id(id),
    m_inputThingId(inputThingId),
    m_inputStateTypeId(inputStateTypeId),
    m_outputThingId(outputThingId),
    m_outputStateTypeId(outputStateTypeId),
    m_inverted(inverted)
{

}

QUuid IOConnection::id() const
{
    return m_id;
}

QUuid IOConnection::inputThingId() const
{
    return m_inputThingId;
}

QUuid IOConnection::inputStateTypeId() const
{
    return m_inputStateTypeId;
}

QUuid IOConnection::outputThingId() const
{
    return m_outputThingId;
}

QUuid IOConnection::outputStateTypeId() const
{
    return m_outputStateTypeId;
}

bool IOConnection::inverted() const
{
    return m_inverted;
}

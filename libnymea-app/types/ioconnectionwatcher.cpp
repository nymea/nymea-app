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

#include "ioconnectionwatcher.h"
#include "ioconnections.h"
#include "ioconnection.h"

IOInputConnectionWatcher::IOInputConnectionWatcher(QObject *parent) : QObject(parent)
{

}

IOConnections *IOInputConnectionWatcher::ioConnections() const
{
    return m_ioConnections;
}

void IOInputConnectionWatcher::setIOConnections(IOConnections *ioConnections)
{
    if (m_ioConnections != ioConnections) {

        if (m_ioConnections) {
            disconnect(ioConnections, &IOConnections::countChanged, this, &IOInputConnectionWatcher::ioConnectionChanged);
        }

        m_ioConnections = ioConnections;
        emit ioConnectionsChanged();
        emit ioConnectionChanged();

        connect(ioConnections, &IOConnections::countChanged, this, &IOInputConnectionWatcher::ioConnectionChanged);
    }
}

QUuid IOInputConnectionWatcher::inputThingId() const
{
    return m_inputThingId;
}

void IOInputConnectionWatcher::setInputThingId(const QUuid &inputThingId)
{
    if (m_inputThingId != inputThingId) {
        m_inputThingId = inputThingId;
        emit inputThingIdChanged();
        emit ioConnectionChanged();
    }
}

QUuid IOInputConnectionWatcher::inputStateTypeId() const
{
    return m_inputStateTypeId;
}

void IOInputConnectionWatcher::setInputStateTypeId(const QUuid &inputStateTypeId)
{
    if (m_inputStateTypeId != inputStateTypeId) {
        m_inputStateTypeId = inputStateTypeId;
        emit inputStateTypeIdChanged();
        emit ioConnectionChanged();
    }
}

IOConnection* IOInputConnectionWatcher::ioConnection() const
{
    if (!m_ioConnections) {
        return nullptr;
    }
    return m_ioConnections->findIOConnectionByInput(m_inputThingId, m_inputStateTypeId);
}

IOOutputConnectionWatcher::IOOutputConnectionWatcher(QObject *parent): QObject(parent)
{

}

IOConnections *IOOutputConnectionWatcher::ioConnections() const
{
    return m_ioConnections;
}

void IOOutputConnectionWatcher::setIOConnections(IOConnections *ioConnections)
{
    if (m_ioConnections != ioConnections) {

        if (m_ioConnections) {
            disconnect(ioConnections, &IOConnections::countChanged, this, &IOOutputConnectionWatcher::ioConnectionChanged);
        }

        m_ioConnections = ioConnections;
        emit ioConnectionsChanged();
        emit ioConnectionChanged();

        connect(ioConnections, &IOConnections::countChanged, this, &IOOutputConnectionWatcher::ioConnectionChanged);
    }
}

QUuid IOOutputConnectionWatcher::outputThingId() const
{
    return m_outputThingId;
}

void IOOutputConnectionWatcher::setOutputThingId(const QUuid &outputThingId)
{
    if (m_outputThingId != outputThingId) {
        m_outputThingId = outputThingId;
        emit outputThingIdChanged();
        emit ioConnectionChanged();
    }
}

QUuid IOOutputConnectionWatcher::outputStateTypeId() const
{
    return m_outputStateTypeId;
}

void IOOutputConnectionWatcher::setOutputStateTypeId(const QUuid &outputStateTypeId)
{
    if (m_outputStateTypeId != outputStateTypeId) {
        m_outputStateTypeId = outputStateTypeId;
        emit outputStateTypeIdChanged();
        emit ioConnectionChanged();
    }
}

IOConnection *IOOutputConnectionWatcher::ioConnection() const
{
    if (!m_ioConnections) {
        return nullptr;
    }
    return m_ioConnections->findIOConnectionByOutput(m_outputThingId, m_outputStateTypeId);
}

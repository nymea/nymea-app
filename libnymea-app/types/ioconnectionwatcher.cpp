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

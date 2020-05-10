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

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

#include "eventdescriptor.h"
#include <QDebug>

EventDescriptor::EventDescriptor(QObject *parent) : QObject(parent)
{
    m_paramDescriptors = new ParamDescriptors(this);
}

QString EventDescriptor::deviceId() const
{
    return m_deviceId;
}

void EventDescriptor::setDeviceId(const QString &deviceId)
{
    if (m_deviceId != deviceId) {
        m_deviceId = deviceId;
        emit deviceIdChanged();
    }
}

QString EventDescriptor::eventTypeId() const
{
    return m_eventTypeId;
}

void EventDescriptor::setEventTypeId(const QString &eventTypeId)
{
    if (m_eventTypeId != eventTypeId) {
        m_eventTypeId = eventTypeId;
        emit eventTypeIdChanged();
    }
}

QString EventDescriptor::interfaceName() const
{
    return m_interfaceName;
}

void EventDescriptor::setInterfaceName(const QString &interfaceName)
{
    if (m_interfaceName != interfaceName) {
        m_interfaceName = interfaceName;
        emit interfaceNameChanged();
    }
}

QString EventDescriptor::interfaceEvent() const
{
    return m_interfaceEvent;
}

void EventDescriptor::setInterfaceEvent(const QString &interfaceEvent)
{
    if (m_interfaceEvent != interfaceEvent) {
        m_interfaceEvent = interfaceEvent;
        emit interfaceEventChanged();
    }
}

ParamDescriptors *EventDescriptor::paramDescriptors() const
{
    return m_paramDescriptors;
}

EventDescriptor *EventDescriptor::clone() const
{
    EventDescriptor *ret = new EventDescriptor();
    ret->setDeviceId(this->deviceId());
    ret->setEventTypeId(this->eventTypeId());
    ret->setInterfaceName(this->interfaceName());
    ret->setInterfaceEvent(this->interfaceEvent());
    for (int i = 0; i < this->paramDescriptors()->rowCount(); i++) {
        ret->paramDescriptors()->addParamDescriptor(this->paramDescriptors()->get(i)->clone());
    }
    return ret;
}

#define COMPARE(a, b) if (a != b) { qDebug() << a << "!=" << b; return false; }
#define COMPARE_PTR(a, b) if (!a->operator==(b)) { qDebug() << a << "!=" << b; return false; }
bool EventDescriptor::operator==(EventDescriptor *other) const
{
    COMPARE(m_deviceId, other->deviceId());
    COMPARE(m_eventTypeId, other->eventTypeId());
    COMPARE(m_interfaceName, other->interfaceName());
    COMPARE(m_interfaceEvent, other->interfaceEvent());
    COMPARE_PTR(m_paramDescriptors, other->paramDescriptors());
    return true;
}

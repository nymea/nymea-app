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

#include "eventdescriptor.h"
#include <QDebug>

EventDescriptor::EventDescriptor(QObject *parent) : QObject(parent)
{
    m_paramDescriptors = new ParamDescriptors(this);
}

QUuid EventDescriptor::thingId() const
{
    return m_thingId;
}

void EventDescriptor::setThingId(const QUuid &thingId)
{
    if (m_thingId != thingId) {
        m_thingId = thingId;
        emit thingIdChanged();
    }
}

QUuid EventDescriptor::eventTypeId() const
{
    return m_eventTypeId;
}

void EventDescriptor::setEventTypeId(const QUuid &eventTypeId)
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
    ret->setThingId(this->thingId());
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
    COMPARE(m_thingId, other->thingId());
    COMPARE(m_eventTypeId, other->eventTypeId());
    COMPARE(m_interfaceName, other->interfaceName());
    COMPARE(m_interfaceEvent, other->interfaceEvent());
    COMPARE_PTR(m_paramDescriptors, other->paramDescriptors());
    return true;
}

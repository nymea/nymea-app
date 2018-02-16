#include "eventdescriptor.h"

EventDescriptor::EventDescriptor(QObject *parent) : QObject(parent)
{
    m_paramDescriptors = new ParamDescriptors(this);
}

QUuid EventDescriptor::deviceId() const
{
    return m_deviceId;
}

void EventDescriptor::setDeviceId(const QUuid &deviceId)
{
    if (m_deviceId != deviceId) {
        m_deviceId = deviceId;
        emit deviceIdChanged();
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
    m_interfaceEvent = interfaceEvent;
}

ParamDescriptors *EventDescriptor::paramDescriptors() const
{
    return m_paramDescriptors;
}

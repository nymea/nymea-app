#include "eventdescriptor.h"

EventDescriptor::EventDescriptor(QObject *parent) : QObject(parent)
{

}

QUuid EventDescriptor::deviceId() const
{
    return m_deviceId;
}

void EventDescriptor::setDeviceId(const QUuid &deviceId)
{
    m_deviceId = deviceId;
}

QUuid EventDescriptor::eventTypeId() const
{
    return m_eventTypeId;
}

void EventDescriptor::setEventTypeId(const QUuid &eventTypeId)
{
    m_eventTypeId = eventTypeId;
}

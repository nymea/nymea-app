#include "eventdescriptortemplate.h"

EventDescriptorTemplate::EventDescriptorTemplate(const QString &interfaceName, const QString &interfaceEvent, int selectionId, SelectionMode selectionMode, QObject *parent):
    QObject(parent),
    m_interfaceName(interfaceName),
    m_interfaceEvent(interfaceEvent),
    m_selectionId(selectionId),
    m_selectionMode(selectionMode)
{

}

QString EventDescriptorTemplate::interfaceName() const
{
    return m_interfaceName;
}

QString EventDescriptorTemplate::interfaceEvent() const
{
    return m_interfaceEvent;
}

int EventDescriptorTemplate::selectionId() const
{
    return m_selectionId;
}

EventDescriptorTemplate::SelectionMode EventDescriptorTemplate::selectionMode() const
{
    return m_selectionMode;
}

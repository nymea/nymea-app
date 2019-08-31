#include "eventdescriptortemplate.h"

EventDescriptorTemplate::EventDescriptorTemplate(const QString &interfaceName, const QString &interfaceEvent, int selectionId, SelectionMode selectionMode, QObject *parent):
    QObject(parent),
    m_interfaceName(interfaceName),
    m_interfaceEvent(interfaceEvent),
    m_selectionId(selectionId),
    m_selectionMode(selectionMode),
    m_paramDescriptors(new ParamDescriptors(this))
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

ParamDescriptors *EventDescriptorTemplate::paramDescriptors() const
{
    return m_paramDescriptors;
}

QStringList EventDescriptorTemplates::interfaces() const
{
    QStringList ret;
    for (int i = 0; i < m_list.count(); i++) {
        ret.append(m_list.at(i)->interfaceName());
    }
    ret.removeDuplicates();
    return ret;
}

#include "statedescriptortemplate.h"

StateDescriptorTemplate::StateDescriptorTemplate(const QString &interfaceName, const QString &interfaceState, int selectionId, StateDescriptorTemplate::SelectionMode selectionMode, StateDescriptorTemplate::ValueOperator valueOperator, const QVariant &value, QObject *parent):
    QObject(parent),
    m_interfaceName(interfaceName),
    m_interfaceState(interfaceState),
    m_selectionId(selectionId),
    m_selectionMode(selectionMode),
    m_valueOperator(valueOperator),
    m_value(value)
{

}

QString StateDescriptorTemplate::interfaceName() const
{
    return m_interfaceName;
}

QString StateDescriptorTemplate::interfaceState() const
{
    return m_interfaceState;
}

int StateDescriptorTemplate::selectionId() const
{
    return m_selectionId;
}

StateDescriptorTemplate::SelectionMode StateDescriptorTemplate::selectionMode() const
{
    return m_selectionMode;
}

StateDescriptorTemplate::ValueOperator StateDescriptorTemplate::valueOperator() const
{
    return m_valueOperator;
}

QVariant StateDescriptorTemplate::value() const
{
    return m_value;
}

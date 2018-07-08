#include "ruleactiontemplate.h"


RuleActionTemplate::RuleActionTemplate(const QString &interfaceName, const QString &interfaceAction, int selectionId, SelectionMode selectionMode, QObject *parent):
    QObject(parent),
    m_interfaceName(interfaceName),
    m_interfaceAction(interfaceAction),
    m_selectionId(selectionId),
    m_selectionMode(selectionMode),
    m_ruleActionParams(new RuleActionParams(this))
{

}

QString RuleActionTemplate::interfaceName() const
{
    return m_interfaceName;
}

QString RuleActionTemplate::interfaceAction() const
{
    return m_interfaceAction;
}

int RuleActionTemplate::selectionId() const
{
    return m_selectionId;
}

RuleActionTemplate::SelectionMode RuleActionTemplate::selectionMode() const
{
    return m_selectionMode;
}

RuleActionParams *RuleActionTemplate::ruleActionParams() const
{
    return m_ruleActionParams;
}

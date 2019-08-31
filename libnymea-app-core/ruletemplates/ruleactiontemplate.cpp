#include "ruleactiontemplate.h"
#include "ruleactionparamtemplate.h"

RuleActionTemplate::RuleActionTemplate(const QString &interfaceName, const QString &interfaceAction, int selectionId, RuleActionTemplate::SelectionMode selectionMode, RuleActionParamTemplates *params, QObject *parent):
    QObject(parent),
    m_interfaceName(interfaceName),
    m_interfaceAction(interfaceAction),
    m_selectionId(selectionId),
    m_selectionMode(selectionMode),
    m_ruleActionParamTemplates(params ? params : new RuleActionParamTemplates())
{
    m_ruleActionParamTemplates->setParent(this);
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

RuleActionParamTemplates *RuleActionTemplate::ruleActionParamTemplates() const
{
    return m_ruleActionParamTemplates;
}

QStringList RuleActionTemplates::interfaces() const
{
    QStringList ret;
    for (int i = 0; i < m_list.count(); i++) {
        ret.append(m_list.at(i)->interfaceName());
    }
    ret.removeDuplicates();
    return ret;
}

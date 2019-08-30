#include "ruletemplate.h"
#include "eventdescriptortemplate.h"
#include "stateevaluatortemplate.h"
#include "ruleactiontemplate.h"

RuleTemplate::RuleTemplate(const QString &interfaceName, const QString &description, const QString &ruleNameTemplate, QObject *parent):
    QObject(parent),
    m_interfaceName(interfaceName),
    m_description(description),
    m_ruleNameTemplate(ruleNameTemplate),
    m_eventDescriptorTemplates(new EventDescriptorTemplates(this)),
    m_ruleActionTemplates(new RuleActionTemplates(this)),
    m_ruleExitActionTemplates(new RuleActionTemplates(this))
{
}

QString RuleTemplate::description() const
{
    return m_description;
}

QString RuleTemplate::ruleNameTemplate() const
{
    return m_ruleNameTemplate;
}

QStringList RuleTemplate::interfaces() const
{
    QStringList ret;
    ret.append(m_eventDescriptorTemplates->interfaces());
    if (m_stateEvaluatorTemplate) {
        ret.append(m_stateEvaluatorTemplate->interfaces());
    }
    ret.append(m_ruleActionTemplates->interfaces());
    ret.append(m_ruleExitActionTemplates->interfaces());
    return ret;
}

EventDescriptorTemplates *RuleTemplate::eventDescriptorTemplates() const
{
    return m_eventDescriptorTemplates;
}

StateEvaluatorTemplate *RuleTemplate::stateEvaluatorTemplate() const
{
    return m_stateEvaluatorTemplate;
}

void RuleTemplate::setStateEvaluatorTemplate(StateEvaluatorTemplate *stateEvaluatorTemplate)
{
    if (m_stateEvaluatorTemplate) {
        m_stateEvaluatorTemplate->deleteLater();
    }
    stateEvaluatorTemplate->setParent(this);
    m_stateEvaluatorTemplate = stateEvaluatorTemplate;
}

RuleActionTemplates *RuleTemplate::ruleActionTemplates() const
{
    return m_ruleActionTemplates;
}

RuleActionTemplates *RuleTemplate::ruleExitActionTemplates() const
{
    return m_ruleExitActionTemplates;
}

#include "rule.h"

#include "eventdescriptors.h"
#include "ruleactions.h"
#include "stateevaluator.h"

Rule::Rule(const QUuid &id, QObject *parent) :
    QObject(parent),
    m_id(id),
    m_eventDescriptors(new EventDescriptors(this)),
    m_stateEvaluator(new StateEvaluator(this)),
    m_ruleActions(new RuleActions(this))
{

}

QUuid Rule::id() const
{
    return m_id;
}

QString Rule::name() const
{
    return m_name;
}

void Rule::setName(const QString &name)
{
    if (m_name != name) {
        m_name = name;
        emit nameChanged();
    }
}

bool Rule::enabled() const
{
    return m_enabled;
}

void Rule::setEnabled(bool enabled)
{
    if (m_enabled != enabled) {
        m_enabled = enabled;
        emit enabledChanged();
    }
}

EventDescriptors *Rule::eventDescriptors() const
{
    return m_eventDescriptors;
}

StateEvaluator *Rule::stateEvaluator() const
{
    return m_stateEvaluator;
}

RuleActions *Rule::ruleActions() const
{
    return m_ruleActions;
}

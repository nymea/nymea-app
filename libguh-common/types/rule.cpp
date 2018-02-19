#include "rule.h"

#include "eventdescriptor.h"
#include "eventdescriptors.h"
#include "stateevaluator.h"
#include "stateevaluators.h"
#include "ruleaction.h"
#include "ruleactions.h"

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

Rule *Rule::clone() const
{
    Rule *ret = new Rule(this->id());
    ret->setName(this->name());
    ret->setEnabled(this->enabled());
    for (int i = 0; i < this->eventDescriptors()->rowCount(); i++) {
        ret->eventDescriptors()->addEventDescriptor(this->eventDescriptors()->get(i)->clone());
    }
//    ret->stateEvaluator()->setStateDescriptor(this->stateEvaluator()->stateDescriptor()->clone());
//    ret->stateEvaluator()->setStateOperator(this->stateEvaluator()->stateOperator());
//    for (int i = 0; i < this->stateEvaluator()->childEvaluators()->rowCount(); i++) {
//        ret->stateEvaluator()->childEvaluators()->
//    }
    for (int i = 0; i < this->ruleActions()->rowCount(); i++) {
        ret->ruleActions()->addRuleAction(this->ruleActions()->get(i)->clone());
    }
    return ret;
}

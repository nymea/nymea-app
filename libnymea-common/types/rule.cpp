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
//    m_stateEvaluator(new StateEvaluator(this)),
    m_actions(new RuleActions(this)),
    m_exitActions(new RuleActions(this))
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

bool Rule::active() const
{
    return m_active;
}

void Rule::setActive(bool active)
{
    if (m_active != active) {
        m_active = active;
        emit activeChanged();
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

RuleActions *Rule::actions() const
{
    return m_actions;
}

RuleActions *Rule::exitActions() const
{
    return m_exitActions;
}

void Rule::setStateEvaluator(StateEvaluator *stateEvaluator)
{
    if (m_stateEvaluator) {
        m_stateEvaluator->deleteLater();
    }
    m_stateEvaluator = stateEvaluator;
    if (m_stateEvaluator) { // Might be a nullptr now if cleared
        m_stateEvaluator->setParent(this);
    }
    emit stateEvaluatorChanged();
}

void Rule::createStateEvaluator()
{
    setStateEvaluator(new StateEvaluator(this));
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
    for (int i = 0; i < this->actions()->rowCount(); i++) {
        ret->actions()->addRuleAction(this->actions()->get(i)->clone());
    }
    for (int i = 0; i < this->exitActions()->rowCount(); i++) {
        ret->exitActions()->addRuleAction(this->exitActions()->get(i)->clone());
    }
    return ret;
}

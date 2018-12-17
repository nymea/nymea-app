#include "rule.h"

#include "eventdescriptor.h"
#include "eventdescriptors.h"
#include "stateevaluator.h"
#include "stateevaluators.h"
#include "statedescriptor.h"
#include "ruleaction.h"
#include "ruleactions.h"
#include "timedescriptor.h"
#include "timeeventitems.h"
#include "timeeventitem.h"
#include "calendaritems.h"
#include "calendaritem.h"

#include <QDebug>

Rule::Rule(const QUuid &id, QObject *parent) :
    QObject(parent),
    m_id(id),
    m_eventDescriptors(new EventDescriptors(this)),
//    m_stateEvaluator(new StateEvaluator(this)),
    m_actions(new RuleActions(this)),
    m_exitActions(new RuleActions(this)),
    m_timeDescriptor(new TimeDescriptor(this))
{
//    qDebug() << "### Creating rule" << this;
}

Rule::~Rule()
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

bool Rule::executable() const
{
    return m_executable;
}

void Rule::setExecutable(bool executable)
{
    if (m_executable != executable) {
        m_executable = executable;
        emit executableChanged();
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

TimeDescriptor *Rule::timeDescriptor() const
{
    return m_timeDescriptor;
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

StateEvaluator* Rule::createStateEvaluator() const
{
    return new StateEvaluator();
}

Rule *Rule::clone() const
{
    Rule *ret = new Rule(this->id());
    ret->setName(this->name());
    ret->setEnabled(this->enabled());
    ret->setExecutable(this->executable());
    for (int i = 0; i < this->eventDescriptors()->rowCount(); i++) {
        ret->eventDescriptors()->addEventDescriptor(this->eventDescriptors()->get(i)->clone());
    }
    for (int i = 0; i < this->timeDescriptor()->timeEventItems()->rowCount(); i++) {
        ret->timeDescriptor()->timeEventItems()->addTimeEventItem(this->timeDescriptor()->timeEventItems()->get(i)->clone());
    }
    for (int i = 0; i < this->timeDescriptor()->calendarItems()->rowCount(); i++) {
        ret->timeDescriptor()->calendarItems()->addCalendarItem(this->timeDescriptor()->calendarItems()->get(i)->clone());
    }
    if (this->stateEvaluator()) {
        ret->setStateEvaluator(this->stateEvaluator()->clone());
    }
    for (int i = 0; i < this->actions()->rowCount(); i++) {
        ret->actions()->addRuleAction(this->actions()->get(i)->clone());
    }
    for (int i = 0; i < this->exitActions()->rowCount(); i++) {
        ret->exitActions()->addRuleAction(this->exitActions()->get(i)->clone());
    }
    return ret;
}

QDebug operator <<(QDebug &dbg, Rule *rule)
{
    dbg << rule->name() << " (Enabled:" << rule->enabled() << "Active:" << rule->active() << ")" << endl;
    if (rule->eventDescriptors()->rowCount() > 0) {
        dbg << "Event descriptors:" << endl;
    }
    for (int i = 0; i < rule->eventDescriptors()->rowCount(); i++) {
        EventDescriptor *ed = rule->eventDescriptors()->get(i);
        dbg << " " << i << ":";
        if (!ed->deviceId().isNull() && !ed->eventTypeId().isNull()) {
            dbg << "Device ID:" << ed->deviceId() << "Event Type ID:" << ed->eventTypeId() << endl;;
        } else {
            dbg << "Interface Name:" << ed->interfaceName() << "Event Name:" << ed->interfaceEvent() << endl;;
        }
    }
    dbg << "State Evaluator:" << endl;
    printStateEvaluator(dbg, rule->stateEvaluator());

    if (rule->actions()->rowCount() > 0) {
        dbg << "Actions:" << endl;
    }
    for (int i = 0; i < rule->actions()->rowCount(); i++) {
        RuleAction *ra = rule->actions()->get(i);
        dbg << " " << i << ":";
        if (!ra->deviceId().isNull() && !ra->actionTypeId().isNull()) {
            dbg << "Device ID:" << ra->deviceId() << "Action Type ID:" << ra->actionTypeId() << endl;;
        } else {
            dbg << "Interface Name:" << ra->interfaceName() << "Action Name:" << ra->interfaceAction() << endl;;
        }
    }

    if (rule->exitActions()->rowCount() > 0) {
        dbg << "Exit Actions:" << endl;
    }
    for (int i = 0; i < rule->exitActions()->rowCount(); i++) {
        RuleAction *ra = rule->exitActions()->get(i);
        dbg << " " << i << ":";
        if (!ra->deviceId().isNull() && !ra->actionTypeId().isNull()) {
            dbg << "Device ID:" << ra->deviceId() << "Action Type ID:" << ra->actionTypeId() << endl;;
        } else {
            dbg << "Interface Name:" << ra->interfaceName() << "Action Name:" << ra->interfaceAction() << endl;;
        }
    }
    return dbg;
}

QDebug printStateEvaluator(QDebug &dbg, StateEvaluator *stateEvaluator, int indentLevel)
{
    if (stateEvaluator->stateDescriptor()) {
        for (int i = 0; i < indentLevel; i++) { dbg << " "; }
        dbg << "State Descriptor:";
        if (!stateEvaluator->stateDescriptor()->deviceId().isNull() && !stateEvaluator->stateDescriptor()->stateTypeId().isNull()) {
            dbg << "Device ID:" << stateEvaluator->stateDescriptor()->deviceId().toString() << stateEvaluator->stateDescriptor()->stateTypeId().toString();
        } else {
            dbg << "Interface name:" << stateEvaluator->stateDescriptor()->interfaceName() << stateEvaluator->stateDescriptor()->interfaceState();
        }
        switch (stateEvaluator->stateDescriptor()->valueOperator()) {
        case StateDescriptor::ValueOperatorLess:
            dbg << "<";
            break;
        case StateDescriptor::ValueOperatorEquals:
            dbg << "=";
            break;
        case StateDescriptor::ValueOperatorGreater:
            dbg << ">";
            break;
        case StateDescriptor::ValueOperatorNotEquals:
            dbg << "!=";
            break;
        case StateDescriptor::ValueOperatorLessOrEqual:
            dbg << "<=";
            break;
        case StateDescriptor::ValueOperatorGreaterOrEqual:
            dbg << ">=";
            break;
        }
        dbg << stateEvaluator->stateDescriptor()->value() << endl;
    }
    if (stateEvaluator->childEvaluators()->rowCount() > 0) {
        for (int i = 0; i < indentLevel; i++) { dbg << " "; }
        dbg << (stateEvaluator->stateOperator() == StateEvaluator::StateOperatorAnd ? "AND" : "OR") << endl;
    }
    for (int i = 0; i < stateEvaluator->childEvaluators()->rowCount(); i++) {
        printStateEvaluator(dbg, stateEvaluator->childEvaluators()->get(i), indentLevel+1);
    }
    return dbg;
}

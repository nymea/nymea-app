#include "rulemanager.h"

#include "jsonrpc/jsonrpcclient.h"
#include "jsonrpc/jsontypes.h"
#include "types/rule.h"
#include "types/eventdescriptor.h"
#include "types/eventdescriptors.h"
#include "types/ruleactions.h"
#include "types/ruleaction.h"
#include "types/ruleactionparams.h"
#include "types/ruleactionparam.h"
#include "types/stateevaluator.h"
#include "types/stateevaluators.h"
#include "types/statedescriptor.h"
#include "types/timedescriptor.h"
#include "types/timeeventitems.h"
#include "types/timeeventitem.h"
#include "types/repeatingoption.h"
#include "types/calendaritems.h"
#include "types/calendaritem.h"

#include <QMetaEnum>

RuleManager::RuleManager(JsonRpcClient* jsonClient, QObject *parent) :
    JsonHandler(parent),
    m_jsonClient(jsonClient),
    m_rules(new Rules(this))
{
    m_jsonClient->registerNotificationHandler(this, "handleRulesNotification");
}

QString RuleManager::nameSpace() const
{
    return "Rules";
}

void RuleManager::clear()
{
    m_rules->clear();
}

void RuleManager::init()
{
    m_jsonClient->sendCommand("Rules.GetRules", this, "getRulesReply");
}

Rules *RuleManager::rules() const
{
    return m_rules;
}

Rule *RuleManager::createNewRule()
{
    return new Rule(QUuid(), this);
}

void RuleManager::addRule(const QVariantMap params)
{
    m_jsonClient->sendCommand("Rules.AddRule", params, this, "onAddRuleReply");
}

void RuleManager::addRule(Rule *rule)
{
    QVariantMap params = JsonTypes::packRule(rule);
    m_jsonClient->sendCommand("Rules.AddRule", params, this, "onAddRuleReply");
}

void RuleManager::removeRule(const QUuid &ruleId)
{
    QVariantMap params;
    params.insert("ruleId", ruleId);
    m_jsonClient->sendCommand("Rules.RemoveRule", params, this, "removeRuleReply");
}

void RuleManager::editRule(Rule *rule)
{
    QVariantMap params = JsonTypes::packRule(rule);
    qWarning() << "Packed rule:" << qUtf8Printable(QJsonDocument::fromVariant(params).toJson(QJsonDocument::Indented));
    m_jsonClient->sendCommand("Rules.EditRule", params, this, "onEditRuleReply");

}

void RuleManager::executeActions(const QString &ruleId)
{
    QVariantMap params;
    params.insert("ruleId", ruleId);
    m_jsonClient->sendCommand("Rules.ExecuteActions", params, this, "onExecuteRuleActionsReply");
}

void RuleManager::handleRulesNotification(const QVariantMap &params)
{
    qDebug() << "Rules notification received:" << qUtf8Printable(QJsonDocument::fromVariant(params).toJson(QJsonDocument::Indented));
    if (params.value("notification").toString() == "Rules.RuleAdded") {
        QVariantMap ruleMap = params.value("params").toMap().value("rule").toMap();
        Rule *rule = parseRule(ruleMap);
        qDebug() << "Rule added:" << rule;
        m_rules->insert(rule);
    } else if (params.value("notification").toString() == "Rules.RuleRemoved") {
        QUuid ruleId = params.value("params").toMap().value("ruleId").toUuid();
        m_rules->remove(ruleId);
    } else if (params.value("notification").toString() == "Rules.RuleConfigurationChanged") {
        QVariantMap ruleMap = params.value("params").toMap().value("rule").toMap();
        QUuid ruleId = ruleMap.value("id").toUuid();
        Rule *rule = m_rules->getRule(ruleId);
        if (!rule) {
            qWarning() << "Got a rule update notification for a rule we don't know" << ruleId;
            return;
        }
        m_rules->remove(ruleId);
        Rule *newRule = parseRule(ruleMap);
        m_rules->insert(newRule);
        qDebug() << "Rule changed:" << newRule;
    } else if (params.value("notification").toString() == "Rules.RuleActiveChanged") {
        Rule *rule = m_rules->getRule(params.value("params").toMap().value("ruleId").toUuid());
        if (!rule) {
            qWarning() << "Got a rule active notification for a rule we don't know";
            return;
        }
        rule->setActive(params.value("params").toMap().value("active").toBool());
    } else {
        qWarning() << "Unhandled rule notification" << params;
    }
}

void RuleManager::getRulesReply(const QVariantMap &params)
{
    if (params.value("status").toString() != "success") {
        qWarning() << "Error getting rules:" << params.value("error").toString();
        return;
    }
//    qDebug() << "Get Rules reply" << params;
    foreach (const QVariant &ruleDescriptionVariant, params.value("params").toMap().value("ruleDescriptions").toList()) {
        QUuid ruleId = ruleDescriptionVariant.toMap().value("id").toUuid();
        QString name = ruleDescriptionVariant.toMap().value("name").toString();
        bool enabled = ruleDescriptionVariant.toMap().value("enabled").toBool();
        bool active = ruleDescriptionVariant.toMap().value("active").toBool();
        bool executable = ruleDescriptionVariant.toMap().value("executable").toBool();

        Rule *rule = new Rule(ruleId, m_rules);
        rule->setName(name);
        rule->setEnabled(enabled);
        rule->setActive(active);
        rule->setExecutable(executable);
        m_rules->insert(rule);

        QVariantMap requestParams;
        requestParams.insert("ruleId", rule->id());
        m_jsonClient->sendCommand("Rules.GetRuleDetails", requestParams, this, "getRuleDetailsReply");
    }
}

void RuleManager::getRuleDetailsReply(const QVariantMap &params)
{
    QVariantMap ruleMap = params.value("params").toMap().value("rule").toMap();
    Rule* rule = m_rules->getRule(ruleMap.value("id").toUuid());
    if (!rule) {
        qWarning() << "Got rule details for a rule we don't know";
        return;
    }
    parseEventDescriptors(ruleMap.value("eventDescriptors").toList(), rule);
    parseRuleActions(ruleMap.value("actions").toList(), rule);
    parseRuleExitActions(ruleMap.value("exitActions").toList(), rule);
    parseTimeDescriptor(ruleMap.value("timeDescriptor").toMap(), rule);
    rule->setStateEvaluator(parseStateEvaluator(ruleMap.value("stateEvaluator").toMap()));
//    qDebug() << "** Rule details received:" << rule;
//    qDebug() << "Rule JSON:" << qUtf8Printable(QJsonDocument::fromVariant(ruleMap).toJson());
}

void RuleManager::onAddRuleReply(const QVariantMap &params)
{
    qDebug() << "Add rule reply:" << params;//.value("params").toMap().value("ruleError").toString();
    emit addRuleReply(params.value("params").toMap().value("ruleError").toString(), params.value("params").toMap().value("ruleId").toString());
}

void RuleManager::removeRuleReply(const QVariantMap &params)
{
    qDebug() << "Have remove rule reply" << params;

}

void RuleManager::onEditRuleReply(const QVariantMap &params)
{
    if (params.value("status").toString() == "error") {
        qDebug() << "Bad request editing rule:" << params.value("error").toString();
    }
    if (params.value("params").toMap().value("ruleError").toString() != "RuleErrorNoError") {
        qDebug() << "Bad rule:" << params.value("params").toMap().value("ruleError").toString();
    }
    emit editRuleReply(params.value("params").toMap().value("ruleError").toString());
}

void RuleManager::onExecuteRuleActionsReply(const QVariantMap &params)
{
    qDebug() << "Execute rule actions reply:" << params;
}

Rule *RuleManager::parseRule(const QVariantMap &ruleMap)
{
    QUuid ruleId = ruleMap.value("id").toUuid();
    QString name = ruleMap.value("name").toString();
    bool enabled = ruleMap.value("enabled").toBool();
    bool active = ruleMap.value("active").toBool();
    bool executable = ruleMap.value("executable").toBool();
    Rule* rule = new Rule(ruleId);
    rule->setName(name);
    rule->setEnabled(enabled);
    rule->setActive(active);
    rule->setExecutable(executable);
    parseEventDescriptors(ruleMap.value("eventDescriptors").toList(), rule);
    parseRuleActions(ruleMap.value("actions").toList(), rule);
    parseRuleExitActions(ruleMap.value("exitActions").toList(), rule);
    parseTimeDescriptor(ruleMap.value("timeDescriptor").toMap(), rule);
    rule->setStateEvaluator(parseStateEvaluator(ruleMap.value("stateEvaluator").toMap()));
    return rule;
}

void RuleManager::parseEventDescriptors(const QVariantList &eventDescriptorList, Rule *rule)
{
    foreach (const QVariant &eventDescriptorVariant, eventDescriptorList) {
        EventDescriptor *eventDescriptor = new EventDescriptor(rule);
        eventDescriptor->setDeviceId(eventDescriptorVariant.toMap().value("deviceId").toString());
        eventDescriptor->setEventTypeId(eventDescriptorVariant.toMap().value("eventTypeId").toString());
        eventDescriptor->setInterfaceName(eventDescriptorVariant.toMap().value("interface").toString());
        eventDescriptor->setInterfaceEvent(eventDescriptorVariant.toMap().value("interfaceEvent").toString());
        foreach (const QVariant &paramDescriptorVariant, eventDescriptorVariant.toMap().value("paramDescriptors").toList()) {
            ParamDescriptor *paramDescriptor = new ParamDescriptor();
            paramDescriptor->setParamTypeId(paramDescriptorVariant.toMap().value("paramTypeId").toString());
            paramDescriptor->setParamName(paramDescriptorVariant.toMap().value("paramName").toString());
            paramDescriptor->setValue(paramDescriptorVariant.toMap().value("value"));
            QMetaEnum operatorEnum = QMetaEnum::fromType<ParamDescriptor::ValueOperator>();
            paramDescriptor->setOperatorType((ParamDescriptor::ValueOperator)operatorEnum.keyToValue(paramDescriptorVariant.toMap().value("operator").toString().toLocal8Bit()));
            eventDescriptor->paramDescriptors()->addParamDescriptor(paramDescriptor);
        }
//        qDebug() << "Adding eventdescriptor" << eventDescriptor->deviceId() << eventDescriptor->eventTypeId();
        rule->eventDescriptors()->addEventDescriptor(eventDescriptor);
    }
}

StateEvaluator *RuleManager::parseStateEvaluator(const QVariantMap &stateEvaluatorMap)
{
//    qDebug() << "Parsing state evaluator. Child count:" << stateEvaluatorMap.value("childEvaluators").toList().count();
    if (!stateEvaluatorMap.contains("stateDescriptor")) {
        return nullptr;
    }
    StateEvaluator *stateEvaluator = new StateEvaluator(this);
    QVariantMap sdMap = stateEvaluatorMap.value("stateDescriptor").toMap();
    QMetaEnum operatorEnum = QMetaEnum::fromType<StateDescriptor::ValueOperator>();
    StateDescriptor::ValueOperator op = (StateDescriptor::ValueOperator)operatorEnum.keyToValue(sdMap.value("operator").toByteArray());

    StateDescriptor *sd = nullptr;
    if (sdMap.contains("deviceId") && sdMap.contains("stateTypeId")) {
         sd = new StateDescriptor(sdMap.value("deviceId").toUuid(), sdMap.value("stateTypeId").toUuid(), op, sdMap.value("value"), stateEvaluator);
    } else {
        sd = new StateDescriptor(sdMap.value("interface").toString(), sdMap.value("interfaceState").toString(), op, sdMap.value("value"), stateEvaluator);
    }
    stateEvaluator->setStateDescriptor(sd);

    foreach (const QVariant &childEvaluatorVariant, stateEvaluatorMap.value("childEvaluators").toList()) {
        StateEvaluator *childEvaluator = parseStateEvaluator(childEvaluatorVariant.toMap());
        if (childEvaluator) {
            stateEvaluator->childEvaluators()->addStateEvaluator(childEvaluator);
        }
    }
    operatorEnum = QMetaEnum::fromType<StateEvaluator::StateOperator>();
    stateEvaluator->setStateOperator((StateEvaluator::StateOperator)operatorEnum.keyToValue(stateEvaluatorMap.value("operator").toByteArray()));
    return stateEvaluator;
}

void RuleManager::parseRuleActions(const QVariantList &ruleActions, Rule *rule)
{
    foreach (const QVariant &ruleActionVariant, ruleActions) {
        rule->actions()->addRuleAction(parseRuleAction(ruleActionVariant.toMap()));
    }
}

void RuleManager::parseRuleExitActions(const QVariantList &ruleActions, Rule *rule)
{
    foreach (const QVariant &ruleActionVariant, ruleActions) {
        rule->exitActions()->addRuleAction(parseRuleAction(ruleActionVariant.toMap()));
    }
}

RuleAction *RuleManager::parseRuleAction(const QVariantMap &ruleAction)
{
    RuleAction *ret = new RuleAction();
    if (ruleAction.contains("deviceId") && ruleAction.contains("actionTypeId")) {
        ret->setDeviceId(ruleAction.value("deviceId").toUuid());
        ret->setActionTypeId(ruleAction.value("actionTypeId").toUuid());
    } else {
        ret->setInterfaceName(ruleAction.value("interface").toString());
        ret->setInterfaceAction(ruleAction.value("interfaceAction").toString());
    }
    foreach (const QVariant &ruleActionParamVariant, ruleAction.value("ruleActionParams").toList()) {
        RuleActionParam *param = new RuleActionParam();
        param->setParamTypeId(ruleActionParamVariant.toMap().value("paramTypeId").toString());
        param->setParamName(ruleActionParamVariant.toMap().value("paramName").toString());
        param->setValue(ruleActionParamVariant.toMap().value("value"));
        param->setEventTypeId(ruleActionParamVariant.toMap().value("eventTypeId").toString());
        param->setEventParamTypeId(ruleActionParamVariant.toMap().value("eventParamTypeId").toString());
        param->setStateDeviceId(ruleActionParamVariant.toMap().value("stateDeviceId").toString());
        param->setStateTypeId(ruleActionParamVariant.toMap().value("stateTypeId").toString());
        ret->ruleActionParams()->addRuleActionParam(param);
    }
    return ret;
}

void RuleManager::parseTimeDescriptor(const QVariantMap &timeDescriptor, Rule *rule)
{
    foreach (const QVariant &timeEventItemVariant, timeDescriptor.value("timeEventItems").toList()) {
        TimeEventItem *timeEventItem = new TimeEventItem();
        if (timeEventItemVariant.toMap().contains("datetime")) {
            timeEventItem->setDateTime(QDateTime::fromSecsSinceEpoch(timeEventItemVariant.toMap().value("datetime").toULongLong()));
        }
        if (timeEventItemVariant.toMap().contains("time")){
            timeEventItem->setTime(QTime::fromString(timeEventItemVariant.toMap().value("time").toString()));
        }
        QVariantMap repeatingOptionMap = timeEventItemVariant.toMap().value("repeating").toMap();
        QMetaEnum modeEnum = QMetaEnum::fromType<RepeatingOption::RepeatingMode>();
        timeEventItem->repeatingOption()->setRepeatingMode((RepeatingOption::RepeatingMode)modeEnum.keyToValue(repeatingOptionMap.value("mode").toByteArray()));
        timeEventItem->repeatingOption()->setWeekDays(repeatingOptionMap.value("weekDays").toList());
        timeEventItem->repeatingOption()->setMonthDays(repeatingOptionMap.value("monthDays").toList());
        rule->timeDescriptor()->timeEventItems()->addTimeEventItem(timeEventItem);
    }
    foreach (const QVariant &calendarItemVariant, timeDescriptor.value("calendarItems").toList()) {
        CalendarItem *calendarItem = new CalendarItem();
        if (calendarItemVariant.toMap().contains("datetime")) {
            calendarItem->setDateTime(QDateTime::fromSecsSinceEpoch(calendarItemVariant.toMap().value("datetime").toULongLong()));
        }
        if (calendarItemVariant.toMap().contains("startTime")) {
            calendarItem->setStartTime(QTime::fromString(calendarItemVariant.toMap().value("startTime").toString()));
        }
        calendarItem->setDuration(calendarItemVariant.toMap().value("duration").toInt());
        QVariantMap repeatingOptionMap = calendarItemVariant.toMap().value("repeating").toMap();
        QMetaEnum modeEnum = QMetaEnum::fromType<RepeatingOption::RepeatingMode>();
        calendarItem->repeatingOption()->setRepeatingMode((RepeatingOption::RepeatingMode)modeEnum.keyToValue(repeatingOptionMap.value("mode").toByteArray()));
        calendarItem->repeatingOption()->setWeekDays(repeatingOptionMap.value("weekDays").toList());
        calendarItem->repeatingOption()->setMonthDays(repeatingOptionMap.value("monthDays").toList());
        rule->timeDescriptor()->calendarItems()->addCalendarItem(calendarItem);
    }
//    rule->timeDescriptor()
}

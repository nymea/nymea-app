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
    return new Rule();
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
    qWarning() << "Packed rule:" << params;
    m_jsonClient->sendCommand("Rules.EditRule", params, this, "onEditRuleReply");

}

void RuleManager::handleRulesNotification(const QVariantMap &params)
{
//    qDebug() << "rules notification received" << params;
    if (params.value("notification").toString() == "Rules.RuleAdded") {
        QVariantMap ruleMap = params.value("params").toMap().value("rule").toMap();
        m_rules->insert(parseRule(ruleMap));
    } else if (params.value("notification").toString() == "Rules.RuleRemoved") {
        QUuid ruleId = params.value("params").toMap().value("ruleId").toUuid();
        m_rules->remove(ruleId);
    } else if (params.value("notification").toString() == "Rules.RuleConfigurationChanged") {
        QVariantMap ruleMap = params.value("params").toMap().value("rule").toMap();
        QUuid ruleId = ruleMap.value("id").toUuid();
        int idx = -1;
        for (int i = 0; i < m_rules->rowCount(); i++) {
            if (m_rules->get(i)->id() == ruleId) {
                idx = i;
                break;
            }
        }
        if (idx == -1) {
            qWarning() << "Got a rule update notification for a rule we don't know" << ruleId;
            return;
        }
        m_rules->remove(ruleId);
        m_rules->insert(parseRule(ruleMap));
    } else if (params.value("notification").toString() == "Rules.RuleActiveChanged") {
        m_rules->getRule(params.value("params").toMap().value("ruleId").toUuid())->setActive(params.value("params").toMap().value("active").toBool());
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
    foreach (const QVariant &ruleDescriptionVariant, params.value("params").toMap().value("ruleDescriptions").toList()) {
        QUuid ruleId = ruleDescriptionVariant.toMap().value("id").toUuid();
        QString name = ruleDescriptionVariant.toMap().value("name").toString();
        bool enabled = ruleDescriptionVariant.toMap().value("enabled").toBool();
        bool active = ruleDescriptionVariant.toMap().value("active").toBool();

        Rule *rule = new Rule(ruleId, m_rules);
        rule->setName(name);
        rule->setEnabled(enabled);
        rule->setActive(active);
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
        qDebug() << "Got rule details for a rule we don't know";
        return;
    }
    qDebug() << "got rule details for rule" << ruleMap;
    parseEventDescriptors(ruleMap.value("eventDescriptors").toList(), rule);
    parseRuleActions(ruleMap.value("actions").toList(), rule);
    parseRuleExitActions(ruleMap.value("exitActions").toList(), rule);
    rule->setStateEvaluator(parseStateEvaluator(ruleMap.value("stateEvaluator").toMap()));
}

void RuleManager::onAddRuleReply(const QVariantMap &params)
{
    qDebug() << "Add rule reply" << params;
    emit addRuleReply(params.value("params").toMap().value("ruleError").toString());
}

void RuleManager::removeRuleReply(const QVariantMap &params)
{
    qDebug() << "Have remove rule reply" << params;
}

void RuleManager::onEditRuleReply(const QVariantMap &params)
{
    qDebug() << "Edit rule reply:" << params.value("params").toMap().value("ruleError").toString();
    emit editRuleReply(params.value("params").toMap().value("ruleError").toString());
}

Rule *RuleManager::parseRule(const QVariantMap &ruleMap)
{
    QUuid ruleId = ruleMap.value("id").toUuid();
    QString name = ruleMap.value("name").toString();
    bool enabled = ruleMap.value("enabled").toBool();
    bool active = ruleMap.value("active").toBool();
    Rule* rule = new Rule(ruleId);
    rule->setName(name);
    rule->setEnabled(enabled);
    rule->setActive(active);
    parseEventDescriptors(ruleMap.value("eventDescriptors").toList(), rule);
    parseRuleActions(ruleMap.value("actions").toList(), rule);
    parseRuleExitActions(ruleMap.value("exitActions").toList(), rule);
    rule->setStateEvaluator(parseStateEvaluator(ruleMap.value("stateEvaluator").toMap()));
    return rule;
}

void RuleManager::parseEventDescriptors(const QVariantList &eventDescriptorList, Rule *rule)
{
    foreach (const QVariant &eventDescriptorVariant, eventDescriptorList) {
        EventDescriptor *eventDescriptor = new EventDescriptor(rule);
        eventDescriptor->setDeviceId(eventDescriptorVariant.toMap().value("deviceId").toUuid());
        eventDescriptor->setEventTypeId(eventDescriptorVariant.toMap().value("eventTypeId").toUuid());
        eventDescriptor->setInterfaceName(eventDescriptorVariant.toMap().value("interface").toString());
        eventDescriptor->setInterfaceEvent(eventDescriptorVariant.toMap().value("interfaceEvent").toString());
        foreach (const QVariant &paramDescriptorVariant, eventDescriptorVariant.toMap().value("paramDescriptors").toList()) {
            ParamDescriptor *paramDescriptor = new ParamDescriptor(paramDescriptorVariant.toMap().value("paramTypeId").toString(), paramDescriptorVariant.toMap().value("value"));
            QMetaEnum operatorEnum = QMetaEnum::fromType<ParamDescriptor::ValueOperator>();
            paramDescriptor->setOperatorType((ParamDescriptor::ValueOperator)operatorEnum.keyToValue(paramDescriptorVariant.toMap().value("operator").toString().toLocal8Bit()));
            eventDescriptor->paramDescriptors()->addParamDescriptor(paramDescriptor);
        }
        rule->eventDescriptors()->addEventDescriptor(eventDescriptor);
    }
}

StateEvaluator *RuleManager::parseStateEvaluator(const QVariantMap &stateEvaluatorMap)
{
    qDebug() << "bla" << stateEvaluatorMap;
    StateEvaluator *stateEvaluator = new StateEvaluator(this);
    if (stateEvaluatorMap.contains("stateDescriptor")) {
        QVariantMap sdMap = stateEvaluatorMap.value("stateDescriptor").toMap();
        QMetaEnum operatorEnum = QMetaEnum::fromType<StateDescriptor::ValueOperator>();
        StateDescriptor::ValueOperator op = (StateDescriptor::ValueOperator)operatorEnum.keyToValue(sdMap.value("operator").toByteArray());
        StateDescriptor *sd = new StateDescriptor(sdMap.value("deviceId").toUuid(), op, sdMap.value("stateTypeId").toUuid(), sdMap.value("value"), stateEvaluator);
        stateEvaluator->setStateDescriptor(sd);
    }

    foreach (const QVariant &childEvaluatorVariant, stateEvaluatorMap.value("childEvaluators").toList()) {
        stateEvaluator->childEvaluators()->addStateEvaluator(parseStateEvaluator(childEvaluatorVariant.toMap()));
    }
    QMetaEnum operatorEnum = QMetaEnum::fromType<StateEvaluator::StateOperator>();
    stateEvaluator->setStateOperator((StateEvaluator::StateOperator)operatorEnum.keyToValue(stateEvaluatorMap.value("operator").toByteArray()));
    return stateEvaluator;
}

void RuleManager::parseRuleActions(const QVariantList &ruleActions, Rule *rule)
{
    foreach (const QVariant &ruleActionVariant, ruleActions) {
        RuleAction *ruleAction = new RuleAction();
        ruleAction->setDeviceId(ruleActionVariant.toMap().value("deviceId").toUuid());
        ruleAction->setActionTypeId(ruleActionVariant.toMap().value("actionTypeId").toUuid());
        foreach (const QVariant &ruleActionParamVariant, ruleActionVariant.toMap().value("ruleActionParams").toList()) {
            RuleActionParam *param = new RuleActionParam();
            param->setParamTypeId(ruleActionParamVariant.toMap().value("paramTypeId").toUuid());
            param->setValue(ruleActionParamVariant.toMap().value("value"));
            ruleAction->ruleActionParams()->addRuleActionParam(param);
        }
        rule->actions()->addRuleAction(ruleAction);
    }
}

void RuleManager::parseRuleExitActions(const QVariantList &ruleActions, Rule *rule)
{
    foreach (const QVariant &ruleActionVariant, ruleActions) {
        RuleAction *ruleAction = new RuleAction();
        ruleAction->setDeviceId(ruleActionVariant.toMap().value("deviceId").toUuid());
        ruleAction->setActionTypeId(ruleActionVariant.toMap().value("actionTypeId").toUuid());
        foreach (const QVariant &ruleActionParamVariant, ruleActionVariant.toMap().value("ruleActionParams").toList()) {
            RuleActionParam *param = new RuleActionParam();
            param->setParamTypeId(ruleActionParamVariant.toMap().value("paramTypeId").toUuid());
            param->setValue(ruleActionParamVariant.toMap().value("value"));
            ruleAction->ruleActionParams()->addRuleActionParam(param);
        }
        rule->exitActions()->addRuleAction(ruleAction);
    }
}

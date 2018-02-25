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
    m_jsonClient->sendCommand("Rules.EditRule", params, this, "onEditRuleReply");

}

void RuleManager::handleRulesNotification(const QVariantMap &params)
{
//    qDebug() << "rules notification received" << params;
    if (params.value("notification").toString() == "Rules.RuleAdded") {
        QVariantMap ruleMap = params.value("params").toMap().value("rule").toMap();
        QUuid ruleId = ruleMap.value("id").toUuid();
        QString name = ruleMap.value("name").toString();
        bool enabled = ruleMap.value("enabled").toBool();
        bool active = ruleMap.value("active").toBool();
        Rule* rule = new Rule(ruleId, m_rules);
        rule->setName(name);
        rule->setEnabled(enabled);
        rule->setActive(active);
        parseEventDescriptors(ruleMap.value("eventDescriptors").toList(), rule);
        StateEvaluator* stateEvaluator = parseStateEvaluator(ruleMap.value("stateEvaluator").toMap());
        stateEvaluator->setParent(rule);

        parseRuleActions(ruleMap.value("actions").toList(), rule);
        m_rules->insert(rule);
    } else if (params.value("notification").toString() == "Rules.RuleRemoved") {
        QUuid ruleId = params.value("params").toMap().value("ruleId").toUuid();
        m_rules->remove(ruleId);
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

        Rule *rule = new Rule(ruleId, m_rules);
        rule->setName(name);
        rule->setEnabled(enabled);
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
//    qDebug() << "got rule details for rule" << ruleMap;
    parseEventDescriptors(ruleMap.value("eventDescriptors").toList(), rule);
    parseRuleActions(ruleMap.value("actions").toList(), rule);
     parseStateEvaluator(ruleMap.value("stateEvaluator").toMap());
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

void RuleManager::parseEventDescriptors(const QVariantList &eventDescriptorList, Rule *rule)
{
    foreach (const QVariant &eventDescriptorVariant, eventDescriptorList) {
        EventDescriptor *eventDescriptor = new EventDescriptor(rule);
        eventDescriptor->setDeviceId(eventDescriptorVariant.toMap().value("deviceId").toUuid());
        eventDescriptor->setEventTypeId(eventDescriptorVariant.toMap().value("eventTypeId").toUuid());
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
    StateEvaluator *stateEvaluator = new StateEvaluator(this);
    if (stateEvaluatorMap.contains("stateDescriptor")) {
        QVariantMap sdMap = stateEvaluatorMap.value("sateDescriptor").toMap();
        QString operatorString = sdMap.value("stateOperator").toString();
        StateDescriptor::ValueOperator op;
        if (operatorString == "ValueOperatorEquals") {
            op = StateDescriptor::ValueOperatorEquals;
        } else if (operatorString == "ValueOperatorNotEquals") {
            op = StateDescriptor::ValueOperatorNotEquals;
        } else if (operatorString == "ValueOperatorLess") {
            op = StateDescriptor::ValueOperatorLess;
        } else if (operatorString == "ValueOperatorGreater") {
            op = StateDescriptor::ValueOperatorGreater;
        } else if (operatorString == "ValueOperatorLessOrEqual") {
            op = StateDescriptor::ValueOperatorLessOrEqual;
        } else if (operatorString == "ValueOperatorGreaterOrEqual") {
            op = StateDescriptor::ValueOperatorGreaterOrEqual;
        }
        StateDescriptor *sd = new StateDescriptor(sdMap.value("deviceId").toUuid(), op, sdMap.value("stateTypeId").toUuid(), sdMap.value("value"), stateEvaluator);
        stateEvaluator->setStateDescriptor(sd);

    }
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
        rule->ruleActions()->addRuleAction(ruleAction);
    }
}

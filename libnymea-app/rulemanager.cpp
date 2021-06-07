/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
* Copyright 2013 - 2020, nymea GmbH
* Contact: contact@nymea.io
*
* This file is part of nymea.
* This project including source code and documentation is protected by
* copyright law, and remains the property of nymea GmbH. All rights, including
* reproduction, publication, editing and translation, are reserved. The use of
* this project is subject to the terms of a license agreement to be concluded
* with nymea GmbH in accordance with the terms of use of nymea GmbH, available
* under https://nymea.io/license
*
* GNU General Public License Usage
* Alternatively, this project may be redistributed and/or modified under the
* terms of the GNU General Public License as published by the Free Software
* Foundation, GNU version 3. This project is distributed in the hope that it
* will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty
* of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
* Public License for more details.
*
* You should have received a copy of the GNU General Public License along with
* this project. If not, see <https://www.gnu.org/licenses/>.
*
* For any further details and any questions please contact us under
* contact@nymea.io or see our FAQ/Licensing Information on
* https://nymea.io/license/faq
*
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#include "rulemanager.h"

#include "jsonrpc/jsonrpcclient.h"
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
#include "logging.h"

NYMEA_LOGGING_CATEGORY(dcRuleManager, "RuleManager")

#include <QMetaEnum>
#include <QJsonDocument>

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
    m_fetchingData = true;
    emit fetchingDataChanged();
    m_jsonClient->sendCommand("Rules.GetRules", this, "getRulesResponse");
}

bool RuleManager::fetchingData() const
{
    return m_fetchingData;
}

Rules *RuleManager::rules() const
{
    return m_rules;
}

Rule *RuleManager::createNewRule()
{
    return new Rule(QUuid(), this);
}

int RuleManager::addRule(const QVariantMap params)
{
    return m_jsonClient->sendCommand("Rules.AddRule", params, this, "addRuleResponse");
}

int RuleManager::addRule(Rule *rule)
{
    QVariantMap params = packRule(rule);
    qCDebug(dcRuleManager) << "packed rule:" << qUtf8Printable(QJsonDocument::fromVariant(params).toJson(QJsonDocument::Indented));
    return m_jsonClient->sendCommand("Rules.AddRule", params, this, "addRuleResponse");
}

int RuleManager::removeRule(const QUuid &ruleId)
{
    QVariantMap params;
    params.insert("ruleId", ruleId);
    return m_jsonClient->sendCommand("Rules.RemoveRule", params, this, "removeRuleResponse");
}

int RuleManager::editRule(Rule *rule)
{
    QVariantMap params = packRule(rule);
    qCDebug(dcRuleManager) << "Packed rule:" << qUtf8Printable(QJsonDocument::fromVariant(params).toJson(QJsonDocument::Indented));
    return m_jsonClient->sendCommand("Rules.EditRule", params, this, "editRuleResponse");
}

int RuleManager::executeActions(const QString &ruleId)
{
    QVariantMap params;
    params.insert("ruleId", ruleId);
    return m_jsonClient->sendCommand("Rules.ExecuteActions", params, this, "executeRuleActionsResponse");
}

void RuleManager::handleRulesNotification(const QVariantMap &params)
{
    qCDebug(dcRuleManager) << "Rules notification received:" << qUtf8Printable(QJsonDocument::fromVariant(params).toJson(QJsonDocument::Indented));
    if (params.value("notification").toString() == "Rules.RuleAdded") {
        QVariantMap ruleMap = params.value("params").toMap().value("rule").toMap();
        Rule *rule = parseRule(ruleMap);
        qCDebug(dcRuleManager) << "Rule added:" << rule;
        m_rules->insert(rule);
    } else if (params.value("notification").toString() == "Rules.RuleRemoved") {
        QUuid ruleId = params.value("params").toMap().value("ruleId").toUuid();
        m_rules->remove(ruleId);
    } else if (params.value("notification").toString() == "Rules.RuleConfigurationChanged") {
        QVariantMap ruleMap = params.value("params").toMap().value("rule").toMap();
        QUuid ruleId = ruleMap.value("id").toUuid();
        Rule *rule = m_rules->getRule(ruleId);
        if (!rule) {
            qCWarning(dcRuleManager) << "Got a rule update notification for a rule we don't know" << ruleId;
            return;
        }
        m_rules->remove(ruleId);
        Rule *newRule = parseRule(ruleMap);
        m_rules->insert(newRule);
        qCDebug(dcRuleManager) << "Rule changed:" << newRule;
    } else if (params.value("notification").toString() == "Rules.RuleActiveChanged") {
        Rule *rule = m_rules->getRule(params.value("params").toMap().value("ruleId").toUuid());
        if (!rule) {
            qCWarning(dcRuleManager) << "Got a rule active notification for a rule we don't know";
            return;
        }
        rule->setActive(params.value("params").toMap().value("active").toBool());
    } else {
        qCWarning(dcRuleManager) << "Unhandled rule notification" << params;
    }
}

void RuleManager::getRulesResponse(int /*commandId*/, const QVariantMap &params)
{
    //    qDebug() << "Get Rules reply" << params;
    foreach (const QVariant &ruleDescriptionVariant, params.value("ruleDescriptions").toList()) {
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
        m_jsonClient->sendCommand("Rules.GetRuleDetails", requestParams, this, "getRuleDetailsResponse");
    }
    m_fetchingData = false;
    emit fetchingDataChanged();
}

void RuleManager::getRuleDetailsResponse(int commandId, const QVariantMap &params)
{
    Q_UNUSED(commandId)
    QVariantMap ruleMap = params.value("rule").toMap();
    Rule* rule = m_rules->getRule(ruleMap.value("id").toUuid());
    if (!rule) {
        qCWarning(dcRuleManager) << "Got rule details for a rule we don't know";
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

void RuleManager::addRuleResponse(int commandId, const QVariantMap &params)
{
    if (params.value("ruleError").toString() != "RuleErrorNoError") {
        qCWarning(dcRuleManager) << "Failed to add rule:" << qUtf8Printable(QJsonDocument::fromVariant(params).toJson());
    } else {
        qCDebug(dcRuleManager) << "Rule added successfully. Rule ID:" << params.value("ruleId").toString();
    }
    QMetaEnum metaEnum = QMetaEnum::fromType<RuleError>();
    RuleError ruleError = static_cast<RuleError>(metaEnum.keyToValue(params.value("ruleError").toByteArray()));
    emit addRuleReply(commandId, ruleError, params.value("ruleId").toUuid());
}

void RuleManager::removeRuleResponse(int commandId, const QVariantMap &params)
{
    qCDebug(dcRuleManager) << "Have remove rule reply" << commandId << params;
    QMetaEnum metaEnum = QMetaEnum::fromType<RuleError>();
    RuleError ruleError = static_cast<RuleError>(metaEnum.keyToValue(params.value("ruleError").toByteArray()));
    qCritical() << "DAFUQQQ" << commandId << ruleError;
    emit removeRuleReply(commandId, ruleError);
}

void RuleManager::editRuleResponse(int commandId, const QVariantMap &params)
{
    if (params.value("ruleError").toString() != "RuleErrorNoError") {
        qCDebug(dcRuleManager) << "Bad rule:" << params.value("ruleError").toString();
    }
    QMetaEnum metaEnum = QMetaEnum::fromType<RuleError>();
    RuleError ruleError = static_cast<RuleError>(metaEnum.keyToValue(params.value("ruleError").toByteArray()));
    emit editRuleReply(commandId, ruleError);
}

void RuleManager::executeRuleActionsResponse(int commandId, const QVariantMap &params)
{
    qCDebug(dcRuleManager) << "Execute rule actions reply:" << commandId << params;
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
        eventDescriptor->setThingId(eventDescriptorVariant.toMap().value("thingId").toString());
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
        //        qDebug() << "Adding eventdescriptor" << eventDescriptor->thingId() << eventDescriptor->eventTypeId();
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
    if (sdMap.contains("thingId") && sdMap.contains("stateTypeId")) {
        sd = new StateDescriptor(sdMap.value("thingId").toUuid(), sdMap.value("stateTypeId").toUuid(), op, sdMap.value("value"), stateEvaluator);
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
    if (ruleAction.contains("thingId") && ruleAction.contains("actionTypeId")) {
        ret->setThingId(ruleAction.value("thingId").toUuid());
        ret->setActionTypeId(ruleAction.value("actionTypeId").toUuid());
    } else if (ruleAction.contains("thingId") && ruleAction.contains("browserItemId")) {
        ret->setThingId(ruleAction.value("thingId").toUuid());
        ret->setBrowserItemId(ruleAction.value("browserItemId").toString());
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
        param->setStateThingId(ruleActionParamVariant.toMap().value("stateThingId").toString());
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

QVariantMap RuleManager::packRule(Rule *rule)
{
    QVariantMap ret;
    if (!rule->id().isNull()) {
        ret.insert("ruleId", rule->id());
    }
    ret.insert("name", rule->name());
    ret.insert("enabled", rule->enabled());
    ret.insert("executable", rule->executable());

    if (rule->actions()->rowCount() > 0) {
        ret.insert("actions", packRuleActions(rule->actions()));
    }
    if (rule->exitActions()->rowCount() > 0) {
        ret.insert("exitActions", packRuleActions(rule->exitActions()));
    }

    if (rule->eventDescriptors()->rowCount() > 0) {
        ret.insert("eventDescriptors", packEventDescriptors(rule->eventDescriptors()));
    }

    if (rule->timeDescriptor()->timeEventItems()->rowCount() > 0 || rule->timeDescriptor()->calendarItems()->rowCount() > 0) {
        ret.insert("timeDescriptor", packTimeDescriptor(rule->timeDescriptor()));
    }

    if (rule->stateEvaluator()) {
        ret.insert("stateEvaluator", packStateEvaluator(rule->stateEvaluator()));
    }

    return ret;
}

QVariantList RuleManager::packEventDescriptors(EventDescriptors *eventDescriptors)
{
    QVariantList ret;
    for (int i = 0; i < eventDescriptors->rowCount(); i++) {
        QVariantMap eventDescriptorMap;
        EventDescriptor* eventDescriptor = eventDescriptors->get(i);
        if (!eventDescriptor->thingId().isNull() && !eventDescriptor->eventTypeId().isNull()) {
            eventDescriptorMap.insert("eventTypeId", eventDescriptor->eventTypeId());
            eventDescriptorMap.insert("thingId", eventDescriptor->thingId());
        } else {
            eventDescriptorMap.insert("interface", eventDescriptor->interfaceName());
            eventDescriptorMap.insert("interfaceEvent", eventDescriptor->interfaceEvent());
        }
        if (eventDescriptor->paramDescriptors()->rowCount() > 0) {
            QVariantList paramDescriptors;
            for (int j = 0; j < eventDescriptor->paramDescriptors()->rowCount(); j++) {
                QVariantMap paramDescriptor;
                if (!eventDescriptor->paramDescriptors()->get(j)->paramTypeId().isNull()) {
                    paramDescriptor.insert("paramTypeId", eventDescriptor->paramDescriptors()->get(j)->paramTypeId());
                } else {
                    paramDescriptor.insert("paramName", eventDescriptor->paramDescriptors()->get(j)->paramName());
                }
                paramDescriptor.insert("value", eventDescriptor->paramDescriptors()->get(j)->value());
                QMetaEnum operatorEnum = QMetaEnum::fromType<ParamDescriptor::ValueOperator>();
                paramDescriptor.insert("operator", operatorEnum.valueToKey(eventDescriptor->paramDescriptors()->get(j)->operatorType()));
                paramDescriptors.append(paramDescriptor);
            }
            eventDescriptorMap.insert("paramDescriptors", paramDescriptors);
        }
        ret.append(eventDescriptorMap);
    }
    return ret;
}

QVariantMap RuleManager::packTimeDescriptor(TimeDescriptor *timeDescriptor)
{
    QVariantMap ret;
    QVariantList timeEventItems;
    for (int i = 0; i < timeDescriptor->timeEventItems()->rowCount(); i++) {
        timeEventItems.append(packTimeEventItem(timeDescriptor->timeEventItems()->get(i)));
    }
    if (!timeEventItems.isEmpty()) {
        ret.insert("timeEventItems", timeEventItems);
    }
    QVariantList calendarItems;
    for (int i = 0; i < timeDescriptor->calendarItems()->rowCount(); i++) {
        calendarItems.append(packCalendarItem(timeDescriptor->calendarItems()->get(i)));
    }
    if (!calendarItems.isEmpty()) {
        ret.insert("calendarItems", calendarItems);
    }
    return ret;
}

QVariantMap RuleManager::packTimeEventItem(TimeEventItem *timeEventItem)
{
    QVariantMap ret;
    if (!timeEventItem->time().isNull()) {
        ret.insert("time", timeEventItem->time().toString("hh:mm"));
    }
    if (!timeEventItem->dateTime().isNull()) {
        ret.insert("datetime", timeEventItem->dateTime().toSecsSinceEpoch());
    }
    ret.insert("repeating", packRepeatingOption(timeEventItem->repeatingOption()));
    return ret;
}

QVariantMap RuleManager::packCalendarItem(CalendarItem *calendarItem)
{
    QVariantMap ret;
    ret.insert("duration", calendarItem->duration());
    if (!calendarItem->dateTime().isNull()) {
        ret.insert("datetime", calendarItem->dateTime().toSecsSinceEpoch());
    }
    if (!calendarItem->startTime().isNull()) {
        ret.insert("startTime", calendarItem->startTime().toString("hh:mm"));
    }
    ret.insert("repeating", packRepeatingOption(calendarItem->repeatingOption()));
    return ret;
}

QVariantMap RuleManager::packRepeatingOption(RepeatingOption *repeatingOption)
{
    QVariantMap ret;
    QMetaEnum repeatingModeEnum = QMetaEnum::fromType<RepeatingOption::RepeatingMode>();
    ret.insert("mode", repeatingModeEnum.valueToKey(repeatingOption->repeatingMode()));
    if (!repeatingOption->weekDays().isEmpty()) {
        ret.insert("weekDays", repeatingOption->weekDays());
    }
    if (!repeatingOption->monthDays().isEmpty()) {
        ret.insert("monthDays", repeatingOption->monthDays());
    }
    return ret;
}

QVariantList RuleManager::packRuleActions(RuleActions *ruleActions)
{
    QVariantList ret;
    for (int i = 0; i < ruleActions->rowCount(); i++) {
        QVariantMap ruleAction;
        RuleAction *ra = ruleActions->get(i);
        if (!ra->actionTypeId().isNull() && !ra->thingId().isNull()) {
            ruleAction.insert("thingId", ra->thingId());
            ruleAction.insert("actionTypeId", ra->actionTypeId());
        } else if (!ra->thingId().isNull() && !ra->browserItemId().isEmpty()) {
            ruleAction.insert("thingId", ra->thingId());
            ruleAction.insert("browserItemId", ra->browserItemId());
        } else {
            ruleAction.insert("interface", ra->interfaceName());
            ruleAction.insert("interfaceAction", ra->interfaceAction());
        }
        if (ra->ruleActionParams()->rowCount() > 0) {
            QVariantList ruleActionParams;
            for (int j = 0; j < ra->ruleActionParams()->rowCount(); j++) {
                QVariantMap ruleActionParam;
                RuleActionParam *rap = ruleActions->get(i)->ruleActionParams()->get(j);
                if (!rap->paramTypeId().isNull()) {
                    ruleActionParam.insert("paramTypeId", rap->paramTypeId());
                } else {
                    ruleActionParam.insert("paramName", rap->paramName());
                }
                if (rap->isValueBased()) {
                    ruleActionParam.insert("value", rap->value());
                } else if (rap->isEventParamBased()) {
                    ruleActionParam.insert("eventTypeId", rap->eventTypeId());
                    ruleActionParam.insert("eventParamTypeId", rap->eventParamTypeId());
                } else {
                    ruleActionParam.insert("stateThingId", rap->stateThingId());
                    ruleActionParam.insert("stateTypeId", rap->stateTypeId());
                }
                ruleActionParams.append(ruleActionParam);
            }
            ruleAction.insert("ruleActionParams", ruleActionParams);
        }
        ret.append(ruleAction);
    }

    return ret;
}

QVariantMap RuleManager::packStateEvaluator(StateEvaluator *stateEvaluator)
{
    QVariantMap ret;
    QMetaEnum stateOperatorEnum = QMetaEnum::fromType<StateEvaluator::StateOperator>();
    ret.insert("operator", stateOperatorEnum.valueToKey(stateEvaluator->stateOperator()));
    QVariantMap stateDescriptor;
    if (!stateEvaluator->stateDescriptor()->thingId().isNull() && !stateEvaluator->stateDescriptor()->stateTypeId().isNull()) {
        stateDescriptor.insert("thingId", stateEvaluator->stateDescriptor()->thingId());
        stateDescriptor.insert("stateTypeId", stateEvaluator->stateDescriptor()->stateTypeId());
    } else {
        stateDescriptor.insert("interface", stateEvaluator->stateDescriptor()->interfaceName());
        stateDescriptor.insert("interfaceState", stateEvaluator->stateDescriptor()->interfaceState());
    }
    QMetaEnum valueOperatorEnum = QMetaEnum::fromType<StateDescriptor::ValueOperator>();
    stateDescriptor.insert("operator", valueOperatorEnum.valueToKeys(stateEvaluator->stateDescriptor()->valueOperator()));
    stateDescriptor.insert("value", stateEvaluator->stateDescriptor()->value());
    ret.insert("stateDescriptor", stateDescriptor);
    QVariantList childEvaluators;
    for (int i = 0; i < stateEvaluator->childEvaluators()->rowCount(); i++) {
        childEvaluators.append(packStateEvaluator(stateEvaluator->childEvaluators()->get(i)));
    }
    ret.insert("childEvaluators", childEvaluators);
    return ret;
}

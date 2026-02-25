// SPDX-License-Identifier: LGPL-3.0-or-later

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
* Copyright (C) 2013 - 2024, nymea GmbH
* Copyright (C) 2024 - 2025, chargebyte austria GmbH
*
* This file is part of libnymea-app.
*
* libnymea-app is free software: you can redistribute it and/or
* modify it under the terms of the GNU Lesser General Public License
* as published by the Free Software Foundation, either version 3
* of the License, or (at your option) any later version.
*
* libnymea-app is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
* GNU Lesser General Public License for more details.
*
* You should have received a copy of the GNU Lesser General Public License
* along with libnymea-app. If not, see <https://www.gnu.org/licenses/>.
*
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#ifndef RULEMANAGER_H
#define RULEMANAGER_H

#include <QObject>

#include "types/rules.h"

class JsonRpcClient;
class EventDescriptors;
class TimeDescriptor;
class TimeEventItem;
class CalendarItem;
class RepeatingOption;
class StateEvaluator;
class RuleAction;
class RuleActions;

class RuleManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(Rules* rules READ rules CONSTANT)
    Q_PROPERTY(bool fetchingData READ fetchingData NOTIFY fetchingDataChanged)

public:

    enum RuleError {
        RuleErrorNoError,
        RuleErrorInvalidRuleId,
        RuleErrorRuleNotFound,
        RuleErrorThingNotFound,
        RuleErrorEventTypeNotFound,
        RuleErrorStateTypeNotFound,
        RuleErrorActionTypeNotFound,
        RuleErrorInvalidParameter,
        RuleErrorInvalidRuleFormat,
        RuleErrorMissingParameter,
        RuleErrorInvalidRuleActionParameter,
        RuleErrorInvalidStateEvaluatorValue,
        RuleErrorTypesNotMatching,
        RuleErrorNotExecutable,
        RuleErrorInvalidTimeDescriptor,
        RuleErrorInvalidRepeatingOption,
        RuleErrorInvalidCalendarItem,
        RuleErrorInvalidTimeEventItem,
        RuleErrorContainsEventBasesAction,
        RuleErrorNoExitActions,
        RuleErrorInterfaceNotFound
    };
    Q_ENUM(RuleError)


    explicit RuleManager(JsonRpcClient *jsonClient, QObject *parent = nullptr);

    void clear();
    void init();
    bool fetchingData() const;

    Rules* rules() const;

    Q_INVOKABLE Rule* createNewRule();

    Q_INVOKABLE int addRule(const QVariantMap params);
    Q_INVOKABLE int addRule(Rule *rule);
    Q_INVOKABLE int removeRule(const QUuid &ruleId);
    Q_INVOKABLE int editRule(Rule *rule);
    Q_INVOKABLE int executeActions(const QString &ruleId);

signals:
    void addRuleReply(int commandId, RuleError ruleError, const QUuid &ruleId);
    void editRuleReply(int commandId, RuleError ruleError);
    void removeRuleReply(int commandId, RuleError ruleError);
    void fetchingDataChanged();

private slots:
    void handleRulesNotification(const QVariantMap &params);
    void getRulesResponse(int commandId, const QVariantMap &params);
    void getRuleDetailsResponse(int commandId, const QVariantMap &params);
    void addRuleResponse(int commandId, const QVariantMap &params);
    void removeRuleResponse(int commandId, const QVariantMap &params);
    void editRuleResponse(int commandId, const QVariantMap &params);
    void executeRuleActionsResponse(int commandId, const QVariantMap &params);

private:
    Rule *parseRule(const QVariantMap &ruleMap);
    void parseEventDescriptors(const QVariantList &eventDescriptorList, Rule *rule);
    StateEvaluator* parseStateEvaluator(const QVariantMap &stateEvaluatorMap);
    void parseRuleActions(const QVariantList &ruleActions, Rule *rule);
    void parseRuleExitActions(const QVariantList &ruleActions, Rule *rule);
    RuleAction* parseRuleAction(const QVariantMap &ruleAction);
    void parseTimeDescriptor(const QVariantMap &timeDescriptor, Rule *rule);

    QVariantMap packRule(Rule *rule);
    QVariantList packEventDescriptors(EventDescriptors *eventDescriptors);
    QVariantMap packTimeDescriptor(TimeDescriptor *timeDescriptor);
    QVariantMap packTimeEventItem(TimeEventItem *timeEventItem);
    QVariantMap packCalendarItem(CalendarItem *calendarItem);
    QVariantMap packRepeatingOption(RepeatingOption *repeatingOption);
    QVariantList packRuleActions(RuleActions *ruleActions);
    QVariantMap packStateEvaluator(StateEvaluator *stateEvaluator);

private:
    JsonRpcClient *m_jsonClient;
    Rules* m_rules;
    bool m_fetchingData = false;
};

#endif // RULEMANAGER_H

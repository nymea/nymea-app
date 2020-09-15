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

#ifndef RULEMANAGER_H
#define RULEMANAGER_H

#include <QObject>

#include "types/rules.h"
#include "jsonrpc/jsonhandler.h"

class JsonRpcClient;
class EventDescriptors;
class TimeDescriptor;
class TimeEventItem;
class CalendarItem;
class RepeatingOption;
class StateEvaluator;
class RuleAction;
class RuleActions;

class RuleManager : public JsonHandler
{
    Q_OBJECT
    Q_PROPERTY(Rules* rules READ rules CONSTANT)

public:
    explicit RuleManager(JsonRpcClient *jsonClient, QObject *parent = nullptr);

    QString nameSpace() const override;

    void clear();
    void init();

    Rules* rules() const;

    Q_INVOKABLE Rule* createNewRule();

    Q_INVOKABLE int addRule(const QVariantMap params);
    Q_INVOKABLE int addRule(Rule *rule);
    Q_INVOKABLE int removeRule(const QUuid &ruleId);
    Q_INVOKABLE int editRule(Rule *rule);
    Q_INVOKABLE int executeActions(const QString &ruleId);

private slots:
    void handleRulesNotification(const QVariantMap &params);
    void getRulesReply(int commandId, const QVariantMap &params);
    void getRuleDetailsReply(int commandId, const QVariantMap &params);
    void onAddRuleReply(int commandId, const QVariantMap &params);
    void removeRuleReply(int commandId, const QVariantMap &params);
    void onEditRuleReply(int commandId, const QVariantMap &params);
    void onExecuteRuleActionsReply(int commandId, const QVariantMap &params);

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

signals:
    void addRuleReply(int commandId, const QString &ruleError, const QString &ruleId);
    void editRuleReply(int commandId, const QString &ruleError);

private:
    JsonRpcClient *m_jsonClient;
    Rules* m_rules;
};

#endif // RULEMANAGER_H

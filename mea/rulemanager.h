#ifndef RULEMANAGER_H
#define RULEMANAGER_H

#include <QObject>

#include "types/rules.h"
#include "jsonrpc/jsonhandler.h"

class JsonRpcClient;
class StateEvaluator;

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

    Q_INVOKABLE void addRule(const QVariantMap params);
    Q_INVOKABLE void addRule(Rule *rule);
    Q_INVOKABLE void removeRule(const QUuid &ruleId);
    Q_INVOKABLE void editRule(Rule *rule);

private slots:
    void handleRulesNotification(const QVariantMap &params);
    void getRulesReply(const QVariantMap &params);
    void getRuleDetailsReply(const QVariantMap &params);
    void onAddRuleReply(const QVariantMap &params);
    void removeRuleReply(const QVariantMap &params);
    void onEditRuleReply(const QVariantMap &params);

private:
    Rule *parseRule(const QVariantMap &ruleMap);
    void parseEventDescriptors(const QVariantList &eventDescriptorList, Rule *rule);
    StateEvaluator* parseStateEvaluator(const QVariantMap &stateEvaluatorMap);
    void parseRuleActions(const QVariantList &ruleActions, Rule *rule);
    void parseRuleExitActions(const QVariantList &ruleActions, Rule *rule);
    void parseTimeDescriptor(const QVariantMap &timeDescriptor, Rule *rule);

signals:
    void addRuleReply(const QString &ruleError);
    void editRuleReply(const QString &ruleError);

private:
    JsonRpcClient *m_jsonClient;
    Rules* m_rules;
};

#endif // RULEMANAGER_H

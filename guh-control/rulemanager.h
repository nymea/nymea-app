#ifndef RULEMANAGER_H
#define RULEMANAGER_H

#include <QObject>

#include "types/rules.h"
#include "jsonrpc/jsonhandler.h"

class JsonRpcClient;

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

    Q_INVOKABLE void addRule(const QVariantMap params);
    Q_INVOKABLE void removeRule(const QUuid &ruleId);

private slots:
    void handleRulesNotification(const QVariantMap &params);
    void getRulesReply(const QVariantMap &params);
    void getRuleDetailsReply(const QVariantMap &params);
    void addRuleReply(const QVariantMap &params);
    void removeRuleReply(const QVariantMap &params);

private:
    void parseEventDescriptors(const QVariantList &eventDescriptorList, Rule *rule);
    void parseRuleActions(const QVariantList &ruleActions, Rule *rule);

private:
    JsonRpcClient *m_jsonClient;
    Rules* m_rules;
};

#endif // RULEMANAGER_H

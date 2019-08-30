#ifndef RULETEMPLATE_H
#define RULETEMPLATE_H

#include <QObject>

class EventDescriptorTemplates;
class RuleActionTemplates;
class StateEvaluatorTemplate;

class RuleTemplate : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString description READ description CONSTANT)
    Q_PROPERTY(QString ruleNameTemplate READ ruleNameTemplate CONSTANT)
    Q_PROPERTY(QStringList interfaces READ interfaces CONSTANT)
    Q_PROPERTY(EventDescriptorTemplates* eventDescriptorTemplates READ eventDescriptorTemplates CONSTANT)
    Q_PROPERTY(StateEvaluatorTemplate* stateEvaluatorTemplate READ stateEvaluatorTemplate CONSTANT)
    Q_PROPERTY(RuleActionTemplates* ruleActionTemplates READ ruleActionTemplates CONSTANT)
    Q_PROPERTY(RuleActionTemplates* ruleExitActionTemplates READ ruleExitActionTemplates CONSTANT)

public:
    explicit RuleTemplate(const QString &interfaceName, const QString &description, const QString &ruleNameTemplate, QObject *parent = nullptr);

    QString description() const;
    QString ruleNameTemplate() const;
    QStringList interfaces() const;

    EventDescriptorTemplates* eventDescriptorTemplates() const;
    StateEvaluatorTemplate* stateEvaluatorTemplate() const;
    void setStateEvaluatorTemplate(StateEvaluatorTemplate *stateEvaluatorTemplate);
    RuleActionTemplates* ruleActionTemplates() const;
    RuleActionTemplates* ruleExitActionTemplates() const;

private:
    QString m_interfaceName;
    QString m_description;
    QString m_ruleNameTemplate;
    EventDescriptorTemplates* m_eventDescriptorTemplates = nullptr;
    StateEvaluatorTemplate* m_stateEvaluatorTemplate = nullptr;
    RuleActionTemplates *m_ruleActionTemplates = nullptr;
    RuleActionTemplates *m_ruleExitActionTemplates = nullptr;
};

#endif // RULETEMPLATE_H

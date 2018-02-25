#ifndef RULE_H
#define RULE_H

#include <QObject>
#include <QUuid>

class EventDescriptors;
class RuleActions;
class StateEvaluator;

class Rule : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QUuid id READ id CONSTANT)
    Q_PROPERTY(QString name READ name WRITE setName NOTIFY nameChanged)
    Q_PROPERTY(bool enabled READ enabled WRITE setEnabled NOTIFY enabledChanged)
    Q_PROPERTY(bool active READ active NOTIFY activeChanged)
    Q_PROPERTY(EventDescriptors* eventDescriptors READ eventDescriptors CONSTANT)
    Q_PROPERTY(StateEvaluator* stateEvaluator READ stateEvaluator CONSTANT)
    Q_PROPERTY(RuleActions* ruleActions READ ruleActions CONSTANT)
public:
    explicit Rule(const QUuid &id = QUuid(), QObject *parent = nullptr);

    QUuid id() const;

    QString name() const;
    void setName(const QString &name);

    bool enabled() const;
    void setEnabled(bool enabled);

    bool active() const;
    void setActive(bool active);

    EventDescriptors* eventDescriptors() const;
    StateEvaluator *stateEvaluator() const;
    RuleActions* ruleActions() const;

    Rule *clone() const;

signals:
    void nameChanged();
    void enabledChanged();
    void activeChanged();

private:
    QUuid m_id;
    QString m_name;
    bool m_enabled = true;
    bool m_active = false;
    EventDescriptors *m_eventDescriptors = nullptr;
    StateEvaluator *m_stateEvaluator = nullptr;
    RuleActions *m_ruleActions = nullptr;
};

#endif // RULE_H

#ifndef RULE_H
#define RULE_H

#include <QObject>
#include <QUuid>

class EventDescriptors;
class RuleActions;
class StateEvaluator;
class TimeDescriptor;

class Rule : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QUuid id READ id CONSTANT)
    Q_PROPERTY(QString name READ name WRITE setName NOTIFY nameChanged)
    Q_PROPERTY(bool enabled READ enabled WRITE setEnabled NOTIFY enabledChanged)
    Q_PROPERTY(bool active READ active NOTIFY activeChanged)
    Q_PROPERTY(bool executable READ executable WRITE setExecutable NOTIFY executableChanged)
    Q_PROPERTY(EventDescriptors* eventDescriptors READ eventDescriptors CONSTANT)
    Q_PROPERTY(StateEvaluator* stateEvaluator READ stateEvaluator WRITE setStateEvaluator NOTIFY stateEvaluatorChanged)
    Q_PROPERTY(RuleActions* actions READ actions CONSTANT)
    Q_PROPERTY(RuleActions* exitActions READ exitActions CONSTANT)
    Q_PROPERTY(TimeDescriptor* timeDescriptor READ timeDescriptor CONSTANT)
public:
    explicit Rule(const QUuid &id = QUuid(), QObject *parent = nullptr);
    ~Rule();

    QUuid id() const;

    QString name() const;
    void setName(const QString &name);

    bool enabled() const;
    void setEnabled(bool enabled);

    bool active() const;
    void setActive(bool active);

    bool executable() const;
    void setExecutable(bool executable);

    EventDescriptors* eventDescriptors() const;
    StateEvaluator *stateEvaluator() const;
    RuleActions* actions() const;
    RuleActions* exitActions() const;
    TimeDescriptor* timeDescriptor() const;

    Q_INVOKABLE StateEvaluator* createStateEvaluator() const;

    Q_INVOKABLE void setStateEvaluator(StateEvaluator* stateEvaluator);

    Q_INVOKABLE Rule *clone() const;

    Q_INVOKABLE bool compare(Rule* other) const;
    bool operator==(Rule *other) const;

signals:
    void nameChanged();
    void enabledChanged();
    void activeChanged();
    void executableChanged();
    void stateEvaluatorChanged();

private:
    QUuid m_id;
    QString m_name;
    bool m_enabled = true;
    bool m_active = false;
    bool m_executable = false;
    EventDescriptors *m_eventDescriptors = nullptr;
    StateEvaluator *m_stateEvaluator = nullptr;
    RuleActions *m_actions = nullptr;
    RuleActions *m_exitActions = nullptr;
    TimeDescriptor *m_timeDescriptor = nullptr;
};

QDebug operator<<(QDebug &dbg, Rule *rule);
QDebug printStateEvaluator(QDebug &dbg, StateEvaluator *stateEvaluator, int indentLevel = 1);

#endif // RULE_H

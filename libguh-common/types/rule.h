#ifndef RULE_H
#define RULE_H

#include <QObject>
#include <QUuid>

class EventDescriptors;
class RuleActions;

class Rule : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QUuid id READ id CONSTANT)
    Q_PROPERTY(QString name READ name NOTIFY nameChanged)
    Q_PROPERTY(bool enabled READ enabled NOTIFY enabledChanged)
    Q_PROPERTY(EventDescriptors* eventDescriptors READ eventDescriptors CONSTANT)
    Q_PROPERTY(RuleActions* ruleActions READ ruleActions CONSTANT)
public:
    explicit Rule(const QUuid &id, QObject *parent = nullptr);

    QUuid id() const;

    QString name() const;
    void setName(const QString &name);

    bool enabled() const;
    void setEnabled(bool enabled);

    EventDescriptors* eventDescriptors() const;
    RuleActions* ruleActions() const;

signals:
    void nameChanged();
    void enabledChanged();

private:
    QUuid m_id;
    QString m_name;
    bool m_enabled = false;
    EventDescriptors *m_eventDescriptors = nullptr;
    RuleActions *m_ruleActions = nullptr;
};

#endif // RULE_H

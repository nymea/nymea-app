#ifndef RULEACTION_H
#define RULEACTION_H

#include <QObject>
#include <QUuid>

class RuleActionParams;

class RuleAction : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QUuid deviceId READ deviceId WRITE setDeviceId NOTIFY deviceIdChanged)
    Q_PROPERTY(QUuid actionTypeId READ actionTypeId WRITE setActionTypeId NOTIFY actionTypeIdChanged)
    Q_PROPERTY(RuleActionParams* ruleActionParams READ ruleActionParams CONSTANT)

public:
    explicit RuleAction(QObject *parent = nullptr);

    QUuid deviceId() const;
    void setDeviceId(const QUuid &deviceId);

    QUuid actionTypeId() const;
    void setActionTypeId(const QUuid &actionTypeId);

    RuleActionParams* ruleActionParams() const;

signals:
    void deviceIdChanged();
    void actionTypeIdChanged();

private:
    QUuid m_deviceId;
    QUuid m_actionTypeId;
    RuleActionParams *m_ruleActionParams;
};

#endif // RULEACTION_H

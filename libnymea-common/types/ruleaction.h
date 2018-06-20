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
    Q_PROPERTY(QString interfaceName READ interfaceName WRITE setInterfaceName NOTIFY interfaceNameChanged)
    Q_PROPERTY(QString interfaceAction READ interfaceAction WRITE setInterfaceAction NOTIFY interfaceActionChanged)
    Q_PROPERTY(RuleActionParams* ruleActionParams READ ruleActionParams CONSTANT)

public:
    explicit RuleAction(QObject *parent = nullptr);

    QUuid deviceId() const;
    void setDeviceId(const QUuid &deviceId);

    QUuid actionTypeId() const;
    void setActionTypeId(const QUuid &actionTypeId);

    QString interfaceName() const;
    void setInterfaceName(const QString &interfaceName);

    QString interfaceAction() const;
    void setInterfaceAction(const QString &interfaceAction);

    RuleActionParams* ruleActionParams() const;

    RuleAction *clone() const;

signals:
    void deviceIdChanged();
    void actionTypeIdChanged();
    void interfaceNameChanged();
    void interfaceActionChanged();

private:
    QUuid m_deviceId;
    QUuid m_actionTypeId;
    QString m_interfaceName;
    QString m_interfaceAction;
    RuleActionParams *m_ruleActionParams;
};

#endif // RULEACTION_H

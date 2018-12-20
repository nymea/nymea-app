#include "ruleaction.h"

#include "ruleactionparam.h"
#include "ruleactionparams.h"

#include <QDebug>

RuleAction::RuleAction(QObject *parent) : QObject(parent)
{
    m_ruleActionParams = new RuleActionParams(this);
}

QUuid RuleAction::deviceId() const
{
    return m_deviceId;
}

void RuleAction::setDeviceId(const QUuid &deviceId)
{
    if (m_deviceId != deviceId) {
        m_deviceId = deviceId;
        emit deviceIdChanged();
    }
}

QUuid RuleAction::actionTypeId() const
{
    return m_actionTypeId;
}

void RuleAction::setActionTypeId(const QUuid &actionTypeId)
{
    if (m_actionTypeId != actionTypeId) {
        m_actionTypeId = actionTypeId;
        emit actionTypeIdChanged();
    }
}

QString RuleAction::interfaceName() const
{
    return m_interfaceName;
}

void RuleAction::setInterfaceName(const QString &interfaceName)
{
    if (m_interfaceName != interfaceName) {
        m_interfaceName = interfaceName;
        emit interfaceNameChanged();
    }
}

QString RuleAction::interfaceAction() const
{
    return m_interfaceAction;
}

void RuleAction::setInterfaceAction(const QString &interfaceAction)
{
    if (m_interfaceAction != interfaceAction) {
        m_interfaceAction = interfaceAction;
        emit interfaceActionChanged();
    }
}

RuleActionParams *RuleAction::ruleActionParams() const
{
    return m_ruleActionParams;
}

RuleAction *RuleAction::clone() const
{
    RuleAction *ret = new RuleAction();
    ret->setDeviceId(deviceId());
    ret->setActionTypeId(actionTypeId());
    ret->setInterfaceName(interfaceName());
    ret->setInterfaceAction(interfaceAction());
    for (int i = 0; i < ruleActionParams()->rowCount(); i++) {
        ret->ruleActionParams()->addRuleActionParam(ruleActionParams()->get(i)->clone());
    }
    return ret;
}

#define COMPARE(a, b) if (a != b) { qDebug() << a << "!=" << b; return false; }
#define COMPARE_PTR(a, b) if (!a->operator==(b)) { qDebug() << a << "!=" << b; return false; }
bool RuleAction::operator==(RuleAction *other) const
{
    COMPARE(m_deviceId, other->deviceId());
    COMPARE(m_actionTypeId, other->actionTypeId());
    COMPARE(m_interfaceName, other->interfaceName());
    COMPARE(m_interfaceAction, other->interfaceAction());
    COMPARE_PTR(m_ruleActionParams, other->ruleActionParams());
    return true;
}

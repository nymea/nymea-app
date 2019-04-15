#include "ruleactionparams.h"

#include "ruleactionparam.h"

RuleActionParams::RuleActionParams(QObject *parent) : QAbstractListModel(parent)
{

}

int RuleActionParams::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return m_list.count();
}

QVariant RuleActionParams::data(const QModelIndex &index, int role) const
{
    switch (role) {
    case RoleParamTypeId:
        return m_list.at(index.row())->paramTypeId();
    case RoleValue:
        return m_list.at(index.row())->value();
    case RoleEventTypeId:
        return m_list.at(index.row())->eventTypeId();
    case RoleEventParamTypeId:
        return m_list.at(index.row())->eventParamTypeId();
    }
    return QVariant();
}

QHash<int, QByteArray> RuleActionParams::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles.insert(RoleParamTypeId, "paramTypeId");
    roles.insert(RoleValue, "value");
    roles.insert(RoleEventTypeId, "eventTypeId");
    roles.insert(RoleEventParamTypeId, "eventParamTypeId");
    return roles;
}

void RuleActionParams::addRuleActionParam(RuleActionParam *ruleActionParam)
{
    ruleActionParam->setParent(this);
    beginInsertRows(QModelIndex(), m_list.count(), m_list.count());
    m_list.append(ruleActionParam);
    endInsertRows();
}

void RuleActionParams::setRuleActionParam(const QString &paramTypeId, const QVariant &value)
{
    foreach (RuleActionParam *rap, m_list) {
        if (rap->paramTypeId() == paramTypeId) {
            rap->setValue(value);
            return;
        }
    }

    // Still here? Need to add it
    RuleActionParam *rap = new RuleActionParam(this);
    rap->setParamTypeId(paramTypeId);
    rap->setValue(value);
    addRuleActionParam(rap);
}

void RuleActionParams::setRuleActionParamByName(const QString &paramName, const QVariant &value)
{
    foreach (RuleActionParam *rap, m_list) {
        if (rap->paramName() == paramName) {
            rap->setValue(value);
            return;
        }
    }

    // Still here? Need to add it
    RuleActionParam *rap = new RuleActionParam(this);
    rap->setParamName(paramName);
    rap->setValue(value);
    addRuleActionParam(rap);
}

void RuleActionParams::setRuleActionParamEvent(const QString &paramTypeId, const QString &eventTypeId, const QString &eventParamTypeId)
{
    foreach (RuleActionParam *rap, m_list) {
        if (rap->paramTypeId() == paramTypeId) {
            rap->setEventTypeId(eventTypeId);
            rap->setEventParamTypeId(eventParamTypeId);
            return;
        }
    }
    RuleActionParam *rap = new RuleActionParam(this);
    rap->setParamTypeId(paramTypeId);
    rap->setEventTypeId(eventTypeId);
    rap->setEventParamTypeId(eventParamTypeId);
    addRuleActionParam(rap);
}

void RuleActionParams::setRuleActionParamState(const QString &paramTypeId, const QString &stateDeviceId, const QString &stateTypeId)
{
    foreach (RuleActionParam *rap, m_list) {
        if (rap->paramTypeId() == paramTypeId) {
            rap->setStateDeviceId(stateDeviceId);
            rap->setStateTypeId(stateTypeId);
            return;
        }
    }
    RuleActionParam *rap = new RuleActionParam(this);
    rap->setParamTypeId(paramTypeId);
    rap->setStateDeviceId(stateDeviceId);
    rap->setStateTypeId(stateTypeId);
    addRuleActionParam(rap);
}

RuleActionParam *RuleActionParams::get(int index) const
{
    return m_list.at(index);
}

bool RuleActionParams::operator==(RuleActionParams *other) const
{
    if (rowCount() != other->rowCount()) {
        return false;
    }
    for (int i = 0; i < rowCount(); i++) {
        if (!get(i)->operator==(other->get(i))) {
            return false;
        }
    }
    return true;
}

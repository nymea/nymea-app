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
    }
    return QVariant();
}

QHash<int, QByteArray> RuleActionParams::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles.insert(RoleParamTypeId, "paramTypeId");
    roles.insert(RoleValue, "value");
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

RuleActionParam *RuleActionParams::get(int index) const
{
    return m_list.at(index);
}

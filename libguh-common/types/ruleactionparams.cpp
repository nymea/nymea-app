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
    return QVariant();
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

#include "ruleactionparams.h"

#include "ruleactionparam.h"

RuleActionParams::RuleActionParams(QObject *parent) : QAbstractListModel(parent)
{

}

int RuleActionParams::rowCount(const QModelIndex &parent) const
{
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

RuleActionParam *RuleActionParams::get(int index) const
{
    return m_list.at(index);
}

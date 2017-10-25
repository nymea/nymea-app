#include "ruleactions.h"
#include "ruleaction.h"

RuleActions::RuleActions(QObject *parent) : QAbstractListModel(parent)
{

}

int RuleActions::rowCount(const QModelIndex &parent) const
{
    return m_list.count();
}

QVariant RuleActions::data(const QModelIndex &index, int role) const
{
    return QVariant();
}

void RuleActions::addRuleAction(RuleAction *ruleAction)
{
    ruleAction->setParent(this);
    beginInsertRows(QModelIndex(), m_list.count(), m_list.count());
    m_list.append(ruleAction);
    endInsertRows();
}

RuleAction *RuleActions::get(int index) const
{
    return m_list.at(index);
}

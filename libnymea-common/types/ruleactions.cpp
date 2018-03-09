#include "ruleactions.h"
#include "ruleaction.h"

RuleActions::RuleActions(QObject *parent) : QAbstractListModel(parent)
{

}

int RuleActions::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
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
    emit countChanged();
}

void RuleActions::removeRuleAction(int index)
{
    beginRemoveRows(QModelIndex(), index, index);
    m_list.takeAt(index)->deleteLater();
    endRemoveRows();
    emit countChanged();
}

RuleAction *RuleActions::get(int index) const
{
    if (index >= 0 && index < m_list.count()) {
        return m_list.at(index);
    }
    return nullptr;
}

RuleAction *RuleActions::createNewRuleAction() const
{
    return new RuleAction();
}

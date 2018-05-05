#include "stateevaluators.h"

StateEvaluators::StateEvaluators(QObject *parent) : QAbstractListModel(parent)
{

}

int StateEvaluators::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return m_list.count();
}

QVariant StateEvaluators::data(const QModelIndex &index, int role) const
{
    Q_UNUSED(index)
    Q_UNUSED(role)
    return QVariant();
}

QHash<int, QByteArray> StateEvaluators::roleNames() const
{
    QHash<int, QByteArray> roles;
    return roles;
}

void StateEvaluators::addStateEvaluator(StateEvaluator *stateEvaluator)
{
    beginInsertRows(QModelIndex(), m_list.count(), m_list.count());
    m_list.append(stateEvaluator);
    endInsertRows();
    emit countChanged();
}

StateEvaluator *StateEvaluators::get(int index) const
{
    return m_list.at(index);
}

StateEvaluator *StateEvaluators::take(int index)
{
    beginRemoveRows(QModelIndex(), index, index);
    return m_list.takeAt(index);
    endInsertRows();
    emit countChanged();
}

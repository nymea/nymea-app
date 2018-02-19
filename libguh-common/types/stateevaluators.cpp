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
    return QVariant();
}

QHash<int, QByteArray> StateEvaluators::roleNames() const
{
    QHash<int, QByteArray> roles;
    return roles;
}

StateEvaluator *StateEvaluators::get(int index) const
{
    return m_list.at(index);
}

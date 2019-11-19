#include "scripts.h"

#include "script.h"

Scripts::Scripts(QObject *parent) : QAbstractListModel(parent)
{

}

int Scripts::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return m_list.count();
}

QVariant Scripts::data(const QModelIndex &index, int role) const
{
    switch (role) {
    case RoleId:
        return m_list.at(index.row())->id();
    case RoleName:
        return m_list.at(index.row())->name();
    }
    return QVariant();
}

QHash<int, QByteArray> Scripts::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles.insert(RoleId, "id");
    roles.insert(RoleName, "name");
    return roles;

}

void Scripts::clear()
{
    beginResetModel();
    qDeleteAll(m_list);
    m_list.clear();
    endResetModel();
    emit countChanged();
}

void Scripts::addScript(Script *script)
{
    script->setParent(this);
    beginInsertRows(QModelIndex(), m_list.count(), m_list.count());
    m_list.append(script);
    endInsertRows();
    emit countChanged();
}

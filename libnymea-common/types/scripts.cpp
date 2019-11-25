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

    connect(script, &Script::nameChanged, this, [this, script](){
        int idx = m_list.indexOf(script);
        if (idx < 0) return;
        emit dataChanged(index(idx), index(idx), {RoleName});
    });
}

void Scripts::removeScript(const QUuid &id)
{
    for (int i = 0; i < m_list.count(); i++) {
        if (m_list.at(i)->id() == id) {
            beginRemoveRows(QModelIndex(), i, i);
            m_list.takeAt(i)->deleteLater();
            endRemoveRows();
            return;
        }
    }
}

Script* Scripts::get(int index) const
{
    if (index < 0 || index >= m_list.count()) {
        return nullptr;
    }
    return m_list.at(index);
}

Script *Scripts::getScript(const QUuid &scriptId)
{
    foreach (Script *script, m_list) {
        if (script->id() == scriptId) {
            return script;
        }
    }
    return nullptr;
}

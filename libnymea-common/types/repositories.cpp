#include "repositories.h"
#include "repository.h"

Repositories::Repositories(QObject *parent): QAbstractListModel(parent)
{

}

int Repositories::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return m_list.count();
}

QVariant Repositories::data(const QModelIndex &index, int role) const
{
    switch (role) {
    case RoleId:
        return m_list.at(index.row())->id();
    case RoleDisplayName:
        return m_list.at(index.row())->displayName();
    case RoleEnabled:
        return m_list.at(index.row())->enabled();
    }
    return QVariant();
}

QHash<int, QByteArray> Repositories::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles.insert(RoleId, "id");
    roles.insert(RoleDisplayName, "displayName");
    roles.insert(RoleEnabled, "enabled");
    return roles;
}

Repository *Repositories::get(int index) const
{
    if (index >= 0 && index < m_list.count()) {
        return m_list.at(index);
    }
    return nullptr;
}

Repository *Repositories::getRepository(const QString &id) const
{
    foreach (Repository *repo, m_list) {
        if (repo->id() == id) {
            return repo;
        }
    }
    return nullptr;
}

void Repositories::addRepository(Repository *repository)
{
    repository->setParent(this);
    beginInsertRows(QModelIndex(), m_list.count(), m_list.count());
    m_list.append(repository);
    connect(repository, &Repository::enabledChanged, this, [this, repository](){
        QModelIndex idx = index(m_list.indexOf(repository));
        emit dataChanged(idx, idx, {RoleEnabled});
    });
    endInsertRows();
    emit countChanged();
}

void Repositories::removeRepository(const QString &repositoryId)
{
    int idx = -1;
    for (int i = 0; i < m_list.count(); i++) {
        if (m_list.at(i)->id() == repositoryId) {
            idx = i;
            break;
        }
    }
    if (idx < 0) {
        return;
    }
    beginRemoveRows(QModelIndex(), idx, idx);
    m_list.takeAt(idx)->deleteLater();
    endRemoveRows();
    emit countChanged();

}

void Repositories::clear()
{
    beginResetModel();
    qDeleteAll(m_list);
    m_list.clear();
    endResetModel();
    emit countChanged();
}

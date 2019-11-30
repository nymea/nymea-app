#include "taglistmodel.h"
#include "tagsproxymodel.h"
#include "types/tag.h"

#include <QDebug>

TagListModel::TagListModel(QObject *parent) : QAbstractListModel(parent)
{

}

TagsProxyModel *TagListModel::tagsProxy() const
{
    return m_tagsProxy;
}

void TagListModel::setTagsProxy(TagsProxyModel *tagsProxy)
{
    if (m_tagsProxy != tagsProxy) {
        m_tagsProxy = tagsProxy;
        emit tagsProxyChanged();

        connect(tagsProxy, &TagsProxyModel::countChanged, this, &TagListModel::update);

        update();
    }
}

int TagListModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return m_list.count();
}

QVariant TagListModel::data(const QModelIndex &index, int role) const
{
    switch (role) {
    case RoleTagId:
        return m_list.at(index.row())->tagId();
    case RoleValue:
        return m_list.at(index.row())->value();
    }

    return QVariant();
}

QHash<int, QByteArray> TagListModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles.insert(RoleTagId, "tagId");
    roles.insert(RoleValue, "value");
    return roles;
}

bool TagListModel::containsId(const QString &tagId)
{
    foreach (Tag* t, m_list) {
        if (t->tagId() == tagId) {
            return true;
        }
    }
    return false;
}

bool TagListModel::containsValue(const QString &tagValue)
{
    foreach (Tag* t, m_list) {
        if (t->value() == tagValue) {
            return true;
        }
    }
    return false;
}

void TagListModel::update()
{
    beginResetModel();
    qDeleteAll(m_list);
    m_list.clear();

    for (int i = 0; i < m_tagsProxy->rowCount(); i++) {
        Tag *tag = m_tagsProxy->get(i);

        bool found = false;
        foreach (Tag* existingTag, m_list) {
            if (tag->tagId() == existingTag->tagId() && tag->value() == existingTag->value()) {
                found = true;
                break;
            }
        }
        if (!found) {
            Tag *t = new Tag(tag->tagId(), tag->value(), this);
            m_list.append(t);
        }
    }

    qDebug() << "Model populated" << m_list.count() << this;
    endResetModel();
    emit countChanged();
}

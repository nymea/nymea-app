// SPDX-License-Identifier: LGPL-3.0-or-later

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
* Copyright (C) 2013 - 2024, nymea GmbH
* Copyright (C) 2024 - 2025, chargebyte austria GmbH
*
* This file is part of libnymea-app.
*
* libnymea-app is free software: you can redistribute it and/or
* modify it under the terms of the GNU Lesser General Public License
* as published by the Free Software Foundation, either version 3
* of the License, or (at your option) any later version.
*
* libnymea-app is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
* GNU Lesser General Public License for more details.
*
* You should have received a copy of the GNU Lesser General Public License
* along with libnymea-app. If not, see <https://www.gnu.org/licenses/>.
*
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

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
            t->setThingId(tag->thingId());
            t->setRuleId(tag->ruleId());
            beginInsertRows(QModelIndex(), m_list.count(), m_list.count());
            m_list.append(t);
            endInsertRows();
        }
    }

    QMutableListIterator<Tag*> it(m_list);
    while (it.hasNext()) {
        Tag *tag = it.next();
        bool found = false;
        for (int i = 0; i < m_tagsProxy->rowCount(); i++) {
            Tag *tagInSource = m_tagsProxy->get(i);
            if (tag->tagId() == tagInSource->tagId() && tag->value() == tagInSource->value()) {
                found = true;
                break;
            }
        }
        if (!found) {
            int idx = m_list.indexOf(tag);
            beginRemoveRows(QModelIndex(), idx, idx);
            m_list.at(idx)->deleteLater();
            it.remove();
            endRemoveRows();
        }
    }
    emit countChanged();
}

TagListProxyModel::TagListProxyModel(QObject *parent):
    QSortFilterProxyModel(parent)
{

}

TagListModel *TagListProxyModel::tagListModel() const
{
    return m_tagListModel;
}

void TagListProxyModel::setTagListModel(TagListModel *tagListModel)
{
    if (m_tagListModel != tagListModel) {
        m_tagListModel = tagListModel;
        setSourceModel(tagListModel);
        emit tagListModelChanged();

        connect(tagListModel, &TagListModel::countChanged, this, &TagListProxyModel::countChanged);

        setSortCaseSensitivity(Qt::CaseInsensitive);
        setSortRole(TagListModel::RoleTagId);
        sort(0);

        emit countChanged();
    }
}

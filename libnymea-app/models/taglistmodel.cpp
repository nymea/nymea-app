/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
* Copyright 2013 - 2020, nymea GmbH
* Contact: contact@nymea.io
*
* This file is part of nymea.
* This project including source code and documentation is protected by
* copyright law, and remains the property of nymea GmbH. All rights, including
* reproduction, publication, editing and translation, are reserved. The use of
* this project is subject to the terms of a license agreement to be concluded
* with nymea GmbH in accordance with the terms of use of nymea GmbH, available
* under https://nymea.io/license
*
* GNU General Public License Usage
* Alternatively, this project may be redistributed and/or modified under the
* terms of the GNU General Public License as published by the Free Software
* Foundation, GNU version 3. This project is distributed in the hope that it
* will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty
* of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
* Public License for more details.
*
* You should have received a copy of the GNU General Public License along with
* this project. If not, see <https://www.gnu.org/licenses/>.
*
* For any further details and any questions please contact us under
* contact@nymea.io or see our FAQ/Licensing Information on
* https://nymea.io/license/faq
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

    endResetModel();
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

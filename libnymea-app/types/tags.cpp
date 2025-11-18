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

#include "tags.h"
#include "tag.h"

#include <QDebug>

#include <QLoggingCategory>
Q_DECLARE_LOGGING_CATEGORY(dcTags)


Tags::Tags(QObject *parent) : QAbstractListModel(parent)
{

}

int Tags::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return m_list.count();
}

QVariant Tags::data(const QModelIndex &index, int role) const
{
    switch (role) {
    case RoleThingId:
        return m_list.at(index.row())->thingId();
    case RoleRuleId:
        return m_list.at(index.row())->ruleId();
    case RoleTagId:
        return m_list.at(index.row())->tagId();
    case RoleValue:
        return m_list.at(index.row())->value();
    }
    return QVariant();
}

QHash<int, QByteArray> Tags::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles.insert(RoleThingId, "thingId");
    roles.insert(RoleRuleId, "ruleId");
    roles.insert(RoleTagId, "tagId");
    roles.insert(RoleValue, "value");
    return roles;
}

void Tags::addTag(Tag *tag)
{
    tag->setParent(this);
    connect(tag, &Tag::valueChanged, this, &Tags::tagValueChanged);
    beginInsertRows(QModelIndex(), m_list.count(), m_list.count());
    m_list.append(tag);
    endInsertRows();
    qDebug() << "tags count changed";
    emit countChanged();
}

void Tags::addTags(QList<Tag *> tags)
{
    if (tags.isEmpty()) {
        return;
    }
    beginInsertRows(QModelIndex(), m_list.count(), m_list.count() + tags.count() - 1);
    foreach (Tag *tag, tags) {
        tag->setParent(this);
        connect(tag, &Tag::valueChanged, this, &Tags::tagValueChanged);
    }
    m_list.append(tags);
    endInsertRows();
    emit countChanged();
}

void Tags::removeTag(Tag *tag)
{
    int idx = m_list.indexOf(tag);
    if (idx < 0) {
        qWarning() << "Don't know this tag. Can't remove";
        return;
    }
    beginRemoveRows(QModelIndex(), idx, idx);
    m_list.removeAt(idx);
    endRemoveRows();
    tag->deleteLater();
    emit countChanged();
}

Tag *Tags::get(int index) const
{
    if (index < 0 || index >= m_list.count()) {
        return nullptr;
    }
    return m_list.at(index);
}

Tag *Tags::findThingTag(const QUuid &thingId, const QString &tagId) const
{
    foreach (Tag *tag, m_list) {
        if (tag->thingId() == thingId && tag->tagId() == tagId) {
            return tag;
        }
    }
    return nullptr;
}

Tag *Tags::findRuleTag(const QString &ruleId, const QString &tagId) const
{
    foreach (Tag *tag, m_list) {
        if (tag->ruleId() == ruleId && tag->tagId() == tagId) {
            return tag;
        }
    }
    return nullptr;
}

void Tags::clear()
{
    beginResetModel();
    qDeleteAll(m_list);
    m_list.clear();
    endResetModel();
    emit countChanged();
}

void Tags::tagValueChanged()
{
    qCInfo(dcTags) << "Tag value in model changed";
    Tag *tag = static_cast<Tag*>(sender());
    int idx = m_list.indexOf(tag);
    emit dataChanged(index(idx, 0), index(idx, 0), {RoleValue});
}

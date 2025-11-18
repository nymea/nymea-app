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

#ifndef TAGLISTMODEL_H
#define TAGLISTMODEL_H

#include <QAbstractListModel>
#include <QSortFilterProxyModel>

class TagsProxyModel;
class Tag;

class TagListModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)
    Q_PROPERTY(TagsProxyModel* tagsProxy READ tagsProxy WRITE setTagsProxy NOTIFY tagsProxyChanged)
public:
    enum Roles {
        RoleTagId,
        RoleValue
    };
    explicit TagListModel(QObject *parent = nullptr);

    TagsProxyModel* tagsProxy() const;
    void setTagsProxy(TagsProxyModel* tagsProxy);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

    Q_INVOKABLE bool containsId(const QString &tagId);
    Q_INVOKABLE bool containsValue(const QString &tagValue);

signals:
    void countChanged();
    void tagsProxyChanged();

private slots:
    void update();

private:
    TagsProxyModel *m_tagsProxy = nullptr;

    QList<Tag*> m_list;
};

class TagListProxyModel: public QSortFilterProxyModel
{
    Q_OBJECT

    Q_PROPERTY(TagListModel *tagListModel READ tagListModel WRITE setTagListModel NOTIFY tagListModelChanged)

    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)

public:
    TagListProxyModel(QObject *parent = nullptr);

    TagListModel *tagListModel() const;
    void setTagListModel(TagListModel *tagListModel);

signals:
    void tagListModelChanged();

    void countChanged();

private:
    TagListModel *m_tagListModel = nullptr;
};

#endif // TAGLISTMODEL_H

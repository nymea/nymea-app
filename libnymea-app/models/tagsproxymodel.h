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

#ifndef TAGSPROXYMODEL_H
#define TAGSPROXYMODEL_H

#include <QSortFilterProxyModel>
#include <QUuid>

class Tag;
class Tags;

class TagsProxyModel : public QSortFilterProxyModel
{
    Q_OBJECT
    Q_PROPERTY(Tags* tags READ tags WRITE setTags NOTIFY tagsChanged)
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)
    Q_PROPERTY(QString filterTagId READ filterTagId WRITE setFilterTagId NOTIFY filterTagIdChanged)
    Q_PROPERTY(QUuid filterThingId READ filterThingId WRITE setFilterThingId NOTIFY filterThingIdChanged)
    Q_PROPERTY(QUuid filterRuleId READ filterRuleId WRITE setFilterRuleId NOTIFY filterRuleIdChanged)
    Q_PROPERTY(QString filterValue READ filterValue WRITE setFilterValue NOTIFY filterValueChanged)

public:
    explicit TagsProxyModel(QObject *parent = nullptr);

    Tags* tags() const;
    void setTags(Tags* tags);

    QString filterTagId() const;
    void setFilterTagId(const QString &filterTagId);

    QUuid filterThingId() const;
    void setFilterThingId(const QUuid &filterThingId);

    QUuid filterRuleId() const;
    void setFilterRuleId(const QUuid &filterRuleId);

    QString filterValue() const;
    void setFilterValue(const QString &filterValue);

    Q_INVOKABLE Tag* get(int index) const;
    Q_INVOKABLE Tag* findTag(const QString &tagId) const;

protected:
    bool filterAcceptsRow(int source_row, const QModelIndex &source_parent) const override;
    bool lessThan(const QModelIndex &source_left, const QModelIndex &source_right) const override;

signals:
    void tagsChanged();
    void filterTagIdChanged();
    void filterThingIdChanged();
    void filterRuleIdChanged();
    void filterValueChanged();
    void groupSameTagsChanged();
    void countChanged();

private:
    Tags *m_tags = nullptr;
    QString m_filterTagId;
    QUuid m_filterThingId;
    QUuid m_filterRuleId;
    QString m_filterValue;
};

#endif // TAGSPROXYMODEL_H

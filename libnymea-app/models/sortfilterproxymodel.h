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

#ifndef SORTFILTERPROXYMODEL_H
#define SORTFILTERPROXYMODEL_H

#include <QSortFilterProxyModel>

class SortFilterProxyModel : public QSortFilterProxyModel
{
    Q_OBJECT
    Q_PROPERTY(QString filterRoleName READ filterRoleName WRITE setFilterRoleName NOTIFY filterRoleNameChanged)
    Q_PROPERTY(QStringList filterList READ filterList WRITE setFilterList NOTIFY filterListChanged)
    Q_PROPERTY(QString sortRoleName READ sortRoleName WRITE setSortRoleName NOTIFY sortRoleNameChanged)
    Q_PROPERTY(Qt::SortOrder sortOrder READ sortOrder WRITE setSortOrder NOTIFY sortOrderChanged)
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)

public:
    explicit SortFilterProxyModel(QObject *parent = nullptr);

    QString filterRoleName() const;
    void setFilterRoleName(const QString &filterRoleName);

    QStringList filterList() const;
    void setFilterList(const QStringList &filterList);

    QString sortRoleName() const;
    void setSortRoleName(const QString &sortRoleName);

    void setSortOrder(Qt::SortOrder sortOrder);

    Q_INVOKABLE QVariant modelData(int row, const QString &role) const;
    Q_INVOKABLE int mapToSourceIndex(int index) const;

signals:
    void filterRoleNameChanged();
    void filterListChanged();
    void sortRoleNameChanged();
    void sortOrderChanged();
    void countChanged();

protected:
    bool filterAcceptsRow(int source_row, const QModelIndex &source_parent) const override;
    bool lessThan(const QModelIndex &source_left, const QModelIndex &source_right) const override;

private:
    QString m_filterRoleName;
    QStringList m_filterList;
    QString m_sortRoleName;
};

#endif // SORTFILTERPROXYMODEL_H

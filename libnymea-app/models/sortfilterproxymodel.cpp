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

#include "sortfilterproxymodel.h"

#include <QtDebug>

SortFilterProxyModel::SortFilterProxyModel(QObject *parent) : QSortFilterProxyModel(parent)
{
    connect(this, &QSortFilterProxyModel::sourceModelChanged, this, [=](){
        connect(sourceModel(), &QAbstractItemModel::rowsInserted, this, &SortFilterProxyModel::countChanged);
        connect(sourceModel(), &QAbstractItemModel::rowsRemoved, this, &SortFilterProxyModel::countChanged);
        connect(sourceModel(), &QAbstractItemModel::modelReset, this, &SortFilterProxyModel::countChanged);
        emit countChanged();
    });
}

QString SortFilterProxyModel::filterRoleName() const
{
    return m_filterRoleName;
}

void SortFilterProxyModel::setFilterRoleName(const QString &filterRoleName)
{
    if (m_filterRoleName != filterRoleName) {
        m_filterRoleName = filterRoleName;
        emit filterRoleNameChanged();
        invalidateFilter();
        emit countChanged();
    }
}

QStringList SortFilterProxyModel::filterList() const
{
    return m_filterList;
}

void SortFilterProxyModel::setFilterList(const QStringList &filterList)
{
    if (m_filterList != filterList) {
        m_filterList = filterList;
        emit filterListChanged();
        invalidateFilter();
        emit countChanged();
    }
}

QString SortFilterProxyModel::sortRoleName() const
{
    return m_sortRoleName;
}

void SortFilterProxyModel::setSortRoleName(const QString &sortRoleName)
{
    if (m_sortRoleName != sortRoleName) {
        m_sortRoleName = sortRoleName;
        emit sortRoleNameChanged();
        sort(0, sortOrder());
    }
}

void SortFilterProxyModel::setSortOrder(Qt::SortOrder sortOrder)
{
    sort(0, sortOrder);
    emit sortOrderChanged();
}

QVariant SortFilterProxyModel::modelData(int row, const QString &role) const
{
    int roleId = roleNames().key(role.toUtf8());
    return QSortFilterProxyModel::data(index(row, 0), roleId);
}

int SortFilterProxyModel::mapToSourceIndex(int index) const
{
    return QSortFilterProxyModel::mapToSource(this->index(index, 0)).row();
}

bool SortFilterProxyModel::filterAcceptsRow(int source_row, const QModelIndex &source_parent) const
{
    if (!m_filterList.isEmpty() && !m_filterRoleName.isEmpty()) {
        QModelIndex idx = sourceModel()->index(source_row, 0, source_parent);
        int filterRole = sourceModel()->roleNames().key(m_filterRoleName.toUtf8());
        QVariant data = sourceModel()->data(idx, filterRole);
        if (!m_filterList.contains(data.toString())) {
            return false;
        }
    }
    return QSortFilterProxyModel::filterAcceptsRow(source_row, source_parent);
}

bool SortFilterProxyModel::lessThan(const QModelIndex &source_left, const QModelIndex &source_right) const
{
    int sortRole = sourceModel()->roleNames().key(m_sortRoleName.toUtf8());

    QVariant left = sourceModel()->data(source_left, sortRole);
    QVariant right = sourceModel()->data(source_right, sortRole);

    return left <= right;
}

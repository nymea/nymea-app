// SPDX-License-Identifier: LGPL-3.0-or-later

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
* Copyright (C) 2013 - 2024, nymea GmbH
* Copyright (C) 2024 - 2026, chargebyte austria GmbH
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

#include "serverloggingcategoriesproxy.h"

ServerLoggingCategoriesProxy::ServerLoggingCategoriesProxy(QObject *parent)
    : QSortFilterProxyModel(parent)
{
    setDynamicSortFilter(true);
    setSortCaseSensitivity(Qt::CaseInsensitive);
    setSortRole(ServerLoggingCategories::RoleName);

    connect(this, &QAbstractItemModel::rowsInserted, this, &ServerLoggingCategoriesProxy::countChanged);
    connect(this, &QAbstractItemModel::rowsRemoved, this, &ServerLoggingCategoriesProxy::countChanged);
    connect(this, &QAbstractItemModel::modelReset, this, &ServerLoggingCategoriesProxy::countChanged);
}

ServerLoggingCategories *ServerLoggingCategoriesProxy::categories() const
{
    return m_categories;
}

void ServerLoggingCategoriesProxy::setCategories(ServerLoggingCategories *categories)
{
    if (m_categories == categories)
        return;

    m_categories = categories;
    setSourceModel(categories);
    sort(0);

    emit categoriesChanged();
    emit countChanged();
}

QString ServerLoggingCategoriesProxy::filterRegularExpression() const
{
    return m_filterRegularExpression;
}

void ServerLoggingCategoriesProxy::setFilterRegularExpression(const QString &filterRegularExpression)
{
    if (m_filterRegularExpression == filterRegularExpression)
        return;

    m_filterRegularExpression = filterRegularExpression;
    m_filter = QRegularExpression(m_filterRegularExpression, QRegularExpression::CaseInsensitiveOption);

    emit filterRegularExpressionChanged();
    invalidateFilter();
    emit countChanged();
}

bool ServerLoggingCategoriesProxy::filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const
{
    if (!m_categories)
        return false;

    if (m_filterRegularExpression.isEmpty())
        return true;

    QModelIndex sourceIndex = m_categories->index(sourceRow, 0, sourceParent);
    const QString categoryName = m_categories->data(sourceIndex, ServerLoggingCategories::RoleName).toString();

    if (m_filter.isValid()) {
        return m_filter.match(categoryName).hasMatch();
    }

    return categoryName.contains(m_filterRegularExpression, Qt::CaseInsensitive);
}

bool ServerLoggingCategoriesProxy::lessThan(const QModelIndex &sourceLeft, const QModelIndex &sourceRight) const
{
    if (!sourceModel())
        return false;

    const QString left = sourceModel()->data(sourceLeft, sortRole()).toString();
    const QString right = sourceModel()->data(sourceRight, sortRole()).toString();

    const int caseInsensitiveCompare = QString::compare(left, right, Qt::CaseInsensitive);
    if (caseInsensitiveCompare == 0) {
        return QString::compare(left, right, Qt::CaseSensitive) < 0;
    }

    return caseInsensitiveCompare < 0;
}

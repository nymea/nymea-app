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

#ifndef SERVERLOGGINGCATEGORIESPROXY_H
#define SERVERLOGGINGCATEGORIESPROXY_H

#include <QRegularExpression>
#include <QSortFilterProxyModel>

#include "serverloggingcategories.h"

class ServerLoggingCategoriesProxy : public QSortFilterProxyModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged FINAL)
    Q_PROPERTY(ServerLoggingCategories *categories READ categories WRITE setCategories NOTIFY categoriesChanged FINAL)
    Q_PROPERTY(QString filterRegularExpression READ filterRegularExpression WRITE setFilterRegularExpression NOTIFY filterRegularExpressionChanged FINAL)

public:
    explicit ServerLoggingCategoriesProxy(QObject *parent = nullptr);

    ServerLoggingCategories *categories() const;
    void setCategories(ServerLoggingCategories *categories);

    QString filterRegularExpression() const;
    void setFilterRegularExpression(const QString &filterRegularExpression);

signals:
    void countChanged();
    void categoriesChanged();
    void filterRegularExpressionChanged();

protected:
    bool filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const override;
    bool lessThan(const QModelIndex &sourceLeft, const QModelIndex &sourceRight) const override;

private:
    ServerLoggingCategories *m_categories = nullptr;
    QString m_filterRegularExpression;
    QRegularExpression m_filter;
};

#endif // SERVERLOGGINGCATEGORIESPROXY_H

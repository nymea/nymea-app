/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
* Copyright 2013 - 2024, nymea GmbH
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

#ifndef SERVERLOGGINGCATEGORIESPROXY_H
#define SERVERLOGGINGCATEGORIESPROXY_H

#include <QObject>
#include <QSortFilterProxyModel>

#include "serverloggingcategories.h"

class ServerLoggingCategoriesProxy : public QSortFilterProxyModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)
    Q_PROPERTY(ServerLoggingCategories *loggingCategories READ loggingCategories WRITE setLoggingCategories)
    Q_PROPERTY(QString filterString READ filterString WRITE setFilterString NOTIFY filterStringChanged FINAL)
    Q_PROPERTY(TypeFilter typeFilter READ typeFilter WRITE setTypeFilter NOTIFY typeFilterChanged FINAL)

public:
    enum TypeFilter {
        TypeFilterNone,
        TypeFilterSystem,
        TypeFilterPlugin,
        TypeFilterCustom
    };
    Q_ENUM(TypeFilter)

    explicit ServerLoggingCategoriesProxy(QObject *parent = nullptr);

    ServerLoggingCategories *loggingCategories() const;
    void setLoggingCategories(ServerLoggingCategories *loggingCategories);

    TypeFilter typeFilter() const;
    void setTypeFilter(TypeFilter typeFilter);

    QString filterString() const;
    void setFilterString(const QString &filterString);

    Q_INVOKABLE void resetFilter();

    Q_INVOKABLE ServerLoggingCategory *get(int index) const;

signals:
    void countChanged();
    void loggingCategoriesChanged();
    void filterStringChanged();
    void typeFilterChanged();

protected:
    bool filterAcceptsRow(int source_row, const QModelIndex &source_parent) const Q_DECL_OVERRIDE;
    bool lessThan(const QModelIndex &left, const QModelIndex &right) const Q_DECL_OVERRIDE;

private:
    ServerLoggingCategories *m_loggingCategories = nullptr;
    TypeFilter m_typeFilter = TypeFilterNone;
    QString m_filterString;
};

#endif // SERVERLOGGINGCATEGORIESPROXY_H

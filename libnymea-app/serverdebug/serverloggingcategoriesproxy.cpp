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

#include "serverloggingcategoriesproxy.h"

ServerLoggingCategoriesProxy::ServerLoggingCategoriesProxy(QObject *parent)
    : QSortFilterProxyModel{parent}
{

}

ServerLoggingCategories *ServerLoggingCategoriesProxy::loggingCategories() const
{
    return m_loggingCategories;
}

void ServerLoggingCategoriesProxy::setLoggingCategories(ServerLoggingCategories *loggingCategories)
{
    m_loggingCategories = loggingCategories;
    emit loggingCategoriesChanged();

    setSourceModel(m_loggingCategories);

    setSortRole(ServerLoggingCategories::RoleName);
    sort(0, Qt::DescendingOrder);

    invalidateFilter();
    emit countChanged();
}

void ServerLoggingCategoriesProxy::setTypeFilter(TypeFilter typeFilter)
{
    if (m_typeFilter == typeFilter)
        return;

    m_typeFilter = typeFilter;

    invalidateFilter();
    emit countChanged();
}

ServerLoggingCategoriesProxy::TypeFilter ServerLoggingCategoriesProxy::typeFilter() const
{
    return m_typeFilter;
}

QString ServerLoggingCategoriesProxy::filterString() const
{
    return m_filterString;
}

void ServerLoggingCategoriesProxy::setFilterString(const QString &filterString)
{
    if (m_filterString == filterString)
        return;

    m_filterString = filterString;
    emit typeFilterChanged();

    invalidateFilter();
    emit countChanged();
}

void ServerLoggingCategoriesProxy::resetFilter()
{
    m_filterString = QString();
    m_typeFilter = TypeFilterNone;

    invalidateFilter();
    emit countChanged();
}

ServerLoggingCategory *ServerLoggingCategoriesProxy::get(int index) const
{
    if (!m_loggingCategories)
        return nullptr;

    return m_loggingCategories->get(mapToSource(this->index(index, 0)).row());
}

bool ServerLoggingCategoriesProxy::filterAcceptsRow(int source_row, const QModelIndex &source_parent) const
{
    Q_UNUSED(source_parent)

    ServerLoggingCategory *category = m_loggingCategories->get(source_row);

    if (!m_filterString.isEmpty() && !category->name().toLower().contains(m_filterString.toLower()))
        return false;

    bool typeFilter = true;
    switch (m_typeFilter) {
    case TypeFilterNone:
        typeFilter = false;
        break;
    case TypeFilterSystem:
        typeFilter = category->type() == ServerLoggingCategory::TypeSystem;
        break;
    case TypeFilterPlugin:
        typeFilter = category->type() == ServerLoggingCategory::TypePlugin;
        break;
    case TypeFilterCustom:
        typeFilter = category->type() == ServerLoggingCategory::TypeCustom;
        break;
    }

    return typeFilter;
}

bool ServerLoggingCategoriesProxy::lessThan(const QModelIndex &left, const QModelIndex &right) const
{
    QString leftName = sourceModel()->data(left, ServerLoggingCategories::RoleName).toString();
    QString rightName = sourceModel()->data(right, ServerLoggingCategories::RoleName).toString();
    return QString::localeAwareCompare(leftName, rightName) > 0;
}

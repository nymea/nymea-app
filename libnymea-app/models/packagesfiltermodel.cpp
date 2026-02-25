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

#include "packagesfiltermodel.h"
#include "types/package.h"

PackagesFilterModel::PackagesFilterModel(QObject *parent): QSortFilterProxyModel(parent)
{
    setSortRole(Packages::RoleDisplayName);
    sort(0);
}

Packages *PackagesFilterModel::packages() const
{
    return m_packages;
}

void PackagesFilterModel::setPackages(Packages *packages)
{
    if (m_packages != packages) {
        m_packages = packages;
        setSourceModel(packages);
        connect(packages, &Packages::countChanged, this, &PackagesFilterModel::countChanged);
        emit packagesChanged();
        emit countChanged();
        invalidate();
    }
}

bool PackagesFilterModel::updatesOnly() const
{
    return m_updatesOnly;
}

void PackagesFilterModel::setUpdatesOnly(bool updatesOnly)
{
    if (m_updatesOnly != updatesOnly) {
        m_updatesOnly = updatesOnly;
        emit updatesOnlyChanged();
        invalidateFilter();
        emit countChanged();
    }
}

QString PackagesFilterModel::nameFilter() const
{
    return m_nameFilter;
}

void PackagesFilterModel::setNameFilter(const QString &nameFilter)
{
    if (nameFilter != m_nameFilter) {
        m_nameFilter = nameFilter;
        emit nameFilterChanged();
        invalidateFilter();
        emit countChanged();
    }
}

Package *PackagesFilterModel::get(int index) const
{
    return m_packages->get(mapToSource(this->index(index, 0)).row());
}

bool PackagesFilterModel::filterAcceptsRow(int source_row, const QModelIndex &source_parent) const
{
    Q_UNUSED(source_parent)
    if (m_updatesOnly) {
        if (!m_packages->get(source_row)->updateAvailable()) {
            return false;
        }
    }
    if (!m_nameFilter.isEmpty()) {
        if (!m_packages->get(source_row)->displayName().toLower().contains(m_nameFilter.toLower())) {
            return false;
        }
    }
    return true;
}

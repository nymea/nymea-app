/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
* Copyright 2013 - 2020, nymea GmbH
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

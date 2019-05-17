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

Package *PackagesFilterModel::get(int index) const
{
    return m_packages->get(mapToSource(this->index(index, 0)).row());
}

bool PackagesFilterModel::filterAcceptsRow(int source_row, const QModelIndex &source_parent) const
{
    if (m_updatesOnly) {
        if (!m_packages->get(source_row)->updateAvailable()) {
            return false;
        }
    }
    return true;
}

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

#ifndef PACKAGESFILTERMODEL_H
#define PACKAGESFILTERMODEL_H

#include <QSortFilterProxyModel>
#include "types/packages.h"

class PackagesFilterModel : public QSortFilterProxyModel
{
    Q_OBJECT
    Q_PROPERTY(Packages* packages READ packages WRITE setPackages NOTIFY packagesChanged)
    Q_PROPERTY(bool updatesOnly READ updatesOnly WRITE setUpdatesOnly NOTIFY updatesOnlyChanged)
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)

    Q_PROPERTY(QString nameFilter READ nameFilter WRITE setNameFilter NOTIFY nameFilterChanged)

public:
    explicit PackagesFilterModel(QObject *parent = nullptr);

    Packages* packages() const;
    void setPackages(Packages *packages);

    bool updatesOnly() const;
    void setUpdatesOnly(bool updatesOnly);

    QString nameFilter() const;
    void setNameFilter(const QString &nameFilter);

    Q_INVOKABLE Package* get(int index) const;

protected:
    bool filterAcceptsRow(int source_row, const QModelIndex &source_parent) const override;

signals:
    void countChanged();
    void packagesChanged();
    void updatesOnlyChanged();
    void nameFilterChanged();

private:
    Packages *m_packages;

    bool m_updatesOnly = false;

    QString m_nameFilter;
};

#endif // PACKAGESFILTERMODEL_H

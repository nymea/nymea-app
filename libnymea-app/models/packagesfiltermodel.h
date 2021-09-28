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

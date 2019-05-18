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

public:
    explicit PackagesFilterModel(QObject *parent = nullptr);

    Packages* packages() const;
    void setPackages(Packages *packages);

    bool updatesOnly() const;
    void setUpdatesOnly(bool updatesOnly);

    Q_INVOKABLE Package* get(int index) const;

protected:
    bool filterAcceptsRow(int source_row, const QModelIndex &source_parent) const override;

signals:
    void countChanged();
    void packagesChanged();
    void updatesOnlyChanged();

private:
    Packages *m_packages;

    bool m_updatesOnly = false;
};

#endif // PACKAGESFILTERMODEL_H

#ifndef SORTFILTERPROXYMODEL_H
#define SORTFILTERPROXYMODEL_H

#include <QSortFilterProxyModel>

class SortFilterProxyModel : public QSortFilterProxyModel
{
    Q_OBJECT
    Q_PROPERTY(QString filterRoleName READ filterRoleName WRITE setFilterRoleName NOTIFY filterRoleNameChanged)
    Q_PROPERTY(QStringList filterList READ filterList WRITE setFilterList NOTIFY filterListChanged)
    Q_PROPERTY(QString sortRoleName READ sortRoleName WRITE setSortRoleName NOTIFY sortRoleNameChanged)
    Q_PROPERTY(Qt::SortOrder sortOrder READ sortOrder WRITE setSortOrder NOTIFY sortOrderChanged)
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)

public:
    explicit SortFilterProxyModel(QObject *parent = nullptr);

    QString filterRoleName() const;
    void setFilterRoleName(const QString &filterRoleName);

    QStringList filterList() const;
    void setFilterList(const QStringList &filterList);

    QString sortRoleName() const;
    void setSortRoleName(const QString &sortRoleName);

    void setSortOrder(Qt::SortOrder sortOrder);

    Q_INVOKABLE QVariant modelData(int row, const QString &role) const;
    Q_INVOKABLE int mapToSourceIndex(int index) const;

signals:
    void filterRoleNameChanged();
    void filterListChanged();
    void sortRoleNameChanged();
    void sortOrderChanged();
    void countChanged();

protected:
    bool filterAcceptsRow(int source_row, const QModelIndex &source_parent) const override;
    bool lessThan(const QModelIndex &source_left, const QModelIndex &source_right) const override;

private:
    QString m_filterRoleName;
    QStringList m_filterList;
    QString m_sortRoleName;
};

#endif // SORTFILTERPROXYMODEL_H

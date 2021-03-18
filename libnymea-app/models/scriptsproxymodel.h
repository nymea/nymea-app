#ifndef SCRIPTSPROXYMODEL_H
#define SCRIPTSPROXYMODEL_H

#include <QSortFilterProxyModel>

#include "types/scripts.h"

class ScriptsProxyModel : public QSortFilterProxyModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)
    Q_PROPERTY(Scripts* scripts READ scripts WRITE setScripts NOTIFY scriptsChanged)

    Q_PROPERTY(QString filterName READ filterName WRITE setFilterName NOTIFY filterNameChanged)

public:
    explicit ScriptsProxyModel(QObject *parent = nullptr);

    Scripts* scripts() const;
    void setScripts(Scripts *scripts);

    QString filterName() const;
    void setFilterName(const QString &filterName);

    Script* get(int index) const;

signals:
    void countChanged();
    void scriptsChanged();
    void filterNameChanged();

protected:
    bool filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const override;

private:
    Scripts* m_scripts = nullptr;

    QString m_filterName;
};

#endif // SCRIPTSPROXYMODEL_H

#ifndef RULESFILTERMODEL_H
#define RULESFILTERMODEL_H

#include <QSortFilterProxyModel>
#include <QUuid>

class Rules;
class Rule;

class RulesFilterModel : public QSortFilterProxyModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)
    Q_PROPERTY(Rules* rules READ rules WRITE setRules NOTIFY rulesChanged)
    Q_PROPERTY(QString filterDeviceId READ filterDeviceId WRITE setFilterDeviceId NOTIFY filterDeviceIdChanged)
    Q_PROPERTY(bool filterExecutable READ filterExecutable WRITE setFilterExecutable NOTIFY filterExecutableChanged)

public:
    explicit RulesFilterModel(QObject *parent = nullptr);

    Rules* rules() const;
    void setRules(Rules* rules);

    QString filterDeviceId() const;
    void setFilterDeviceId(const QString &filterDeviceId);

    bool filterExecutable() const;
    void setFilterExecutable(bool filterExecutable);

    Q_INVOKABLE Rule* get(int index) const;

signals:
    void rulesChanged();
    void filterDeviceIdChanged();
    void filterExecutableChanged();
    void countChanged();

protected:
    bool filterAcceptsRow(int source_row, const QModelIndex &source_parent) const override;

private:
    Rules *m_rules = nullptr;
    QString m_filterDeviceId;
    bool m_filterExecutable = false;
};

#endif // RULESFILTERMODEL_H

#ifndef RULESFILTERMODEL_H
#define RULESFILTERMODEL_H

#include <QSortFilterProxyModel>
#include <QUuid>

class Rules;
class Rule;

class RulesFilterModel : public QSortFilterProxyModel
{
    Q_OBJECT
    Q_PROPERTY(Rules* rules READ rules WRITE setRules NOTIFY rulesChanged)
    Q_PROPERTY(QUuid filterEventDeviceId READ filterEventDeviceId WRITE setFilterEventDeviceId NOTIFY filterEventDeviceIdChanged)

public:
    explicit RulesFilterModel(QObject *parent = nullptr);

    Rules* rules() const;
    void setRules(Rules* rules);

    QUuid filterEventDeviceId() const;
    void setFilterEventDeviceId(const QUuid &filterEventDeviceId);

    Q_INVOKABLE Rule* get(int index) const;

signals:
    void rulesChanged();
    void filterEventDeviceIdChanged();

protected:
    bool filterAcceptsRow(int source_row, const QModelIndex &source_parent) const override;

private:
    Rules *m_rules = nullptr;
    QUuid m_filterEventDeviceId;
};

#endif // RULESFILTERMODEL_H

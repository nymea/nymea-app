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
    Q_PROPERTY(QString filterDeviceId READ filterDeviceId WRITE setFilterDeviceId NOTIFY filterDeviceIdChanged)

public:
    explicit RulesFilterModel(QObject *parent = nullptr);

    Rules* rules() const;
    void setRules(Rules* rules);

    QString filterDeviceId() const;
    void setFilterDeviceId(const QString &filterDeviceId);

    Q_INVOKABLE Rule* get(int index) const;

signals:
    void rulesChanged();
    void filterDeviceIdChanged();

protected:
    bool filterAcceptsRow(int source_row, const QModelIndex &source_parent) const override;

private:
    Rules *m_rules = nullptr;
    QString m_filterDeviceId;
};

#endif // RULESFILTERMODEL_H

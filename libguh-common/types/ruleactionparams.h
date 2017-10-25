#ifndef RULEACTIONPARAMS_H
#define RULEACTIONPARAMS_H

#include <QAbstractListModel>

class RuleActionParam;

class RuleActionParams : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)
public:
    explicit RuleActionParams(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role) const override;

    void addRuleActionParam(RuleActionParam* ruleActionParam);

    Q_INVOKABLE RuleActionParam* get(int index) const;

signals:
    void countChanged();

private:
    QList<RuleActionParam*> m_list;
};

#endif // RULEACTIONPARAMS_H

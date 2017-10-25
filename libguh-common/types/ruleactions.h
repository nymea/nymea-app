#ifndef RULEACTIONS_H
#define RULEACTIONS_H

#include <QAbstractListModel>

class RuleAction;

class RuleActions : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)
public:
    explicit RuleActions(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role) const override;

    void addRuleAction(RuleAction* ruleAction);

    Q_INVOKABLE RuleAction* get(int index) const;

signals:
    void countChanged();

private:
    QList<RuleAction*> m_list;
};

#endif // RULEACTIONS_H

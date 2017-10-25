#ifndef RULES_H
#define RULES_H

#include <QAbstractListModel>

class Rule;

class Rules : public QAbstractListModel
{
    Q_OBJECT
public:
    enum Roles {
        RoleName
    };
    explicit Rules(QObject *parent = nullptr);

    void clear();

    int rowCount(const QModelIndex &parent) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

    void insert(Rule *rule);
    void remove(const QUuid &ruleId);

    Q_INVOKABLE Rule* get(int index) const;
    Q_INVOKABLE Rule* getRule(const QUuid &ruleId) const;

private:
    QList<Rule*> m_list;
};

#endif // RULES_H

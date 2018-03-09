#ifndef STATEEVALUATORS_H
#define STATEEVALUATORS_H

#include <QAbstractListModel>

class StateEvaluator;

class StateEvaluators : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)

public:
    explicit StateEvaluators(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

    void addStateEvaluator(StateEvaluator* stateEvaluator);
    Q_INVOKABLE StateEvaluator* get(int index) const;
    StateEvaluator* take(int index);

signals:
    void countChanged();

private:
    QList<StateEvaluator*> m_list;
};

#endif // STATEEVALUATORS_H

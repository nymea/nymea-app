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

    // Caller takes ownership, is responsible for deleting
    Q_INVOKABLE StateEvaluator* take(int index);

    // StateEvaluator will be deleted
    Q_INVOKABLE void remove(int index);

    bool operator==(StateEvaluators *other) const;

signals:
    void countChanged();

private:
    QList<StateEvaluator*> m_list;
};

#endif // STATEEVALUATORS_H

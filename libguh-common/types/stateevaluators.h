#ifndef STATEEVALUATORS_H
#define STATEEVALUATORS_H

#include <QAbstractListModel>

class StateEvaluator;

class StateEvaluators : public QAbstractListModel
{
    Q_OBJECT
public:
    explicit StateEvaluators(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

    StateEvaluator* get(int index) const;
private:
    QList<StateEvaluator*> m_list;
};

#endif // STATEEVALUATORS_H

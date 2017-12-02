#ifndef STATEEVALUATOR_H
#define STATEEVALUATOR_H

#include <QObject>

class StateEvaluators;
class StateDescriptor;

class StateEvaluator : public QObject
{
    Q_OBJECT
    Q_PROPERTY(StateOperator stateOperator READ stateOperator CONSTANT)
    Q_PROPERTY(StateEvaluators* childEvaluators READ childEvaluators CONSTANT)
    Q_PROPERTY(StateDescriptor* stateDescriptor READ stateDescriptor CONSTANT)

public:
    enum StateOperator {
        StateOperatorAnd,
        StateOperatorOr
    };
    Q_ENUM(StateOperator)
    explicit StateEvaluator(QObject *parent = nullptr);

    StateOperator stateOperator() const;
    void setStateOperator(StateOperator stateOperator);

    StateEvaluators* childEvaluators() const;

    StateDescriptor* stateDescriptor() const;

    bool containsDevice(const QUuid &deviceId) const;

private:
    StateOperator m_operator = StateOperatorAnd;
    StateEvaluators *m_childEvaluators = nullptr;
    StateDescriptor *m_stateDescriptor = nullptr;

};

#endif // STATEEVALUATOR_H

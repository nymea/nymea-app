#ifndef STATEEVALUATOR_H
#define STATEEVALUATOR_H

#include <QObject>

class StateEvaluators;
class StateDescriptor;

class StateEvaluator : public QObject
{
    Q_OBJECT
    Q_PROPERTY(StateOperator stateOperator READ stateOperator WRITE setStateOperator NOTIFY stateOperatorChanged)
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
    void setStateDescriptor(StateDescriptor *stateDescriptor);

    bool containsDevice(const QUuid &deviceId) const;

    Q_INVOKABLE StateEvaluator* addChildEvaluator();

    StateEvaluator* clone() const;
    bool operator==(StateEvaluator *other) const;

signals:
    void stateOperatorChanged();

private:
    StateOperator m_operator = StateOperatorAnd;
    StateEvaluators *m_childEvaluators = nullptr;
    StateDescriptor *m_stateDescriptor = nullptr;

};

#endif // STATEEVALUATOR_H

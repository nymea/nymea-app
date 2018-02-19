#ifndef STATEDESCRIPTOR_H
#define STATEDESCRIPTOR_H

#include <QObject>
#include <QUuid>
#include <QVariant>

class StateDescriptor : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QUuid deviceId READ deviceId CONSTANT)
    Q_PROPERTY(ValueOperator valueOperator READ valueOperator CONSTANT)
    Q_PROPERTY(QUuid stateTypeId READ stateTypeId CONSTANT)
    Q_PROPERTY(QVariant value READ value CONSTANT)

public:
    enum ValueOperator {
        ValueOperatorEquals,
        ValueOperatorNotEquals,
        ValueOperatorLess,
        ValueOperatorGreater,
        ValueOperatorLessOrEqual,
        ValueOperatorGreaterOrEqual
    };
    Q_ENUM(ValueOperator)

    explicit StateDescriptor(const QUuid &deviceId, ValueOperator valueOperator, const QUuid &stateTypeId, const QVariant &value, QObject *parent = nullptr);

    QUuid deviceId() const;
    ValueOperator valueOperator() const;
    QUuid stateTypeId() const;
    QVariant value() const;

    StateDescriptor* clone() const;
private:
    QUuid m_deviceId;
    ValueOperator m_operator = ValueOperatorEquals;
    QUuid m_stateTypeId;
    QVariant m_value;
};

#endif // STATEDESCRIPTOR_H

#ifndef STATEDESCRIPTOR_H
#define STATEDESCRIPTOR_H

#include <QObject>
#include <QUuid>
#include <QVariant>

class StateDescriptor : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QUuid deviceId READ deviceId WRITE setDeviceId NOTIFY deviceIdChanged)
    Q_PROPERTY(ValueOperator valueOperator READ valueOperator WRITE setValueOperator NOTIFY valueOperatorChanged)
    Q_PROPERTY(QUuid stateTypeId READ stateTypeId WRITE setStateTypeId NOTIFY stateTypeIdChanged)
    Q_PROPERTY(QVariant value READ value WRITE setValue NOTIFY valueChanged)

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
    StateDescriptor(QObject *parent = nullptr);

    QUuid deviceId() const;
    void setDeviceId(const QUuid &deviceId);

    ValueOperator valueOperator() const;
    void setValueOperator(ValueOperator valueOperator);

    QUuid stateTypeId() const;
    void setStateTypeId(const QUuid &stateTypeId);

    QVariant value() const;
    void setValue(const QVariant &value);

    StateDescriptor* clone() const;

signals:
    void deviceIdChanged();
    void valueOperatorChanged();
    void stateTypeIdChanged();
    void valueChanged();

private:
    QUuid m_deviceId;
    ValueOperator m_operator = ValueOperatorEquals;
    QUuid m_stateTypeId;
    QVariant m_value;
};

#endif // STATEDESCRIPTOR_H

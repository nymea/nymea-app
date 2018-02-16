#ifndef PARAMDESCRIPTOR_H
#define PARAMDESCRIPTOR_H

#include "param.h"

class ParamDescriptor : public Param
{
    Q_OBJECT
    Q_PROPERTY(ValueOperator operatorType READ operatorType WRITE setOperatorType NOTIFY operatorTypeChanged)
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

    explicit ParamDescriptor(const QString &id = QString(), const QVariant &value = QVariant(), QObject *parent = nullptr);

    ValueOperator operatorType() const;
    void setOperatorType(ValueOperator operatorType);

signals:
    void operatorTypeChanged();

private:
    ValueOperator m_operator;
};

#endif // PARAMDESCRIPTOR_H

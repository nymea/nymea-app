#ifndef PARAMDESCRIPTOR_H
#define PARAMDESCRIPTOR_H

#include "param.h"

class ParamDescriptor : public Param
{
    Q_OBJECT
    Q_PROPERTY(QString paramName READ paramName WRITE setParamName NOTIFY paramNameChanged)
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

    explicit ParamDescriptor(QObject *parent = nullptr);

    QString paramName() const;
    void setParamName(const QString &paramName);

    ValueOperator operatorType() const;
    void setOperatorType(ValueOperator operatorType);

    ParamDescriptor* clone() const;

signals:
    void paramNameChanged();
    void operatorTypeChanged();

private:
    QString m_paramName;
    ValueOperator m_operator;
};

#endif // PARAMDESCRIPTOR_H

#include "paramdescriptor.h"

#include <QDebug>

ParamDescriptor::ParamDescriptor(QObject *parent) : Param(parent)
{

}

QString ParamDescriptor::paramName() const
{
    return m_paramName;
}

void ParamDescriptor::setParamName(const QString &paramName)
{
    if (m_paramName != paramName) {
        m_paramName = paramName;
        emit paramNameChanged();
    }
}

ParamDescriptor::ValueOperator ParamDescriptor::operatorType() const
{
    return m_operator;
}

void ParamDescriptor::setOperatorType(ParamDescriptor::ValueOperator operatorType)
{
    if (m_operator != operatorType) {
        m_operator = operatorType;
        emit operatorTypeChanged();
    }
}

ParamDescriptor *ParamDescriptor::clone() const
{
    ParamDescriptor *ret = new ParamDescriptor();
    ret->setParamTypeId(this->paramTypeId());
    ret->setParamName(this->paramName());
    ret->setValue(this->value());
    ret->setOperatorType(this->operatorType());
    return ret;
}

#define COMPARE(a, b) if (a != b) { qDebug() << a << "!=" << b; return false; }
#define COMPARE_PTR(a, b) if (!a->operator==(b)) { qDebug() << a << "!=" << b; return false; }
bool ParamDescriptor::operator==(ParamDescriptor *other) const
{
    COMPARE(m_paramTypeId, other->paramTypeId());
    COMPARE(m_paramName, other->paramName());
    COMPARE(m_value, other->value());
    COMPARE(m_operator, other->operatorType());
    return true;
}

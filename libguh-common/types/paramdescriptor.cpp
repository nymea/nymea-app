#include "paramdescriptor.h"

ParamDescriptor::ParamDescriptor(const QString &id, const QVariant &value, QObject *parent) : Param(id, value, parent)
{

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
    ParamDescriptor *ret = new ParamDescriptor(this->id(), this->value());
    ret->setOperatorType(this->operatorType());
    return ret;
}

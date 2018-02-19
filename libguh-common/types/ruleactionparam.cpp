#include "ruleactionparam.h"

RuleActionParam::RuleActionParam(QObject *parent) : QObject(parent)
{

}

QUuid RuleActionParam::paramTypeId() const
{
    return m_paramTypeId;
}

void RuleActionParam::setParamTypeId(const QUuid &paramTypeId)
{
    if (m_paramTypeId != paramTypeId) {
        m_paramTypeId = paramTypeId;
        emit paramTypeIdChanged();
    }
}

QVariant RuleActionParam::value() const
{
    return m_value;
}

void RuleActionParam::setValue(const QVariant &value)
{
    if (m_value != value) {
        m_value = value;
        emit valueChanged();
    }
}

RuleActionParam *RuleActionParam::clone() const
{
    RuleActionParam *ret = new RuleActionParam();
    ret->setParamTypeId(paramTypeId());
    ret->setValue(value());
    return ret;
}

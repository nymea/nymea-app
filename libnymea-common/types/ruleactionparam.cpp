#include "ruleactionparam.h"

RuleActionParam::RuleActionParam(const QString &paramName, const QVariant &value, QObject *parent):
    Param(parent),
    m_paramName(paramName)
{
    setValue(value);
}

RuleActionParam::RuleActionParam(QObject *parent) : Param(parent)
{

}

QString RuleActionParam::paramName() const
{
    return m_paramName;
}

void RuleActionParam::setParamName(const QString &paramName)
{
    if (m_paramName != paramName) {
        m_paramName = paramName;
        emit paramNameChanged();
    }
}

QString RuleActionParam::eventTypeId() const
{
    return m_eventTypeId;
}

void RuleActionParam::setEventTypeId(const QString &eventTypeId)
{
    if (m_eventTypeId != eventTypeId) {
        m_eventTypeId = eventTypeId;
        emit eventTypeIdChanged();
    }
}

QString RuleActionParam::eventParamTypeId() const
{
    return m_eventParamTypeId;
}

void RuleActionParam::setEventParamTypeId(const QString &eventParamTypeId)
{
    if (m_eventParamTypeId != eventParamTypeId) {
        m_eventParamTypeId = eventParamTypeId;
        emit eventParamTypeIdChanged();
    }
}

RuleActionParam *RuleActionParam::clone() const
{
    RuleActionParam *ret = new RuleActionParam();
    ret->setParamTypeId(paramTypeId());
    ret->setParamName(paramName());
    ret->setValue(value());
    ret->setEventTypeId(eventTypeId());
    ret->setEventParamTypeId(eventParamTypeId());
    return ret;
}

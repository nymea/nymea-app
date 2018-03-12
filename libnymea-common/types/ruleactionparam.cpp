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
    ret->setValue(value());
    return ret;
}

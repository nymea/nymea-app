#include "ruleactionparamtemplate.h"

RuleActionParamTemplate::RuleActionParamTemplate(const QString &paramName, const QVariant &value, QObject *parent):
    RuleActionParam(paramName, value, parent)
{

}

RuleActionParamTemplate::RuleActionParamTemplate(const QString &paramName, const QString &eventInterface, const QString &eventName, const QString &eventParamName, QObject *parent):
    RuleActionParam(parent),
    m_eventInterface(eventInterface),
    m_eventName(eventName),
    m_eventParamName(eventParamName)
{
    setParamName(paramName);
}

RuleActionParamTemplate::RuleActionParamTemplate(QObject *parent) : RuleActionParam(parent)
{

}

QString RuleActionParamTemplate::eventInterface() const
{
    return m_eventInterface;
}

void RuleActionParamTemplate::setEventInterface(const QString &eventInterface)
{
    m_eventInterface = eventInterface;
}

QString RuleActionParamTemplate::eventName() const
{
    return m_eventName;
}

void RuleActionParamTemplate::setEventName(const QString &eventName)
{
    m_eventName = eventName;
}

QString RuleActionParamTemplate::eventParamName() const
{
    return m_eventParamName;
}

void RuleActionParamTemplate::setEventParamName(const QString &eventParamName)
{
    m_eventParamName = eventParamName;
}

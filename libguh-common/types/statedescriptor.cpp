#include "statedescriptor.h"

StateDescriptor::StateDescriptor(const QUuid &deviceId, StateDescriptor::ValueOperator valueOperator, const QUuid &stateTypeId, const QVariant &value, QObject *parent):
    QObject(parent),
    m_deviceId(deviceId),
    m_operator(valueOperator),
    m_stateTypeId(stateTypeId),
    m_value(value)
{

}

QUuid StateDescriptor::deviceId() const
{
    return m_deviceId;
}

StateDescriptor::ValueOperator StateDescriptor::valueOperator() const
{
    return m_operator;
}

QUuid StateDescriptor::stateTypeId() const
{
    return m_stateTypeId;
}

QVariant StateDescriptor::value() const
{
    return m_value;
}

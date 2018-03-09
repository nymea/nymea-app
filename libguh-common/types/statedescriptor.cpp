#include "statedescriptor.h"

StateDescriptor::StateDescriptor(const QUuid &deviceId, StateDescriptor::ValueOperator valueOperator, const QUuid &stateTypeId, const QVariant &value, QObject *parent):
    QObject(parent),
    m_deviceId(deviceId),
    m_operator(valueOperator),
    m_stateTypeId(stateTypeId),
    m_value(value)
{

}

StateDescriptor::StateDescriptor(QObject *parent) : QObject(parent)
{

}

QUuid StateDescriptor::deviceId() const
{
    return m_deviceId;
}

void StateDescriptor::setDeviceId(const QUuid &deviceId)
{
    if (m_deviceId != deviceId) {
        m_deviceId = deviceId;
        emit deviceIdChanged();
    }
}

StateDescriptor::ValueOperator StateDescriptor::valueOperator() const
{
    return m_operator;
}

void StateDescriptor::setValueOperator(StateDescriptor::ValueOperator valueOperator)
{
    if (m_operator != valueOperator) {
        m_operator = valueOperator;
        emit valueOperatorChanged();
    }
}

QUuid StateDescriptor::stateTypeId() const
{
    return m_stateTypeId;
}

void StateDescriptor::setStateTypeId(const QUuid &stateTypeId)
{
    if (m_stateTypeId != stateTypeId) {
        m_stateTypeId = stateTypeId;
        emit stateTypeIdChanged();
    }
}

QVariant StateDescriptor::value() const
{
    return m_value;
}

void StateDescriptor::setValue(const QVariant &value)
{
    if (m_value != value) {
        m_value = value;
        emit valueChanged();
    }
}

StateDescriptor *StateDescriptor::clone() const
{
    StateDescriptor *ret = new StateDescriptor(deviceId(), valueOperator(), stateTypeId(), value());
    return ret;
}

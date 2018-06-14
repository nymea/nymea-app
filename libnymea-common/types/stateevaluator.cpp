#include "stateevaluator.h"
#include "stateevaluators.h"
#include "statedescriptor.h"

StateEvaluator::StateEvaluator(QObject *parent) : QObject(parent)
{
    m_childEvaluators = new StateEvaluators(this);
    m_stateDescriptor = new StateDescriptor(this);
}

StateEvaluator::StateOperator StateEvaluator::stateOperator() const
{
    return m_operator;
}

void StateEvaluator::setStateOperator(StateEvaluator::StateOperator stateOperator)
{
    if (m_operator != stateOperator) {
        m_operator = stateOperator;
        emit stateOperatorChanged();
    }
}

StateEvaluators *StateEvaluator::childEvaluators() const
{
    return m_childEvaluators;
}

StateDescriptor *StateEvaluator::stateDescriptor() const
{
    return m_stateDescriptor;
}

void StateEvaluator::setStateDescriptor(StateDescriptor *stateDescriptor)
{
    if (m_stateDescriptor) {
        m_stateDescriptor->deleteLater();
    }
    stateDescriptor->setParent(this);
    m_stateDescriptor = stateDescriptor;
}

bool StateEvaluator::containsDevice(const QUuid &deviceId) const
{
    if (m_stateDescriptor && m_stateDescriptor->deviceId() == deviceId) {
        return true;
    }
    for (int i = 0; i < m_childEvaluators->rowCount(); i++) {
        if (m_childEvaluators->get(i)->containsDevice(deviceId)) {
            return true;
        }
    }
    return false;
}

StateEvaluator* StateEvaluator::addChildEvaluator()
{
    StateEvaluator* stateEvaluator = new StateEvaluator(m_childEvaluators);
    m_childEvaluators->addStateEvaluator(stateEvaluator);
    return stateEvaluator;
}

StateEvaluator *StateEvaluator::clone() const
{
    StateEvaluator *ret = new StateEvaluator();
    ret->m_operator = this->m_operator;
    ret->m_stateDescriptor->setDeviceId(this->m_stateDescriptor->deviceId());
    ret->m_stateDescriptor->setStateTypeId(this->m_stateDescriptor->stateTypeId());
    ret->m_stateDescriptor->setValueOperator(this->m_stateDescriptor->valueOperator());
    ret->m_stateDescriptor->setValue(this->m_stateDescriptor->value());
    for (int i = 0; i < this->m_childEvaluators->rowCount(); i++) {
        ret->m_childEvaluators->addStateEvaluator(this->m_childEvaluators->get(i)->clone());
    }
    return ret;
}

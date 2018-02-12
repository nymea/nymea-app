#include "stateevaluator.h"
#include "stateevaluators.h"
#include "statedescriptor.h"

StateEvaluator::StateEvaluator(QObject *parent) : QObject(parent)
{
    m_childEvaluators = new StateEvaluators(this);
//    m_stateDescriptor = new StateDescriptor(this);
}

StateEvaluator::StateOperator StateEvaluator::stateOperator() const
{
    return m_operator;
}

void StateEvaluator::setStateOperator(StateEvaluator::StateOperator stateOperator)
{
    m_operator = stateOperator;
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

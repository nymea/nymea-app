#include "stateevaluatortemplate.h"

StateEvaluatorTemplate::StateEvaluatorTemplate(StateDescriptorTemplate *stateDescriptorTemplate, StateOperator stateOperator, QObject *parent):
    QObject(parent),
    m_stateDescriptorTemplate(stateDescriptorTemplate),
    m_stateOperator(stateOperator),
    m_childEvaluatorTemplates(new StateEvaluatorTemplates(this))
{
    stateDescriptorTemplate->setParent(this);
}

StateDescriptorTemplate *StateEvaluatorTemplate::stateDescriptorTemplate() const
{
    return m_stateDescriptorTemplate;
}

StateEvaluatorTemplate::StateOperator StateEvaluatorTemplate::stateOperator() const
{
    return m_stateOperator;
}

StateEvaluatorTemplates *StateEvaluatorTemplate::childEvaluatorTemplates() const
{
    return m_childEvaluatorTemplates;
}

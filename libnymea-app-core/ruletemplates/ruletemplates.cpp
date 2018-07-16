#include "ruletemplates.h"

#include "ruletemplate.h"
#include "eventdescriptortemplate.h"
#include "ruleactiontemplate.h"
#include "stateevaluatortemplate.h"

#include "types/ruleactionparam.h"
#include "types/ruleactionparams.h"

#include <QDebug>

RuleTemplates::RuleTemplates(QObject *parent) : QAbstractListModel(parent)
{
    RuleTemplate* t;
    EventDescriptorTemplate* evt;
    StateEvaluatorTemplate* set;
    RuleActionTemplate* rat;
    RuleActionTemplate* reat; // exit

    t = new RuleTemplate("Switch a light", "%0 switches %1", this);
    evt = new EventDescriptorTemplate("button", "pressed", 0, EventDescriptorTemplate::SelectionModeDevice);
    t->eventDescriptorTemplates()->addEventDescriptorTemplate(evt);
    set = new StateEvaluatorTemplate(new StateDescriptorTemplate("light", "power", 1, StateDescriptorTemplate::ValueOperatorEquals, false));
    t->setStateEvaluatorTemplate(set);
    rat = new RuleActionTemplate("light", "power", 1, RuleActionTemplate::SelectionModeDevice);
    rat->ruleActionParams()->setRuleActionParamByName("power", true);
    t->ruleActionTemplates()->addRuleActionTemplate(rat);
    reat = new RuleActionTemplate("light", "power", 1, RuleActionTemplate::SelectionModeDevice);
    reat->ruleActionParams()->setRuleActionParamByName("power", false);
    t->ruleExitActionTemplates()->addRuleActionTemplate(reat);
    m_list.append(t);

    t = new RuleTemplate("Intelligent blinds", "Intelligent blinds %1", this);
    set = new StateEvaluatorTemplate(new StateDescriptorTemplate("temperaturesensor", "temperature", 0, StateDescriptorTemplate::ValueOperatorGreater, 20));
    t->setStateEvaluatorTemplate(set);
    rat = new RuleActionTemplate("simpleclosable", "close", 1, RuleActionTemplate::SelectionModeDevice);
    t->ruleActionTemplates()->addRuleActionTemplate(rat);
    reat = new RuleActionTemplate("simpleclosable", "open", 1, RuleActionTemplate::SelectionModeDevice);
    t->ruleExitActionTemplates()->addRuleActionTemplate(reat);
    m_list.append(t);

    t = new RuleTemplate("Leave home - This will turn of everything when you press a button.", "Leave home", this);
    evt = new EventDescriptorTemplate("button", "pressed", 0, EventDescriptorTemplate::SelectionModeDevice);
    t->eventDescriptorTemplates()->addEventDescriptorTemplate(evt);
    rat = new RuleActionTemplate("power", "power", 1, RuleActionTemplate::SelectionModeInterface);
    t->ruleActionTemplates()->addRuleActionTemplate(rat);
    m_list.append(t);


    t = new RuleTemplate("Remind me to water my plant", "Remind me to water my %0 plant",  this);
    evt = new EventDescriptorTemplate("humiditysensor", "humidity", 0, EventDescriptorTemplate::SelectionModeDevice);
    t->eventDescriptorTemplates()->addEventDescriptorTemplate(evt);
    m_list.append(t);

}

int RuleTemplates::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return m_list.count();
}

QVariant RuleTemplates::data(const QModelIndex &index, int role) const
{
    switch (role) {
    case RoleDescription:
        return m_list.at(index.row())->description();
    }
    return QVariant();
}

QHash<int, QByteArray> RuleTemplates::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles.insert(RoleDescription, "description");
    return roles;
}

RuleTemplate *RuleTemplates::get(int index) const
{
    if (index < 0 || index >= m_list.count()) {
        return nullptr;
    }
    return m_list.at(index);
}

bool RuleTemplatesFilterModel::filterAcceptsRow(int source_row, const QModelIndex &source_parent) const
{
    Q_UNUSED(source_parent)
    if (!m_ruleTemplates) {
        return false;
    }
    RuleTemplate *t = m_ruleTemplates->get(source_row);
    qDebug() << "---------------" << t->description() << m_filterInterfaceNames;
    if (!m_filterInterfaceNames.isEmpty()) {
        bool found = false;
        for (int i = 0; i < t->eventDescriptorTemplates()->rowCount(); i++) {
            if (m_filterInterfaceNames.contains(t->eventDescriptorTemplates()->get(i)->interfaceName())) {
                found = true;
                break;
            }
        }
        if (!found && t->stateEvaluatorTemplate() && stateEvaluatorTemplateContainsInterface(t->stateEvaluatorTemplate(), m_filterInterfaceNames)) {
            found = true;
        }
        if (!found) {
            for (int i = 0; i < t->ruleActionTemplates()->rowCount(); i++) {
                if (m_filterInterfaceNames.contains(t->ruleActionTemplates()->get(i)->interfaceName())) {
                    found = true;
                    break;
                }
            }
        }
        if (!found) {
            for (int i = 0; i < t->ruleExitActionTemplates()->rowCount(); i++) {
                if (m_filterInterfaceNames.contains(t->ruleExitActionTemplates()->get(i)->interfaceName())) {
                    found = true;
                    break;
                }
            }
        }
        if (!found) {
            return false;
        }
    }
    return true;
}

bool RuleTemplatesFilterModel::stateEvaluatorTemplateContainsInterface(StateEvaluatorTemplate *stateEvaluatorTemplate, const QStringList &interfaceNames) const
{
    if (interfaceNames.contains(stateEvaluatorTemplate->stateDescriptorTemplate()->interfaceName())) {
        return true;
    }
    for (int i = 0; i < stateEvaluatorTemplate->childEvaluatorTemplates()->rowCount(); i++) {
        if (stateEvaluatorTemplateContainsInterface(stateEvaluatorTemplate->childEvaluatorTemplates()->get(i), interfaceNames)) {
            return true;
        }
    }
    return false;
}

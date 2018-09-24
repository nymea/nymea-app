#include "ruletemplates.h"

#include "ruletemplate.h"
#include "eventdescriptortemplate.h"
#include "ruleactiontemplate.h"
#include "stateevaluatortemplate.h"

#include "types/ruleactionparam.h"
#include "types/ruleactionparams.h"

#include <QDebug>
#include <QDir>
#include <QJsonDocument>
#include <QMetaEnum>

RuleTemplates::RuleTemplates(QObject *parent) : QAbstractListModel(parent)
{

    RuleTemplate* t;
    EventDescriptorTemplate* evt;
    ParamDescriptor* evpt;
    StateEvaluatorTemplate* set;
    RuleActionTemplate* rat;
    RuleActionTemplate* reat; // exit
    RuleActionParams* raps;

    QDir ruleTemplatesDir(":/ruletemplates");

    foreach (const QString &templateFile, ruleTemplatesDir.entryList({"*.json"})) {
        qDebug() << "Loading rule template:" << ruleTemplatesDir.absoluteFilePath(templateFile);
        QFile f(ruleTemplatesDir.absoluteFilePath(templateFile));
        if (!f.open(QFile::ReadOnly)) {
            qWarning() << "Cannot open rule template file for reading:" << ruleTemplatesDir.absoluteFilePath(templateFile);
            continue;
        }
        QJsonParseError error;
        QJsonDocument jsonDoc = QJsonDocument::fromJson(f.readAll(), &error);
        f.close();
        if (error.error != QJsonParseError::NoError) {
            qWarning() << "Error reading rule template json from file:" << ruleTemplatesDir.absoluteFilePath(templateFile) << error.offset << error.errorString();
            continue;
        }
        foreach (const QVariant &ruleTemplateVariant, jsonDoc.toVariant().toMap().value("templates").toList()) {
            QVariantMap ruleTemplate = ruleTemplateVariant.toMap();

            // RuleTemplate base
            t = new RuleTemplate(ruleTemplate.value("interfaceName").toString(), ruleTemplate.value("description").toString(), ruleTemplate.value("ruleNameTemplate").toString(), this);

            // EventDescriptorTemplate
            foreach (const QVariant &eventDescriptorVariant, ruleTemplate.value("eventDescriptorTemplates").toList()) {
                QVariantMap eventDescriptorTemplate = eventDescriptorVariant.toMap();
                evt = new EventDescriptorTemplate(
                            eventDescriptorTemplate.value("interfaceName").toString(),
                            eventDescriptorTemplate.value("interfaceEvent").toString(),
                            eventDescriptorTemplate.value("selectionId").toInt(),
                            EventDescriptorTemplate::SelectionModeDevice);
                foreach (const QVariant &eventDescriptorParamVariant, eventDescriptorTemplate.value("params").toList()) {
                    QVariantMap eventDescriptorParamTemplate = eventDescriptorParamVariant.toMap();
                    evpt = new ParamDescriptor();
                    evpt->setParamName(eventDescriptorParamTemplate.value("name").toString());
                    if (eventDescriptorParamTemplate.contains("value")) {
                        evpt->setValue(eventDescriptorParamTemplate.value("value"));
                    }
                    evt->paramDescriptors()->addParamDescriptor(evpt);
                }
                t->eventDescriptorTemplates()->addEventDescriptorTemplate(evt);
            }

            // StateEvaluatorTemplate
            if (ruleTemplate.contains("stateEvaluatorTemplate")) {
                QVariantMap stateEvaluatorTemplate = ruleTemplate.value("stateEvaluatorTemplate").toMap();
                QVariantMap stateDescriptorTemplate = stateEvaluatorTemplate.value("stateDescriptorTemplate").toMap();
                QMetaEnum selectionModeEnum = QMetaEnum::fromType<StateDescriptorTemplate::SelectionMode>();
                QMetaEnum operatorEnum = QMetaEnum::fromType<StateDescriptorTemplate::ValueOperator>();
                set = new StateEvaluatorTemplate(
                            new StateDescriptorTemplate(
                                stateDescriptorTemplate.value("interfaceName").toString(),
                                stateDescriptorTemplate.value("interfaceState").toString(),
                                stateDescriptorTemplate.value("selectionId").toInt(),
                                static_cast<StateDescriptorTemplate::SelectionMode>(selectionModeEnum.keyToValue(stateDescriptorTemplate.value("selectionMode", "SelectionModeAny").toByteArray().data())),
                                static_cast<StateDescriptorTemplate::ValueOperator>(operatorEnum.keyToValue(stateDescriptorTemplate.value("operator").toByteArray().data())),
                                stateDescriptorTemplate.value("value")));
                t->setStateEvaluatorTemplate(set);
                // TODO: Child evaluators not supported yet
            }

            // RuleActionTemplates
            foreach (const QVariant &ruleActionVariant, ruleTemplate.value("ruleActionTemplates").toList()) {
                QVariantMap ruleActionTemplate = ruleActionVariant.toMap();
                raps = new RuleActionParams();
                foreach (const QVariant &ruleActionParamVariant, ruleActionTemplate.value("params").toList()) {
                    QVariantMap ruleActionParamTemplate = ruleActionParamVariant.toMap();
                    raps->addRuleActionParam(new RuleActionParam(ruleActionParamTemplate.value("name").toString(), ruleActionParamTemplate.value("value")));
                }
                QMetaEnum selectionModeEnum = QMetaEnum::fromType<RuleActionTemplate::SelectionMode>();
                rat = new RuleActionTemplate(
                            ruleActionTemplate.value("interfaceName").toString(),
                            ruleActionTemplate.value("interfaceAction").toString(),
                            ruleActionTemplate.value("selectionId").toInt(),
                            static_cast<RuleActionTemplate::SelectionMode>(selectionModeEnum.keyToValue(ruleActionTemplate.value("selectionMode", "SelectionModeDevice").toByteArray().data())),
                            raps);
                t->ruleActionTemplates()->addRuleActionTemplate(rat);
            }

            // RuleExitActionTemplates
            foreach (const QVariant &ruleActionVariant, ruleTemplate.value("ruleExitActionTemplates").toList()) {
                QVariantMap ruleActionTemplate = ruleActionVariant.toMap();
                raps = new RuleActionParams();
                foreach (const QVariant &ruleActionParamVariant, ruleActionTemplate.value("params").toList()) {
                    QVariantMap ruleActionParamTemplate = ruleActionParamVariant.toMap();
                    raps->addRuleActionParam(new RuleActionParam(ruleActionParamTemplate.value("name").toString(), ruleActionParamTemplate.value("value")));
                }
                QMetaEnum selectionModeEnum = QMetaEnum::fromType<RuleActionTemplate::SelectionMode>();
                rat = new RuleActionTemplate(
                            ruleActionTemplate.value("interfaceName").toString(),
                            ruleActionTemplate.value("interfaceAction").toString(),
                            ruleActionTemplate.value("selectionId").toInt(),
                            static_cast<RuleActionTemplate::SelectionMode>(selectionModeEnum.keyToValue(ruleActionTemplate.value("selectionMode", "SelectionModeDevice").toByteArray().data())),
                            raps);
                t->ruleExitActionTemplates()->addRuleActionTemplate(rat);
            }

            qDebug() << "Added rule template:" << t->ruleActionTemplates()->rowCount();
            m_list.append(t);
        }
    }
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
    qDebug() << "Checking interface" << t->description() << t->interfaceName() << "for usage with:" << m_filterInterfaceNames;
    if (!m_filterInterfaceNames.isEmpty()) {
        if (!m_filterInterfaceNames.contains(t->interfaceName())) {
            return false;
        }
//        bool found = false;
//        for (int i = 0; i < t->eventDescriptorTemplates()->rowCount(); i++) {
//            if (m_filterInterfaceNames.contains(t->eventDescriptorTemplates()->get(i)->interfaceName())) {
//                found = true;
//                break;
//            }
//        }
//        if (!found && t->stateEvaluatorTemplate() && stateEvaluatorTemplateContainsInterface(t->stateEvaluatorTemplate(), m_filterInterfaceNames)) {
//            found = true;
//        }
//        if (!found) {
//            for (int i = 0; i < t->ruleActionTemplates()->rowCount(); i++) {
//                if (m_filterInterfaceNames.contains(t->ruleActionTemplates()->get(i)->interfaceName())) {
//                    found = true;
//                    break;
//                }
//            }
//        }
//        if (!found) {
//            for (int i = 0; i < t->ruleExitActionTemplates()->rowCount(); i++) {
//                if (m_filterInterfaceNames.contains(t->ruleExitActionTemplates()->get(i)->interfaceName())) {
//                    found = true;
//                    break;
//                }
//            }
//        }
//        if (!found) {
//            return false;
//        }
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

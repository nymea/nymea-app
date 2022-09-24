/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
* Copyright 2013 - 2020, nymea GmbH
* Contact: contact@nymea.io
*
* This file is part of nymea.
* This project including source code and documentation is protected by
* copyright law, and remains the property of nymea GmbH. All rights, including
* reproduction, publication, editing and translation, are reserved. The use of
* this project is subject to the terms of a license agreement to be concluded
* with nymea GmbH in accordance with the terms of use of nymea GmbH, available
* under https://nymea.io/license
*
* GNU General Public License Usage
* Alternatively, this project may be redistributed and/or modified under the
* terms of the GNU General Public License as published by the Free Software
* Foundation, GNU version 3. This project is distributed in the hope that it
* will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty
* of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
* Public License for more details.
*
* You should have received a copy of the GNU General Public License along with
* this project. If not, see <https://www.gnu.org/licenses/>.
*
* For any further details and any questions please contact us under
* contact@nymea.io or see our FAQ/Licensing Information on
* https://nymea.io/license/faq
*
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#include "ruletemplates.h"

#include "ruletemplate.h"
#include "eventdescriptortemplate.h"
#include "timedescriptortemplate.h"
#include "calendaritemtemplate.h"
#include "timeeventitemtemplate.h"
#include "ruleactiontemplate.h"
#include "stateevaluatortemplate.h"
#include "ruleactionparamtemplate.h"

#include "types/ruleactionparam.h"
#include "types/ruleactionparams.h"
#include "types/repeatingoption.h"
#include "thingsproxy.h"

#include <QDebug>
#include <QDir>
#include <QJsonDocument>
#include <QMetaEnum>
#include <QCoreApplication>

Q_DECLARE_LOGGING_CATEGORY(dcRuleManager)

RuleTemplates::RuleTemplates(QObject *parent) : QAbstractListModel(parent)
{

    RuleTemplate* t;
    EventDescriptorTemplate* evt;
    ParamDescriptor* evpt;
    RuleActionTemplate* rat;
    RuleActionParamTemplates* rapts;

    QDir ruleTemplatesDir(":/ruletemplates");

    foreach (const QString &templateFile, ruleTemplatesDir.entryList({"*.json"})) {
        qCDebug(dcRuleManager()) << "Loading rule template:" << ruleTemplatesDir.absoluteFilePath(templateFile);
        QFile f(ruleTemplatesDir.absoluteFilePath(templateFile));
        if (!f.open(QFile::ReadOnly)) {
            qCWarning(dcRuleManager()) << "Cannot open rule template file for reading:" << ruleTemplatesDir.absoluteFilePath(templateFile);
            continue;
        }
        QJsonParseError error;
        QJsonDocument jsonDoc = QJsonDocument::fromJson(f.readAll(), &error);
        f.close();
        if (error.error != QJsonParseError::NoError) {
            qCWarning(dcRuleManager()) << "Error reading rule template json from file:" << ruleTemplatesDir.absoluteFilePath(templateFile) << error.offset << error.errorString();
            continue;
        }
        foreach (const QVariant &ruleTemplateVariant, jsonDoc.toVariant().toMap().value("templates").toList()) {
            QVariantMap ruleTemplate = ruleTemplateVariant.toMap();

            // RuleTemplate base
            QString descriptionContext = QString("description for %0").arg(QFileInfo(templateFile).baseName());
            QString nameTemplateContext = QString("ruleNameTemplate for %0").arg(QFileInfo(templateFile).baseName());
            t = new RuleTemplate(ruleTemplate.value("interfaceName").toString(),
                                 qApp->translate(descriptionContext.toUtf8(), ruleTemplate.value("description").toByteArray()),
                                 qApp->translate(nameTemplateContext.toUtf8(), ruleTemplate.value("ruleNameTemplate").toByteArray()),
                                 this);
            qCDebug(dcRuleManager()) << "Loading rule template" << ruleTemplate.value("description").toString() << tr(ruleTemplate.value("description").toByteArray());

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
                        if (!eventDescriptorParamTemplate.contains("operator")) {
                            qWarning() << "BROKEN Template: Operator missing for event descriptor template" << qUtf8Printable(QJsonDocument::fromVariant(eventDescriptorParamTemplate).toJson(QJsonDocument::Indented));
                        } else {
                            QMetaEnum operatorEnum = QMetaEnum::fromType<ParamDescriptor::ValueOperator>();
                            evpt->setOperatorType(static_cast<ParamDescriptor::ValueOperator>(operatorEnum.keyToValue(eventDescriptorParamTemplate.value("operator").toByteArray().data())));
                        }
                    }
                    evt->paramDescriptors()->addParamDescriptor(evpt);
                }
                t->eventDescriptorTemplates()->addEventDescriptorTemplate(evt);
            }

            // StateEvaluatorTemplate
            if (ruleTemplate.contains("stateEvaluatorTemplate")) {
                t->setStateEvaluatorTemplate(loadStateEvaluatorTemplate(ruleTemplate.value("stateEvaluatorTemplate").toMap()));
            }

            // TimeDescriptorTemplate
            if (ruleTemplate.contains("timeDescriptorTemplate")) {

                t->setTimeDescriptorTemplate(loadTimeDescriptorTemplate(ruleTemplate.value("timeDescriptorTemplate").toMap()));
            }

            // RuleActionTemplates
            foreach (const QVariant &ruleActionVariant, ruleTemplate.value("ruleActionTemplates").toList()) {
                QVariantMap ruleActionTemplate = ruleActionVariant.toMap();
                rapts = new RuleActionParamTemplates();
                foreach (const QVariant &ruleActionParamVariant, ruleActionTemplate.value("params").toList()) {
                    QVariantMap ruleActionParamTemplate = ruleActionParamVariant.toMap();
                    QString paramName = ruleActionParamTemplate.value("name").toString();
                    if (ruleActionParamTemplate.contains("value")) {
                        QVariant paramValue = ruleActionParamTemplate.value("value");
                        rapts->addRuleActionParamTemplate(new RuleActionParamTemplate(paramName, paramValue));
                    } else if (ruleActionParamTemplate.contains("eventInterface") && ruleActionParamTemplate.contains("eventName") && ruleActionParamTemplate.contains("eventParamName")) {
                        QString eventInterface = ruleActionParamTemplate.value("eventInterface").toString();
                        QString eventName = ruleActionParamTemplate.value("eventName").toString();
                        QString eventParamName = ruleActionParamTemplate.value("eventParamName").toString();
                        rapts->addRuleActionParamTemplate(new RuleActionParamTemplate(paramName, eventInterface, eventName, eventParamName));
                    } else {
                        qCWarning(dcRuleManager()) << "Invalid rule action param name on rule template:" << paramName;
                    }
                }
                QMetaEnum selectionModeEnum = QMetaEnum::fromType<RuleActionTemplate::SelectionMode>();
                rat = new RuleActionTemplate(
                            ruleActionTemplate.value("interfaceName").toString(),
                            ruleActionTemplate.value("interfaceAction").toString(),
                            ruleActionTemplate.value("selectionId").toInt(),
                            static_cast<RuleActionTemplate::SelectionMode>(selectionModeEnum.keyToValue(ruleActionTemplate.value("selectionMode", "SelectionModeDevice").toByteArray().data())),
                            rapts);
                t->ruleActionTemplates()->addRuleActionTemplate(rat);
            }

            // RuleExitActionTemplates
            foreach (const QVariant &ruleActionVariant, ruleTemplate.value("ruleExitActionTemplates").toList()) {
                QVariantMap ruleActionTemplate = ruleActionVariant.toMap();
                rapts = new RuleActionParamTemplates();
                foreach (const QVariant &ruleActionParamVariant, ruleActionTemplate.value("params").toList()) {
                    QVariantMap ruleActionParamTemplate = ruleActionParamVariant.toMap();
                    QString paramName = ruleActionParamTemplate.value("name").toString();
                    if (ruleActionParamTemplate.contains("value")) {
                        QVariant paramValue = ruleActionParamTemplate.value("value");
                        rapts->addRuleActionParamTemplate(new RuleActionParamTemplate(paramName, paramValue));
                    } else if (ruleActionParamTemplate.contains("eventInterface") && ruleActionParamTemplate.contains("eventName") && ruleActionParamTemplate.contains("eventParamName")) {
                        QString eventInterface = ruleActionParamTemplate.value("eventInterface").toString();
                        QString eventName = ruleActionParamTemplate.value("eventName").toString();
                        QString eventParamName = ruleActionParamTemplate.value("eventParamName").toString();
                        rapts->addRuleActionParamTemplate(new RuleActionParamTemplate(paramName, eventInterface, eventName, eventParamName));
                    } else {
                        qCWarning(dcRuleManager()) << "Invalid rule exit action param name on rule template:" << paramName;
                    }
                }
                QMetaEnum selectionModeEnum = QMetaEnum::fromType<RuleActionTemplate::SelectionMode>();
                rat = new RuleActionTemplate(
                            ruleActionTemplate.value("interfaceName").toString(),
                            ruleActionTemplate.value("interfaceAction").toString(),
                            ruleActionTemplate.value("selectionId").toInt(),
                            static_cast<RuleActionTemplate::SelectionMode>(selectionModeEnum.keyToValue(ruleActionTemplate.value("selectionMode", "SelectionModeDevice").toByteArray().data())),
                            rapts);
                t->ruleExitActionTemplates()->addRuleActionTemplate(rat);
            }

            m_list.append(t);
        }
        qCDebug(dcRuleManager()) << "Loaded" << m_list.count() << "rule templates";
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
    case RoleInterfaces:
        return m_list.at(index.row())->interfaces();
    }
    return QVariant();
}

QHash<int, QByteArray> RuleTemplates::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles.insert(RoleDescription, "description");
    roles.insert(RoleInterfaces, "interfaces");
    return roles;
}

RuleTemplate *RuleTemplates::get(int index) const
{
    if (index < 0 || index >= m_list.count()) {
        return nullptr;
    }
    return m_list.at(index);
}

StateEvaluatorTemplate *RuleTemplates::loadStateEvaluatorTemplate(const QVariantMap &stateEvaluatorTemplate) const
{
    QVariantMap stateDescriptorTemplate = stateEvaluatorTemplate.value("stateDescriptorTemplate").toMap();
    QMetaEnum selectionModeEnum = QMetaEnum::fromType<StateDescriptorTemplate::SelectionMode>();
    QMetaEnum stateOperatorEnum = QMetaEnum::fromType<StateEvaluatorTemplate::StateOperator>();
    QMetaEnum valueOperatorEnum = QMetaEnum::fromType<StateDescriptorTemplate::ValueOperator>();
    StateEvaluatorTemplate::StateOperator stateOperator = StateEvaluatorTemplate::StateOperatorAnd;
    if (stateEvaluatorTemplate.contains("stateOperatorTemplate")) {
        stateOperator = static_cast<StateEvaluatorTemplate::StateOperator>(stateOperatorEnum.keyToValue(stateEvaluatorTemplate.value("stateOperatorTemplate").toByteArray().data()));
    }

    StateEvaluatorTemplate *set = new StateEvaluatorTemplate(
                new StateDescriptorTemplate(
                    stateDescriptorTemplate.value("interfaceName").toString(),
                    stateDescriptorTemplate.value("interfaceState").toString(),
                    stateDescriptorTemplate.value("selectionId").toInt(),
                    static_cast<StateDescriptorTemplate::SelectionMode>(selectionModeEnum.keyToValue(stateDescriptorTemplate.value("selectionMode", "SelectionModeAny").toByteArray().data())),
                    static_cast<StateDescriptorTemplate::ValueOperator>(valueOperatorEnum.keyToValue(stateDescriptorTemplate.value("operator").toByteArray().data())),
                    stateDescriptorTemplate.value("value")),
                stateOperator
                );
    foreach (const QVariant &childVariant, stateEvaluatorTemplate.value("childEvaluatorTemplates").toList()) {
        QVariantMap childMap = childVariant.toMap();
        set->childEvaluatorTemplates()->addStateEvaluatorTemplate(loadStateEvaluatorTemplate(childMap.value("stateEvaluatorTemplate").toMap()));
    }

    return set;
}

TimeDescriptorTemplate *RuleTemplates::loadTimeDescriptorTemplate(const QVariantMap &timeDescriptorTemplate) const
{
    TimeDescriptorTemplate *tdt = new TimeDescriptorTemplate();
    foreach (const QVariant &childVariant, timeDescriptorTemplate.value("calendarItemTemplates").toList()) {
        QVariantMap childMap = childVariant.toMap();

        int duration = childMap.value("duration").toInt();
        QDateTime dateTime = childMap.value("dateTime").toDateTime();
        QTime startTime = childMap.value("startTime").toTime();
        bool editable = childMap.value("editable", true).toBool();
        RepeatingOption *repeatingOption = loadRepeatingOption(childMap.value("repeatingOption").toMap());
        CalendarItemTemplate *cit = new CalendarItemTemplate(duration, dateTime, startTime, repeatingOption, editable, tdt);
        tdt->calendarItemTemplates()->addCalendarItemTemplate(cit);
    }
    foreach (const QVariant &childVariant, timeDescriptorTemplate.value("timeEventItemTemplates").toList()) {
        QVariantMap childMap = childVariant.toMap();
        QDateTime dateTime = childMap.value("dateTime").toDateTime();
        QTime time = childMap.value("time").toTime();
        bool editable = childMap.value("editable", true).toBool();
        RepeatingOption *repeatingOption = loadRepeatingOption(childMap.value("repeatingOption").toMap());
        TimeEventItemTemplate *teit = new TimeEventItemTemplate(dateTime, time, repeatingOption, editable, tdt);
        tdt->timeEventItemTemplates()->addTimeEventItemTemplate(teit);
    }
    return tdt;
}

RepeatingOption *RuleTemplates::loadRepeatingOption(const QVariantMap &repeatingOptionMap) const
{
    RepeatingOption *repeatingOption = new RepeatingOption();
    repeatingOption->setWeekDays(repeatingOptionMap.value("weekDays").toList());
    repeatingOption->setMonthDays(repeatingOptionMap.value("monthDays").toList());
    QMetaEnum repeatingModeEnum = QMetaEnum::fromType<RepeatingOption::RepeatingMode>();
    repeatingOption->setRepeatingMode(static_cast<RepeatingOption::RepeatingMode>(repeatingModeEnum.keyToValue(repeatingOptionMap.value("repeatingMode").toString().toUtf8().data())));
    return repeatingOption;
}

void RuleTemplatesFilterModel::setFilterByThings(ThingsProxy *filterThingsProxy)
{
    if (m_filterThingsProxy !=  filterThingsProxy) {
        m_filterThingsProxy = filterThingsProxy;
        emit filterByThingsChanged(); invalidateFilter();

        qCDebug(dcRuleManager()) << "Setting things proxy:" << filterThingsProxy->rowCount();
        connect(m_filterThingsProxy, &ThingsProxy::countChanged, this, [this](){
            qCDebug(dcRuleManager()) << "proxy count hcanged";
            invalidateFilter();
        });
    }
}

bool RuleTemplatesFilterModel::filterAcceptsRow(int source_row, const QModelIndex &source_parent) const
{
    Q_UNUSED(source_parent)
    if (!m_ruleTemplates) {
        return false;
    }
    RuleTemplate *t = m_ruleTemplates->get(source_row);
//    qDebug() << "Checking interface" << t->description() << t->interfaces() << "for usage with:" << m_filterInterfaceNames;


    // Make sure we have all the things to satisfy all of the templates events/states/actions
    if (m_filterThingsProxy && !thingsSatisfyRuleTemplate(t, m_filterThingsProxy)) {
        qDebug() << "Filtering out" << t->description() << "because required no thing in the provided filter proxy satisfies definitions";
        return false;
    }

    if (!m_filterInterfaceNames.isEmpty()) {
        bool found = false;
        foreach (const QString toBeFound, m_filterInterfaceNames) {
            if (t->interfaces().contains(toBeFound)) {
                found = true;
                break;
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

bool RuleTemplatesFilterModel::thingsSatisfyRuleTemplate(RuleTemplate *ruleTemplate, ThingsProxy *things) const
{
    // For improved performance it would be better to just cycle things once and flag satisfied states/events/actions
    // instead of looping over all things for every entry, but for the amount of templates we have right now
    // this is good enough. If needed, here's low hanging fruit to collect...

    // First check if all interfaces are around
    foreach (const QString &interfaceName, ruleTemplate->interfaces()) {
        bool haveThing = false;
        for (int i = 0; i < things->rowCount(); i++) {
            Thing *thing = things->get(i);
            if (thing->thingClass()->interfaces().contains(interfaceName)) {
                haveThing = true;
                break;
            }
        }
        if (!haveThing) {
            qCDebug(dcRuleManager()) << "No thing to satisfy interface" << interfaceName << things->rowCount();
            return false;
        }
    }

    // Given optional states/actions/events in interfaces, we also need to check for them
    for (int i = 0; i < ruleTemplate->eventDescriptorTemplates()->rowCount(); i++) {
        EventDescriptorTemplate *eventDescriptorTemplate = ruleTemplate->eventDescriptorTemplates()->get(i);
        bool haveThing = false;
        for (int j = 0; j < things->rowCount(); j++) {
            Thing *thing = things->get(j);
            if (thing->thingClass()->eventTypes()->findByName(eventDescriptorTemplate->eventName())) {
                haveThing = true;
                break;
            }
        }
        if (!haveThing) {
            qCDebug(dcRuleManager()) << "No thing to satisfy event" << eventDescriptorTemplate->eventName();
            return false;
        }
    }

    if (ruleTemplate->stateEvaluatorTemplate() && !thingsSatisfyStateEvaluatorTemplate(ruleTemplate->stateEvaluatorTemplate(), things)) {
        qCDebug(dcRuleManager()) << "No thing to satisfy state evaluator template";
        return false;
    }

    for (int i = 0; i < ruleTemplate->ruleActionTemplates()->rowCount(); i++) {
        RuleActionTemplate *ruleActionTemplate = ruleTemplate->ruleActionTemplates()->get(i);
        bool haveThing = false;
        for (int j = 0; j < things->rowCount(); j++) {
            Thing *thing = things->get(j);
            if (thing->thingClass()->actionTypes()->findByName(ruleActionTemplate->actionName())) {
                haveThing = true;
                break;
            }
        }
        if (!haveThing) {
            qCDebug(dcRuleManager()) << "No thing to satisfy action" << ruleActionTemplate->actionName();
            return false;
        }
    }

    for (int i = 0; i < ruleTemplate->ruleExitActionTemplates()->rowCount(); i++) {
        RuleActionTemplate *ruleExitActionTemplate = ruleTemplate->ruleExitActionTemplates()->get(i);
        bool haveThing = false;
        for (int j = 0; j < things->rowCount(); j++) {
            Thing *thing = things->get(j);
            if (thing->thingClass()->actionTypes()->findByName(ruleExitActionTemplate->actionName())) {
                haveThing = true;
                break;
            }
        }
        if (!haveThing) {
            qCDebug(dcRuleManager()) << "No thing to satisfy exit action" << ruleExitActionTemplate->actionName();
            return false;
        }
    }

    return true;
}

bool RuleTemplatesFilterModel::thingsSatisfyStateEvaluatorTemplate(StateEvaluatorTemplate *stateEvaluatorTemplate, ThingsProxy *things) const
{
    if (stateEvaluatorTemplate->stateDescriptorTemplate()) {
        bool haveThing = false;
        for (int i = 0; i < things->rowCount(); i++) {
            Thing *thing = things->get(i);
            if (thing->thingClass()->stateTypes()->findByName(stateEvaluatorTemplate->stateDescriptorTemplate()->stateName())) {
                haveThing = true;
                break;
            }
        }
        if (!haveThing) {
            return false;
        }
    }

    for (int i = 0; i < stateEvaluatorTemplate->childEvaluatorTemplates()->rowCount(); i++) {
        StateEvaluatorTemplate *childEvaluatorTemplate = stateEvaluatorTemplate->childEvaluatorTemplates()->get(i);
        if (!thingsSatisfyStateEvaluatorTemplate(childEvaluatorTemplate, things)) {
            return false;
        }
    }
    return true;
}

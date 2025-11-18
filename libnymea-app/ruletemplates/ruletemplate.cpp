// SPDX-License-Identifier: LGPL-3.0-or-later

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
* Copyright (C) 2013 - 2024, nymea GmbH
* Copyright (C) 2024 - 2025, chargebyte austria GmbH
*
* This file is part of libnymea-app.
*
* libnymea-app is free software: you can redistribute it and/or
* modify it under the terms of the GNU Lesser General Public License
* as published by the Free Software Foundation, either version 3
* of the License, or (at your option) any later version.
*
* libnymea-app is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
* GNU Lesser General Public License for more details.
*
* You should have received a copy of the GNU Lesser General Public License
* along with libnymea-app. If not, see <https://www.gnu.org/licenses/>.
*
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#include "ruletemplate.h"
#include "eventdescriptortemplate.h"
#include "timedescriptortemplate.h"
#include "stateevaluatortemplate.h"
#include "ruleactiontemplate.h"

RuleTemplate::RuleTemplate(const QString &interfaceName, const QString &description, const QString &ruleNameTemplate, QObject *parent):
    QObject(parent),
    m_interfaceName(interfaceName),
    m_description(description),
    m_ruleNameTemplate(ruleNameTemplate),
    m_eventDescriptorTemplates(new EventDescriptorTemplates(this)),
    m_ruleActionTemplates(new RuleActionTemplates(this)),
    m_ruleExitActionTemplates(new RuleActionTemplates(this))
{
}

QString RuleTemplate::description() const
{
    return m_description;
}

QString RuleTemplate::ruleNameTemplate() const
{
    return m_ruleNameTemplate;
}

QStringList RuleTemplate::interfaces() const
{
    QStringList ret;
    ret.append(m_eventDescriptorTemplates->interfaces());
    if (m_stateEvaluatorTemplate) {
        ret.append(m_stateEvaluatorTemplate->interfaces());
    }
    ret.append(m_ruleActionTemplates->interfaces());
    ret.append(m_ruleExitActionTemplates->interfaces());
    return ret;
}

EventDescriptorTemplates *RuleTemplate::eventDescriptorTemplates() const
{
    return m_eventDescriptorTemplates;
}

StateEvaluatorTemplate *RuleTemplate::stateEvaluatorTemplate() const
{
    return m_stateEvaluatorTemplate;
}

void RuleTemplate::setStateEvaluatorTemplate(StateEvaluatorTemplate *stateEvaluatorTemplate)
{
    if (m_stateEvaluatorTemplate) {
        m_stateEvaluatorTemplate->deleteLater();
    }
    stateEvaluatorTemplate->setParent(this);
    m_stateEvaluatorTemplate = stateEvaluatorTemplate;
}

TimeDescriptorTemplate *RuleTemplate::timeDescriptorTemplate() const
{
    return m_timeDescriptorTemplate;
}

void RuleTemplate::setTimeDescriptorTemplate(TimeDescriptorTemplate *timeDescriptorTemplate)
{
    if (m_timeDescriptorTemplate) {
        m_timeDescriptorTemplate->deleteLater();
    }
    timeDescriptorTemplate->setParent(this);
    m_timeDescriptorTemplate = timeDescriptorTemplate;
}

RuleActionTemplates *RuleTemplate::ruleActionTemplates() const
{
    return m_ruleActionTemplates;
}

RuleActionTemplates *RuleTemplate::ruleExitActionTemplates() const
{
    return m_ruleExitActionTemplates;
}

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

#include "ruletemplate.h"
#include "eventdescriptortemplate.h"
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

RuleActionTemplates *RuleTemplate::ruleActionTemplates() const
{
    return m_ruleActionTemplates;
}

RuleActionTemplates *RuleTemplate::ruleExitActionTemplates() const
{
    return m_ruleExitActionTemplates;
}

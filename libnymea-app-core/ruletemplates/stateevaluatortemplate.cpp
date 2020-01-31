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

QStringList StateEvaluatorTemplate::interfaces() const
{
    QStringList ret;

    if (m_stateDescriptorTemplate) {
        ret.append(stateDescriptorTemplate()->interfaceName());
    }

    for (int i = 0; i < m_childEvaluatorTemplates->rowCount(); i++) {
        ret.append(m_childEvaluatorTemplates->get(i)->interfaces());
    }

    ret.removeDuplicates();
    return ret;
}

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

#include "ruleactiontemplate.h"
#include "ruleactionparamtemplate.h"

RuleActionTemplate::RuleActionTemplate(const QString &interfaceName, const QString &actionName, int selectionId, RuleActionTemplate::SelectionMode selectionMode, RuleActionParamTemplates *params, QObject *parent):
    QObject(parent),
    m_interfaceName(interfaceName),
    m_actionName(actionName),
    m_selectionId(selectionId),
    m_selectionMode(selectionMode),
    m_ruleActionParamTemplates(params ? params : new RuleActionParamTemplates())
{
    m_ruleActionParamTemplates->setParent(this);
}

QString RuleActionTemplate::interfaceName() const
{
    return m_interfaceName;
}

QString RuleActionTemplate::actionName() const
{
    return m_actionName;
}

int RuleActionTemplate::selectionId() const
{
    return m_selectionId;
}

RuleActionTemplate::SelectionMode RuleActionTemplate::selectionMode() const
{
    return m_selectionMode;
}

RuleActionParamTemplates *RuleActionTemplate::ruleActionParamTemplates() const
{
    return m_ruleActionParamTemplates;
}

QStringList RuleActionTemplates::interfaces() const
{
    QStringList ret;
    for (int i = 0; i < m_list.count(); i++) {
        ret.append(m_list.at(i)->interfaceName());
    }
    ret.removeDuplicates();
    return ret;
}

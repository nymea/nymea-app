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

#include "ruleaction.h"

#include "ruleactionparam.h"
#include "ruleactionparams.h"

#include <QDebug>

RuleAction::RuleAction(QObject *parent) : QObject(parent)
{
    m_ruleActionParams = new RuleActionParams(this);
}

QUuid RuleAction::thingId() const
{
    return m_thingId;
}

void RuleAction::setThingId(const QUuid &thingId)
{
    if (m_thingId != thingId) {
        m_thingId = thingId;
        emit thingIdChanged();
    }
}

QUuid RuleAction::actionTypeId() const
{
    return m_actionTypeId;
}

void RuleAction::setActionTypeId(const QUuid &actionTypeId)
{
    if (m_actionTypeId != actionTypeId) {
        m_actionTypeId = actionTypeId;
        emit actionTypeIdChanged();
    }
}

QString RuleAction::interfaceName() const
{
    return m_interfaceName;
}

void RuleAction::setInterfaceName(const QString &interfaceName)
{
    if (m_interfaceName != interfaceName) {
        m_interfaceName = interfaceName;
        emit interfaceNameChanged();
    }
}

QString RuleAction::interfaceAction() const
{
    return m_interfaceAction;
}

void RuleAction::setInterfaceAction(const QString &interfaceAction)
{
    if (m_interfaceAction != interfaceAction) {
        m_interfaceAction = interfaceAction;
        emit interfaceActionChanged();
    }
}

QString RuleAction::browserItemId() const
{
    return m_browserItemId;
}

void RuleAction::setBrowserItemId(const QString &browserItemId)
{
    if (m_browserItemId != browserItemId) {
        m_browserItemId = browserItemId;
        emit browserItemIdChanged();
    }
}

RuleActionParams *RuleAction::ruleActionParams() const
{
    return m_ruleActionParams;
}

RuleAction *RuleAction::clone() const
{
    RuleAction *ret = new RuleAction();
    ret->setThingId(thingId());
    ret->setActionTypeId(actionTypeId());
    ret->setBrowserItemId(browserItemId());
    ret->setInterfaceName(interfaceName());
    ret->setInterfaceAction(interfaceAction());
    for (int i = 0; i < ruleActionParams()->rowCount(); i++) {
        ret->ruleActionParams()->addRuleActionParam(ruleActionParams()->get(i)->clone());
    }
    return ret;
}

#define COMPARE(a, b) if (a != b) { qDebug() << a << "!=" << b; return false; }
#define COMPARE_PTR(a, b) if (!a->operator==(b)) { qDebug() << a << "!=" << b; return false; }
bool RuleAction::operator==(RuleAction *other) const
{
    COMPARE(m_thingId, other->thingId());
    COMPARE(m_actionTypeId, other->actionTypeId());
    COMPARE(m_interfaceName, other->interfaceName());
    COMPARE(m_interfaceAction, other->interfaceAction());
    COMPARE(m_browserItemId, other->browserItemId());
    COMPARE_PTR(m_ruleActionParams, other->ruleActionParams());
    return true;
}

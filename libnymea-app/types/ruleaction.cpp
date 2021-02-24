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

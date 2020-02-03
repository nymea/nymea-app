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

#include "ruleactionparamtemplate.h"

RuleActionParamTemplate::RuleActionParamTemplate(const QString &paramName, const QVariant &value, QObject *parent):
    RuleActionParam(paramName, value, parent)
{

}

RuleActionParamTemplate::RuleActionParamTemplate(const QString &paramName, const QString &eventInterface, const QString &eventName, const QString &eventParamName, QObject *parent):
    RuleActionParam(parent),
    m_eventInterface(eventInterface),
    m_eventName(eventName),
    m_eventParamName(eventParamName)
{
    setParamName(paramName);
}

RuleActionParamTemplate::RuleActionParamTemplate(QObject *parent) : RuleActionParam(parent)
{

}

QString RuleActionParamTemplate::eventInterface() const
{
    return m_eventInterface;
}

void RuleActionParamTemplate::setEventInterface(const QString &eventInterface)
{
    m_eventInterface = eventInterface;
}

QString RuleActionParamTemplate::eventName() const
{
    return m_eventName;
}

void RuleActionParamTemplate::setEventName(const QString &eventName)
{
    m_eventName = eventName;
}

QString RuleActionParamTemplate::eventParamName() const
{
    return m_eventParamName;
}

void RuleActionParamTemplate::setEventParamName(const QString &eventParamName)
{
    m_eventParamName = eventParamName;
}

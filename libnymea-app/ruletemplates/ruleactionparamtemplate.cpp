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

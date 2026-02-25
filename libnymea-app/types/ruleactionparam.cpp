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

#include "ruleactionparam.h"

#include <QDebug>

RuleActionParam::RuleActionParam(const QString &paramName, const QVariant &value, QObject *parent):
    Param(parent),
    m_paramName(paramName)
{
    setValue(value);

    connect(this, &Param::valueChanged, this, &RuleActionParam::isValueBasedChanged);
}

RuleActionParam::RuleActionParam(QObject *parent) : Param(parent)
{

}

QString RuleActionParam::paramName() const
{
    return m_paramName;
}

void RuleActionParam::setParamName(const QString &paramName)
{
    if (m_paramName != paramName) {
        m_paramName = paramName;
        emit paramNameChanged();
    }
}

QString RuleActionParam::eventTypeId() const
{
    return m_eventTypeId;
}

void RuleActionParam::setEventTypeId(const QString &eventTypeId)
{
    if (m_eventTypeId != eventTypeId) {
        m_eventTypeId = eventTypeId;
        emit eventTypeIdChanged();
        emit isEventParamBasedChanged();
    }
}

QString RuleActionParam::eventParamTypeId() const
{
    return m_eventParamTypeId;
}

void RuleActionParam::setEventParamTypeId(const QString &eventParamTypeId)
{
    if (m_eventParamTypeId != eventParamTypeId) {
        m_eventParamTypeId = eventParamTypeId;
        emit eventParamTypeIdChanged();
        emit isEventParamBasedChanged();
    }
}

QString RuleActionParam::stateThingId() const
{
    return m_stateThingId;
}

void RuleActionParam::setStateThingId(const QString &stateThingId)
{
    if (m_stateThingId != stateThingId) {
        m_stateThingId = stateThingId;
        emit stateThingIdChanged();
        emit isStateValueBasedChanged();
    }
}

QString RuleActionParam::stateTypeId() const
{
    return m_stateTypeId;
}

void RuleActionParam::setStateTypeId(const QString &stateTypeId)
{
    if (m_stateTypeId != stateTypeId) {
        m_stateTypeId = stateTypeId;
        emit stateTypeIdChanged();
        emit isStateValueBasedChanged();
    }
}

bool RuleActionParam::isValueBased() const
{
    return !m_value.isNull();
}

bool RuleActionParam::isEventParamBased() const
{
    return !m_eventTypeId.isNull() && !m_eventParamTypeId.isNull();
}

bool RuleActionParam::isStateValueBased() const
{
    return !m_stateThingId.isNull() && !m_stateTypeId.isNull();
}

RuleActionParam *RuleActionParam::clone() const
{
    RuleActionParam *ret = new RuleActionParam();
    ret->setParamTypeId(paramTypeId());
    ret->setParamName(paramName());
    ret->setValue(value());
    ret->setEventTypeId(eventTypeId());
    ret->setEventParamTypeId(eventParamTypeId());
    ret->setStateThingId(stateThingId());
    ret->setStateTypeId(stateTypeId());
    return ret;
}

#define COMPARE(a, b) if (a != b) { qDebug() << a << "!=" << b; return false; }
#define COMPARE_PTR(a, b) if (!a->operator==(b)) { qDebug() << a << "!=" << b; return false; }
bool RuleActionParam::operator==(RuleActionParam *other) const
{
    COMPARE(m_paramTypeId, other->paramTypeId());
    COMPARE(m_paramName, other->paramName());
    COMPARE(m_eventTypeId, other->eventTypeId());
    COMPARE(m_eventParamTypeId, other->eventParamTypeId());
    COMPARE(m_stateThingId, other->stateThingId());
    COMPARE(m_stateTypeId, other->stateTypeId());
    COMPARE(m_value, other->value());
    return true;
}

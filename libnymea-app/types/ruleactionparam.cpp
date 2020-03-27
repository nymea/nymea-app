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

QString RuleActionParam::stateDeviceId() const
{
    return m_stateDeviceId;
}

void RuleActionParam::setStateDeviceId(const QString &stateDeviceId)
{
    if (m_stateDeviceId != stateDeviceId) {
        m_stateDeviceId = stateDeviceId;
        emit stateDeviceIdChanged();
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
    return !m_stateDeviceId.isNull() && !m_stateTypeId.isNull();
}

RuleActionParam *RuleActionParam::clone() const
{
    RuleActionParam *ret = new RuleActionParam();
    ret->setParamTypeId(paramTypeId());
    ret->setParamName(paramName());
    ret->setValue(value());
    ret->setEventTypeId(eventTypeId());
    ret->setEventParamTypeId(eventParamTypeId());
    ret->setStateDeviceId(stateDeviceId());
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
    COMPARE(m_stateDeviceId, other->stateDeviceId());
    COMPARE(m_stateTypeId, other->stateTypeId());
    COMPARE(m_value, other->value());
    return true;
}

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

#include "statetype.h"

StateType::StateType(QObject *parent) :
    QObject(parent)
{
}

QUuid StateType::id() const
{
    return m_id;
}

void StateType::setId(const QUuid &id)
{
    m_id = id;
}

QString StateType::name() const
{
    return m_name;
}

void StateType::setName(const QString &name)
{
    m_name = name;
}

QString StateType::displayName() const
{
    return m_displayName;
}

void StateType::setDisplayName(const QString &displayName)
{
    m_displayName = displayName;
}

QString StateType::type() const
{
    return m_type;
}

void StateType::setType(const QString &type)
{
    m_type = type;
}

void StateType::setType(QVariant::Type type)
{
    m_type = QVariant::typeToName(type);
}

int StateType::index() const
{
    return m_index;
}

void StateType::setIndex(const int &index)
{
    m_index = index;
}

QVariant StateType::defaultValue() const
{
    return m_defaultValue;
}

void StateType::setDefaultValue(const QVariant &defaultValue)
{
    m_defaultValue = defaultValue;
}

QVariantList StateType::allowedValues() const
{
    return m_allowedValues;
}

void StateType::setAllowedValues(const QVariantList &allowedValues)
{
    m_allowedValues = allowedValues;
}

Types::Unit StateType::unit() const
{
    return m_unit;
}

void StateType::setUnit(const Types::Unit &unit)
{
    m_unit = unit;
}

QString StateType::unitString() const
{
    return m_unitString;
}

void StateType::setUnitString(const QString &unitString)
{
    m_unitString = unitString;
}

QVariant StateType::minValue() const
{
    return m_minValue;
}

void StateType::setMinValue(const QVariant &minValue)
{
    m_minValue = minValue;
}

QVariant StateType::maxValue() const
{
    return m_maxValue;
}

void StateType::setMaxValue(const QVariant &maxValue)
{
    m_maxValue = maxValue;
}

Types::IOType StateType::ioType() const
{
    return m_ioType;
}

void StateType::setIOType(Types::IOType ioType)
{
    m_ioType = ioType;
}

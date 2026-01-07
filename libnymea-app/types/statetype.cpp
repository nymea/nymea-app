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

#include "statetype.h"

StateType::StateType(QObject *parent)
    : QObject(parent)
{}

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

QVariantList StateType::possibleValues() const
{
    return m_possibleValues;
}

void StateType::setPossibleValues(const QVariantList &values, const QStringList &displayNames)
{
    Q_ASSERT_X(values.count() == displayNames.count(), "StateType", "Display names list length does not match values list length");
    m_possibleValues = values;
    m_possibleValuesDisplayNames = displayNames;
}

QStringList StateType::possibleValuesDisplayNames() const
{
    return m_possibleValuesDisplayNames;
}

QString StateType::localizedValue(const QVariant &value) const
{
    int idx = static_cast<int>(m_possibleValues.indexOf(value));
    return m_possibleValuesDisplayNames.at(idx);
}

Types::Unit StateType::unit() const
{
    return m_unit;
}

void StateType::setUnit(const Types::Unit &unit)
{
    m_unit = unit;
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

double StateType::stepSize() const
{
    return m_stepSize;
}

void StateType::setStepSize(double stepSize)
{
    m_stepSize = stepSize;
}

Types::IOType StateType::ioType() const
{
    return m_ioType;
}

void StateType::setIOType(Types::IOType ioType)
{
    m_ioType = ioType;
}

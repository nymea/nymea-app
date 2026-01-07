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

#include "paramtype.h"

ParamType::ParamType(QObject *parent)
    : QObject(parent)
{
    m_readOnly = false;
}

ParamType::ParamType(const QString &name, const QVariant::Type type, const QVariant &defaultValue, QObject *parent)
    : QObject(parent)
    , m_name(name)
    , m_type(QVariant::typeToName(type))
    , m_defaultValue(defaultValue)
    , m_readOnly(false)
{}

QUuid ParamType::id() const
{
    return m_id;
}

void ParamType::setId(const QUuid &id)
{
    m_id = id;
}

QString ParamType::name() const
{
    return m_name;
}

void ParamType::setName(const QString &name)
{
    m_name = name;
}

QString ParamType::displayName() const
{
    return m_displayName;
}

void ParamType::setDisplayName(const QString &displayName)
{
    m_displayName = displayName;
}

QString ParamType::type() const
{
    return m_type;
}

void ParamType::setType(const QString &type)
{
    m_type = type;
}

int ParamType::index() const
{
    return m_index;
}

void ParamType::setIndex(const int &index)
{
    m_index = index;
}

QVariant ParamType::defaultValue() const
{
    return m_defaultValue;
}

void ParamType::setDefaultValue(const QVariant &defaultValue)
{
    m_defaultValue = defaultValue;
}

QVariant ParamType::minValue() const
{
    return m_minValue;
}

void ParamType::setMinValue(const QVariant &minValue)
{
    m_minValue = minValue;
}

QVariant ParamType::maxValue() const
{
    return m_maxValue;
}

void ParamType::setMaxValue(const QVariant &maxValue)
{
    m_maxValue = maxValue;
}

double ParamType::stepSize() const
{
    return m_stepSize;
}

void ParamType::setStepSize(double stepSize)
{
    m_stepSize = stepSize;
}

Types::InputType ParamType::inputType() const
{
    return m_inputType;
}

void ParamType::setInputType(const Types::InputType &inputType)
{
    m_inputType = inputType;
}

Types::Unit ParamType::unit() const
{
    return m_unit;
}

void ParamType::setUnit(const Types::Unit &unit)
{
    m_unit = unit;
}

QVariantList ParamType::allowedValues() const
{
    return m_allowedValues;
}

void ParamType::setAllowedValues(const QList<QVariant> allowedValues)
{
    m_allowedValues = allowedValues;
}

bool ParamType::readOnly() const
{
    return m_readOnly;
}

void ParamType::setReadOnly(const bool &readOnly)
{
    m_readOnly = readOnly;
}

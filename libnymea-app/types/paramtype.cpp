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

#include "paramtype.h"

ParamType::ParamType(QObject *parent) :
    QObject(parent)
{
    m_readOnly = false;
}

ParamType::ParamType(const QString &name, const QVariant::Type type, const QVariant &defaultValue, QObject *parent) :
    QObject(parent),
    m_name(name),
    m_type(QVariant::typeToName(type)),
    m_defaultValue(defaultValue),
    m_readOnly(false)
{
}

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

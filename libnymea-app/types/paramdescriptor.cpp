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

#include "paramdescriptor.h"

#include <QDebug>

ParamDescriptor::ParamDescriptor(QObject *parent) : Param(parent)
{

}

QString ParamDescriptor::paramName() const
{
    return m_paramName;
}

void ParamDescriptor::setParamName(const QString &paramName)
{
    if (m_paramName != paramName) {
        m_paramName = paramName;
        emit paramNameChanged();
    }
}

ParamDescriptor::ValueOperator ParamDescriptor::operatorType() const
{
    return m_operator;
}

void ParamDescriptor::setOperatorType(ParamDescriptor::ValueOperator operatorType)
{
    if (m_operator != operatorType) {
        m_operator = operatorType;
        emit operatorTypeChanged();
    }
}

ParamDescriptor *ParamDescriptor::clone() const
{
    ParamDescriptor *ret = new ParamDescriptor();
    ret->setParamTypeId(this->paramTypeId());
    ret->setParamName(this->paramName());
    ret->setValue(this->value());
    ret->setOperatorType(this->operatorType());
    return ret;
}

#define COMPARE(a, b) if (a != b) { qDebug() << a << "!=" << b; return false; }
#define COMPARE_PTR(a, b) if (!a->operator==(b)) { qDebug() << a << "!=" << b; return false; }
bool ParamDescriptor::operator==(ParamDescriptor *other) const
{
    COMPARE(m_paramTypeId, other->paramTypeId());
    COMPARE(m_paramName, other->paramName());
    COMPARE(m_value, other->value());
    COMPARE(m_operator, other->operatorType());
    return true;
}

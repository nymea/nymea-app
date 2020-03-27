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

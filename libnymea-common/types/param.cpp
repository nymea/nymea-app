/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *                                                                         *
 *  Copyright (C) 2017 Simon Stuerz <simon.stuerz@guh.io>                  *
 *                                                                         *
 *  This file is part of nymea:app                                         *
 *                                                                         *
 *  This library is free software; you can redistribute it and/or          *
 *  modify it under the terms of the GNU Lesser General Public             *
 *  License as published by the Free Software Foundation; either           *
 *  version 2.1 of the License, or (at your option) any later version.     *
 *                                                                         *
 *  This library is distributed in the hope that it will be useful,        *
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of         *
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU      *
 *  Lesser General Public License for more details.                        *
 *                                                                         *
 *  You should have received a copy of the GNU Lesser General Public       *
 *  License along with this library; If not, see                           *
 *  <http://www.gnu.org/licenses/>.                                        *
 *                                                                         *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#include "param.h"

Param::Param(const QString &paramTypeId, const QVariant &value, QObject *parent) :
    QObject(parent),
    m_paramTypeId(paramTypeId),
    m_value(value)
{
}

Param::Param(QObject *parent):
    QObject(parent)
{

}

QString Param::paramTypeId() const
{
    return m_paramTypeId;
}

void Param::setParamTypeId(const QString &paramTypeId)
{
    if (m_paramTypeId != paramTypeId) {
        m_paramTypeId = paramTypeId;
        emit paramTypeIdChanged();
    }
}

QVariant Param::value() const
{
    return m_value;
}

void Param::setValue(const QVariant &value)
{
    m_value = value;
    emit valueChanged();
}

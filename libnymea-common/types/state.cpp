/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *                                                                         *
 *  Copyright (C) 2017 Simon Stuerz <simon.stuerz@guh.io>                  *
 *                                                                         *
 *  This file is part of mea                                       *
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

#include "state.h"

#include <QDebug>

State::State(const QUuid &deviceId, const QUuid &stateTypeId, const QVariant &value, QObject *parent) :
    QObject(parent),
    m_deviceId(deviceId),
    m_stateTypeId(stateTypeId),
    m_value(value)
{
}

QUuid State::deviceId() const
{
    return m_deviceId;
}

QUuid State::stateTypeId() const
{
    return m_stateTypeId;
}

QVariant State::value() const
{
    qDebug() << "returning value:" << m_value;
    return m_value;
}

void State::setValue(const QVariant &value)
{
    m_value = value;
    emit valueChanged();
}


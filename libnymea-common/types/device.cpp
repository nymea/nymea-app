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

#include "device.h"
#include "deviceclass.h"

#include <QDebug>

Device::Device(DeviceClass *deviceClass, QObject *parent) :
    QObject(parent),
    m_deviceClass(deviceClass)
{
}

QString Device::name() const
{
    return m_name;
}

void Device::setName(const QString &name)
{
    m_name = name;
    emit nameChanged();
}

QUuid Device::id() const
{
    return m_id;
}

void Device::setId(const QUuid &id)
{
    m_id = id;
}

QUuid Device::deviceClassId() const
{
    return m_deviceClass->id();
}

bool Device::setupComplete()
{
    return m_setupComplete;
}

void Device::setSetupComplete(const bool &setupComplete)
{
    m_setupComplete = setupComplete;
    emit setupCompleteChanged();
}

Params *Device::params() const
{
    return m_params;
}

void Device::setParams(Params *params)
{
    m_params = params;
    emit paramsChanged();
}

States *Device::states() const
{
    return m_states;
}

void Device::setStates(States *states)
{
    m_states = states;
    emit statesChanged();
}

DeviceClass *Device::deviceClass() const
{
    return m_deviceClass;
}

bool Device::hasState(const QUuid &stateTypeId)
{
    foreach (State *state, states()->states()) {
        if (state->stateTypeId() == stateTypeId) {
            return true;
        }
    }
    return false;
}

QVariant Device::stateValue(const QUuid &stateTypeId)
{
    foreach (State *state, states()->states()) {
        if (state->stateTypeId() == stateTypeId) {
            return state->value();
        }
    }
    return QVariant();
}

void Device::setStateValue(const QUuid &stateTypeId, const QVariant &value)
{
    foreach (State *state, states()->states()) {
        if (state->stateTypeId() == stateTypeId) {
            state->setValue(value);
            return;
        }
    }
}

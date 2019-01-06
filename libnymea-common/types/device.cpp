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
    if (m_params != params) {
        if (m_params) {
            m_params->deleteLater();
        }
        m_params = params;
        emit paramsChanged();
    }
}

States *Device::states() const
{
    return m_states;
}

void Device::setStates(States *states)
{
    if (m_states != states) {
        if (m_states) {
            m_states->deleteLater();
        }
        m_states = states;
        emit statesChanged();
    }
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

QDebug operator<<(QDebug &dbg, Device *device)
{
    dbg.nospace() << "Device: " << device->name() << " (" << device->id().toString() << ") Class:" << device->deviceClass()->name() << " (" << device->deviceClassId().toString() << ")" << endl;
    for (int i = 0; i < device->deviceClass()->paramTypes()->rowCount(); i++) {
        ParamType *pt = device->deviceClass()->paramTypes()->get(i);
        Param *p = device->params()->getParam(pt->id().toString());
        if (p) {
            dbg << "  Param " << i << ": " << pt->id().toString() << ": " << pt->name() << " = " << p->value() << endl;
        } else {
            dbg << "  Param " << i << ": " << pt->id().toString() << ": " << pt->name() << " = " << "*** Unknown value ***" << endl;
        }
    }
    for (int i = 0; i < device->deviceClass()->stateTypes()->rowCount(); i++) {
        StateType *st = device->deviceClass()->stateTypes()->get(i);
        State *s = device->states()->getState(st->id());
        dbg << "  State " << i << ": " << st->id() << ": " << st->name() << " = " << s->value() << endl;
    }
    return dbg;
}

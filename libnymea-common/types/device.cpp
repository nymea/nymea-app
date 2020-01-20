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

#include "device.h"
#include "deviceclass.h"

#include <QDebug>

Device::Device(DeviceClass *deviceClass, const QUuid &parentDeviceId, QObject *parent) :
    QObject(parent),
    m_parentDeviceId(parentDeviceId),
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

QUuid Device::parentDeviceId() const
{
    return m_parentDeviceId;
}

bool Device::isChild() const
{
    return !m_parentDeviceId.isNull();
}

Device::DeviceSetupStatus Device::setupStatus() const
{
    return m_setupStatus;
}

void Device::setSetupStatus(Device::DeviceSetupStatus setupStatus)
{
    if (m_setupStatus != setupStatus) {
        m_setupStatus = setupStatus;
        emit setupStatusChanged();
    }
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
        params->setParent(this);
        m_params = params;
        emit paramsChanged();
    }
}

Params *Device::settings() const
{
    return m_settings;
}

void Device::setSettings(Params *settings)
{
    if (m_settings != settings) {
        if (m_settings) {
            m_settings->deleteLater();
        }
        settings->setParent(this);
        m_settings = settings;
        emit settingsChanged();
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
        states->setParent(this);
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
    for (int i = 0; i < device->deviceClass()->settingsTypes()->rowCount(); i++) {
        ParamType *pt = device->deviceClass()->settingsTypes()->get(i);
        Param *p = device->settings()->getParam(pt->id().toString());
        if (p) {
            dbg << "  Setting " << i << ": " << pt->id().toString() << ": " << pt->name() << " = " << p->value() << endl;
        } else {
            dbg << "  Setting " << i << ": " << pt->id().toString() << ": " << pt->name() << " = " << "*** Unknown value ***" << endl;
        }
    }
    for (int i = 0; i < device->deviceClass()->stateTypes()->rowCount(); i++) {
        StateType *st = device->deviceClass()->stateTypes()->get(i);
        State *s = device->states()->getState(st->id());
        dbg << "  State " << i << ": " << st->id() << ": " << st->name() << " = " << s->value() << endl;
    }
    return dbg;
}

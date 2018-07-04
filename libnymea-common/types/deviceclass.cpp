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

#include "deviceclass.h"

#include <QDebug>

DeviceClass::DeviceClass(QObject *parent) :
    QObject(parent)
{
    qRegisterMetaType<BasicTags>();
}

QUuid DeviceClass::id() const
{
    return m_id;
}

void DeviceClass::setId(const QUuid &id)
{
    m_id = id;
}

QUuid DeviceClass::vendorId() const
{
    return m_vendorId;
}

void DeviceClass::setVendorId(const QUuid &vendorId)
{
    m_vendorId = vendorId;
}

QUuid DeviceClass::pluginId() const
{
    return m_pluginId;
}

void DeviceClass::setPluginId(const QUuid &pluginId)
{
    m_pluginId = pluginId;
}

QString DeviceClass::name() const
{
    return m_name;
}

void DeviceClass::setName(const QString &name)
{
    m_name = name;
}

QString DeviceClass::displayName() const
{
    return m_displayName;
}

void DeviceClass::setDisplayName(const QString &displayName)
{
    m_displayName = displayName;
}

QStringList DeviceClass::createMethods() const
{
    return m_createMethods;
}

void DeviceClass::setCreateMethods(const QStringList &createMethods)
{
    m_createMethods = createMethods;
}

DeviceClass::SetupMethod DeviceClass::setupMethod() const
{
    return m_setupMethod;
}

void DeviceClass::setSetupMethod(DeviceClass::SetupMethod setupMethod)
{
    m_setupMethod = setupMethod;
}

QList<DeviceClass::BasicTag> DeviceClass::basicTags() const
{
    return m_basicTags;
}

QStringList DeviceClass::basicTagNames() const
{
    QStringList ret;
    foreach (DeviceClass::BasicTag tag, m_basicTags) {
        ret << basicTagToString(tag);
    }
    return ret;
}

void DeviceClass::setBasicTags(QList<DeviceClass::BasicTag> basicTags)
{
    m_basicTags = basicTags;
}

QStringList DeviceClass::interfaces() const
{
    return m_interfaces;
}

void DeviceClass::setInterfaces(const QStringList &interfaces)
{
    m_interfaces = interfaces;
}

ParamTypes *DeviceClass::paramTypes() const
{
    return m_paramTypes;
}

void DeviceClass::setParamTypes(ParamTypes *paramTypes)
{
    m_paramTypes = paramTypes;
    emit paramTypesChanged();
}

ParamTypes *DeviceClass::discoveryParamTypes() const
{
    return m_discoveryParamTypes;
}

void DeviceClass::setDiscoveryParamTypes(ParamTypes *paramTypes)
{
    m_discoveryParamTypes = paramTypes;
    emit discoveryParamTypesChanged();
}

StateTypes *DeviceClass::stateTypes() const
{
    return m_stateTypes;
}

void DeviceClass::setStateTypes(StateTypes *stateTypes)
{
    m_stateTypes = stateTypes;
    emit stateTypesChanged();
}

EventTypes *DeviceClass::eventTypes() const
{
    return m_eventTypes;
}

void DeviceClass::setEventTypes(EventTypes *eventTypes)
{
    m_eventTypes = eventTypes;
    emit eventTypesChanged();
}

ActionTypes *DeviceClass::actionTypes() const
{
    return m_actionTypes;
}

void DeviceClass::setActionTypes(ActionTypes *actionTypes)
{
    m_actionTypes = actionTypes;
    emit actionTypesChanged();
}

bool DeviceClass::hasActionType(const QString &actionTypeId)
{
    foreach (ActionType *actionType, m_actionTypes->actionTypes()) {
        if (actionType->id() == actionTypeId) {
            return true;
        }
    }
    return false;
}

QString DeviceClass::basicTagToString(DeviceClass::BasicTag basicTag)
{
    switch (basicTag) {
    case DeviceClass::BasicTagActuator:
        return "Actuators";
    case DeviceClass::BasicTagAppliance:
        return "Apliances";
    case DeviceClass::BasicTagCamera:
        return "Cameras";
    case DeviceClass::BasicTagCooling:
        return "Cooling";
    case DeviceClass::BasicTagDevice:
        return "Devices";
    case DeviceClass::BasicTagEnergy:
        return "Energy";
    case DeviceClass::BasicTagGateway:
        return "Gateways";
    case DeviceClass::BasicTagHeating:
        return "Heating";
    case DeviceClass::BasicTagLighting:
        return "Lighting";
    case DeviceClass::BasicTagLock:
        return "Locks";
    case DeviceClass::BasicTagMultimedia:
        return "Multimedia";
    case DeviceClass::BasicTagNotification:
        return "Notifications";
    case DeviceClass::BasicTagSecurity:
        return "Security";
    case DeviceClass::BasicTagSensor:
        return "Sensors";
    case DeviceClass::BasicTagService:
        return "Services";
    case DeviceClass::BasicTagShading:
        return "Shading";
    case DeviceClass::BasicTagTime:
        return "Time";
    case DeviceClass::BasicTagWeather:
        return "Weather";
    default:
        return "Unknown";
    }
    return "Unknown";
}

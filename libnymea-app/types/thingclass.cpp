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

#include "thingclass.h"

#include <QDebug>

ThingClass::ThingClass(QObject *parent) :
    QObject(parent)
{
}

QUuid ThingClass::id() const
{
    return m_id;
}

void ThingClass::setId(const QUuid &id)
{
    m_id = id;
}

QUuid ThingClass::vendorId() const
{
    return m_vendorId;
}

void ThingClass::setVendorId(const QUuid &vendorId)
{
    m_vendorId = vendorId;
}

QUuid ThingClass::pluginId() const
{
    return m_pluginId;
}

void ThingClass::setPluginId(const QUuid &pluginId)
{
    m_pluginId = pluginId;
}

QString ThingClass::name() const
{
    return m_name;
}

void ThingClass::setName(const QString &name)
{
    m_name = name;
}

QString ThingClass::displayName() const
{
    return m_displayName;
}

void ThingClass::setDisplayName(const QString &displayName)
{
    m_displayName = displayName;
}

QStringList ThingClass::createMethods() const
{
    return m_createMethods;
}

void ThingClass::setCreateMethods(const QStringList &createMethods)
{
    m_createMethods = createMethods;
}

ThingClass::SetupMethod ThingClass::setupMethod() const
{
    return m_setupMethod;
}

void ThingClass::setSetupMethod(ThingClass::SetupMethod setupMethod)
{
    m_setupMethod = setupMethod;
}

QStringList ThingClass::interfaces() const
{
    return m_interfaces;
}

void ThingClass::setInterfaces(const QStringList &interfaces)
{
    m_interfaces = interfaces;
}

QString ThingClass::baseInterface() const
{
    foreach (const QString &interface, m_interfaces) {
        if (interface == "gateway") {
            return "gateway";
        }
        if (interface == "shutter") {
            return "shutter";
        }
        if (interface == "blind") {
            return "blind";
        }
        if (interface == "garagedoor") {
            return "garagedoor";
        }
        if (interface == "inputtrigger") {
            return "inputtrigger";
        }
        if (interface == "awning") {
            return "awning";
        }
        if (interface == "outputtrigger") {
            return "outputtrigger";
        }
        if (interface == "light") {
            return "light";
        }
        if (interface == "sensor") {
            return "sensor";
        }
        if (interface == "weather") {
            return "weather";
        }
        if (interface == "media") {
            return "media";
        }
        if (interface == "button" || interface == "powerswitch") {
            return "button";
        }
        if (interface == "notifications") {
            return "notifications";
        }
        if (interface == "powersocket") {
            return "powersocket";
        }
        if (interface == "smartmeter") {
            return "smartmeter";
        }
        if (interface == "heating") {
            return "heating";
        }
        if (interface == "evcharger") {
            return "evcharger";
        }
        if (interface == "irrigation") {
            return "irrigation";
        }
        if (interface == "barcodescanner") {
            return "barcodescanner";
        }
    }
    return "uncategorized";
}

bool ThingClass::browsable() const
{
    return m_browsable;
}

void ThingClass::setBrowsable(bool browsable)
{
    m_browsable = browsable;
}

ParamTypes *ThingClass::paramTypes() const
{
    return m_paramTypes;
}

void ThingClass::setParamTypes(ParamTypes *paramTypes)
{
    if (m_paramTypes) {
        m_paramTypes->deleteLater();
    }
    m_paramTypes = paramTypes;
    emit paramTypesChanged();
}

ParamTypes *ThingClass::settingsTypes() const
{
    return m_settingsTypes;
}

void ThingClass::setSettingsTypes(ParamTypes *settingsTypes)
{
    if (m_settingsTypes) {
        m_settingsTypes->deleteLater();
    }
    m_settingsTypes = settingsTypes;
    emit settingsTypesChanged();
}

ParamTypes *ThingClass::discoveryParamTypes() const
{
    return m_discoveryParamTypes;
}

void ThingClass::setDiscoveryParamTypes(ParamTypes *paramTypes)
{
    if (m_discoveryParamTypes) {
        m_discoveryParamTypes->deleteLater();
    }
    m_discoveryParamTypes = paramTypes;
    emit discoveryParamTypesChanged();
}

StateTypes *ThingClass::stateTypes() const
{
    return m_stateTypes;
}

void ThingClass::setStateTypes(StateTypes *stateTypes)
{
    if (m_stateTypes) {
        m_stateTypes->deleteLater();
    }
    m_stateTypes = stateTypes;
    emit stateTypesChanged();
}

EventTypes *ThingClass::eventTypes() const
{
    return m_eventTypes;
}

void ThingClass::setEventTypes(EventTypes *eventTypes)
{
    if (m_eventTypes) {
        m_eventTypes->deleteLater();
    }
    m_eventTypes = eventTypes;
    emit eventTypesChanged();
}

ActionTypes *ThingClass::actionTypes() const
{
    return m_actionTypes;
}

void ThingClass::setActionTypes(ActionTypes *actionTypes)
{
    if (m_actionTypes) {
        m_actionTypes->deleteLater();
    }
    m_actionTypes = actionTypes;
    emit actionTypesChanged();
}

ActionTypes *ThingClass::browserItemActionTypes() const
{
    return m_browserItemActionTypes;
}

void ThingClass::setBrowserItemActionTypes(ActionTypes *browserActionTypes)
{
    if (m_browserItemActionTypes) {
        m_browserItemActionTypes->deleteLater();
    }
    m_browserItemActionTypes = browserActionTypes;
    emit browserItemActionTypesChanged();
}

bool ThingClass::hasActionType(const QString &actionTypeId)
{
    foreach (ActionType *actionType, m_actionTypes->actionTypes()) {
        if (actionType->id() == actionTypeId) {
            return true;
        }
    }
    return false;
}

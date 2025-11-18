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

#include "interface.h"

#include "eventtypes.h"
#include "statetypes.h"
#include "actiontypes.h"
#include "thingclass.h"

Interface::Interface(const QString &name, const QString &displayName, QObject *parent) :
    QObject(parent),
    m_name(name),
    m_displayName(displayName),
    m_eventTypes(new EventTypes(this)),
    m_stateTypes(new StateTypes(this)),
    m_actionTypes(new ActionTypes(this))
{

}

QString Interface::name() const
{
    return m_name;
}

QString Interface::displayName() const
{
    return m_displayName;
}

EventTypes* Interface::eventTypes() const
{
    return m_eventTypes;
}

StateTypes* Interface::stateTypes() const
{
    return m_stateTypes;
}

ActionTypes* Interface::actionTypes() const
{
    return m_actionTypes;
}

ThingClass *Interface::createThingClass()
{
    ThingClass* dc = new ThingClass();
    dc->setName(m_name);
    dc->setParamTypes(new ParamTypes(dc));
    dc->setSettingsTypes(new ParamTypes(dc));
    dc->setDisplayName(m_displayName);
    dc->setEventTypes(m_eventTypes);
    dc->setStateTypes(m_stateTypes);
    dc->setActionTypes(m_actionTypes);
    return dc;
}

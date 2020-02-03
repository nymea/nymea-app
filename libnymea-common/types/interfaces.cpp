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

#include "interfaces.h"
#include "interface.h"

#include "eventtypes.h"
#include "eventtype.h"
#include "actiontypes.h"
#include "actiontype.h"
#include "statetype.h"
#include "statetypes.h"

#include "device.h"

#include "paramtypes.h"

Interfaces::Interfaces(QObject *parent) : QAbstractListModel(parent)
{
    ParamTypes *pts = nullptr;

    addInterface("battery", tr("Battery powered devices"));
    addStateType("battery", "batteryCritical", QVariant::Bool, false,
                 tr("Battery level is critical"),
                 tr("Battery level entered critical state"));


    addInterface("notifications", tr("Notification services"));
    pts = createParamTypes("title", tr("Title"), QVariant::String);
    addParamType(pts, "body", tr("Message body"), QVariant::String);
    addActionType("notifications", "notify", tr("Send notification"), pts);

    addInterface("power", tr("Powered things"));
    addStateType("power", "power", QVariant::Bool, true,
                 tr("Thing is turned on"),
                 tr("A thing is turned on or off"),
                 tr("Turn things on or off"));

    addInterface("light", tr("Lights"));
    addStateType("light", "power", QVariant::Bool, true,
                 tr("Light is turned on"),
                 tr("A light is turned on or off"),
                 tr("Turn lights on or off"));

    addInterface("dimmablelight", tr("Dimmable lights"));
    addStateType("dimmablelight", "brightness", QVariant::Int, true,
                 tr("Light's brightness is"),
                 tr("A light's brightness has changed"),
                 tr("Set lights brightness"));

    addInterface("temperaturesensor", tr("Temperature sensors"));
    addStateType("temperaturesensor", "temperature", QVariant::Double, false,
                 tr("Temperature"),
                 tr("Temperature has changed"));

    addInterface("simpleclosable", tr("Closable things"));
    addActionType("simpleclosable", "close", tr("Close"), new ParamTypes());

    addInterface("presencesensor", tr("Presence sensors"));
    addStateType("presencesensor", "isPresent", QVariant::Bool, false,
                 tr("Is present"),
                 tr("Presence changed"));

    addInterface("blind", tr("Blinds"));
    addActionType("blind", "close", tr("Close"), new ParamTypes());
    addActionType("blind", "open", tr("Open"), new ParamTypes());

    addInterface("awning", tr("Awnings"));
    addActionType("awning", "close", tr("Close"), new ParamTypes());
    addActionType("awning", "open", tr("Open"), new ParamTypes());

    addInterface("shutter", tr("Shutters"));
    addActionType("shutter", "close", tr("Close"), new ParamTypes());
    addActionType("shutter", "open", tr("Open"), new ParamTypes());

    addInterface("garagegate", tr("Garage gates"));
    addActionType("garagegate", "close", tr("Close"), new ParamTypes());
    addActionType("garagegate", "open", tr("Open"), new ParamTypes());

    addInterface("co2sensor", tr("Air sensors"));
    addStateType("co2sensor", "co2", QVariant::Double, false,
                 tr("Air quality"),
                 tr("Air quality changed"));

    addInterface("humiditysensor", tr("Humidity sensors"));
    addStateType("humiditysensor", "humidity", QVariant::Double, false,
                 tr("Humidity"),
                 tr("Humidity changed"));

    addInterface("daylightsensor", tr("Daylight sensors"));
    addStateType("daylightsensor", "daylight", QVariant::Bool, false,
                 tr("Daylight"),
                 tr("Daylight changed"));

    addInterface("lightsensor", tr("Light intensity sensors"));
    addStateType("lightsensor", "lightIntensity", QVariant::Bool, false,
                 tr("Light intensity"),
                 tr("Light intensity changed"));

    addInterface("evcharger", tr("EV charger"));
    addStateType("evcharger", "power", QVariant::Bool, true,
                 tr("Charging"),
                 tr("Charging changed"),
                 tr("Enable charging"));

    addInterface("volumecontroller", tr("Speakers"));
    addActionType("volumecontroller", "increaseVolume", tr("Increase volume"), new ParamTypes());
    addActionType("volumecontroller", "decreaseVolume", tr("Decrease volume"), new ParamTypes());

    addInterface("gateway", tr("Gateways"));
    addStateType("gateway", "connected", QVariant::Bool, false,
                 tr("Connected"),
                 tr("Connected changed"));

    addInterface("heating", tr("Heatings"));
    addStateType("heating", "power", QVariant::Bool, true,
                 tr("Heating enabled"),
                 tr("Heating enabled changed"),
                 tr("Enable heating"));

    addInterface("mediaplayer", tr("Media players"));
    addStateType("mediaplayer", "playbackStatus", QVariant::String, true,
                 tr("Playback status"),
                 tr("Playback status changed"),
                 tr("Set playback status"));

    addInterface("mediacontroller", tr("Media controllers"));
    addActionType("mediacontroller", "play", tr("Start playback"), new ParamTypes());
    addActionType("mediacontroller", "stop", tr("Stop playback"), new ParamTypes());
    addActionType("mediacontroller", "pause", tr("Pause playback"), new ParamTypes());
    addActionType("mediacontroller", "skipBack", tr("Skip back"), new ParamTypes());
    addActionType("mediacontroller", "skipNext", tr("Skip next"), new ParamTypes());
}

int Interfaces::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return m_list.count();
}

QVariant Interfaces::data(const QModelIndex &index, int role) const
{
    switch (role) {
    case RoleName:
        return m_list.at(index.row())->name();
    case RoleDisplayName:
        return m_list.at(index.row())->displayName();
    }
    return QVariant();
}

QHash<int, QByteArray> Interfaces::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles.insert(RoleName, "name");
    roles.insert(RoleDisplayName, "displayName");
    return roles;
}

Interface *Interfaces::get(int index) const
{
    if (index < 0 || index >= m_list.count()) {
        return nullptr;
    }
    return m_list.at(index);
}

Interface *Interfaces::findByName(const QString &name) const
{
    foreach (Interface* iface, m_list) {
        if (iface->name() == name) {
            return iface;
        }
    }
    return nullptr;
}

void Interfaces::addInterface(const QString &name, const QString &displayName)
{
    Interface *iface = new Interface(name, displayName, this);
    m_list.append(iface);
}

void Interfaces::addEventType(const QString &interfaceName, const QString &name, const QString &displayName, ParamTypes *paramTypes)
{
    Interface *iface = nullptr;
    foreach (Interface* i, m_list) {
        if (i->name() == interfaceName) {
            iface = i;
            break;
        }
    }
    Q_ASSERT_X(iface != nullptr, "Interfaces", "Interface not found");
    EventType *et = new EventType();
    et->setName(name);
    et->setDisplayName(displayName);
    et->setParamTypes(paramTypes);
    iface->eventTypes()->addEventType(et);
}

void Interfaces::addActionType(const QString &interfaceName, const QString &name, const QString &displayName, ParamTypes *paramTypes)
{
    Interface *iface = nullptr;
    foreach (Interface* i, m_list) {
        if (i->name() == interfaceName) {
            iface = i;
            break;
        }
    }
    Q_ASSERT_X(iface != nullptr, "Interfaces", "Interface not found");
    ActionType *at = new ActionType();
    at->setName(name);
    at->setDisplayName(displayName);
    at->setParamTypes(paramTypes);
    iface->actionTypes()->addActionType(at);
}

void Interfaces::addStateType(const QString &interfaceName, const QString &name, QVariant::Type type, bool writable, const QString &displayName, const QString &displayNameEvent, const QString &displayNameAction)
{
    Interface *iface = nullptr;
    foreach (Interface* i, m_list) {
        if (i->name() == interfaceName) {
            iface = i;
            break;
        }
    }
    Q_ASSERT_X(iface != nullptr, "Interfaces", "Interface not found");
    StateType *st = new StateType();
    st->setName(name);
    st->setDisplayName(displayName);
    st->setType(type);
    iface->stateTypes()->addStateType(st);
    ParamTypes *pts = createParamTypes(name, displayName, type);
    addEventType(interfaceName, name, displayNameEvent, pts);
    if (writable) {
        addActionType(interfaceName, name, displayNameAction, pts);
    }
}

ParamTypes *Interfaces::createParamTypes(const QString &name, const QString &displayName, QVariant::Type type, const QVariant &defaultValue, const QVariant &minValue, const QVariant &maxValue)
{
    ParamTypes *pts = new ParamTypes();
    ParamType *pt = new ParamType(name, type, defaultValue);
    pt->setDisplayName(displayName);
    pt->setMinValue(minValue);
    pt->setMaxValue(maxValue);
    pts->addParamType(pt);
    return pts;
}

void Interfaces::addParamType(ParamTypes *paramTypes, const QString &name, const QString &displayName, QVariant::Type type, const QVariant &defaultValue, const QVariant &minValue, const QVariant &maxValue)
{
    ParamType *pt = new ParamType(name, type, defaultValue);
    pt->setDisplayName(displayName);
    pt->setMinValue(minValue);
    pt->setMaxValue(maxValue);
    paramTypes->addParamType(pt);
}

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

    addInterface("accesscontrol", tr("Access control systems"));
    addEventType("accesscontrol", "accessGranted", tr("Access granted"), new ParamTypes());
    addEventType("accesscontrol", "accessDenied", tr("Access denied"), new ParamTypes());

    addInterface("connectable", tr("Connectable things"));
    addStateType("connectable", "connected", QVariant::Bool, false, tr("Connected"), tr("Connected changed"));

    addInterface("gateway", tr("Gateways"), {"connectable"});

    addInterface("account", tr("Accounts"), {"gateway"});
    addStateType("account", "loggedIn", QVariant::Bool, false, tr("User is logged in"), tr("User login changed"));

    addInterface("alert", tr("Alert"));
    addActionType("alert", "alert", tr("Alert"), new ParamTypes());

    addInterface("simpleclosable", tr("Simple closables"));
    addActionType("simpleclosable", "open", tr("Open"), new ParamTypes());
    addActionType("simpleclosable", "close", tr("Close"), new ParamTypes());

    addInterface("closable", tr("Closables"), {"simpleclosable"});
    addActionType("closable", "stop", tr("Stop"), new ParamTypes());

    addInterface("awning", tr("Awnings"), {"closable"});

    addInterface("barcodescanner", tr("Barcode scanners"));
    pts = createParamTypes("content", tr("Content"), QVariant::String);
    addEventType("barcodescanner", "codeScanned", tr("Code scanned"), pts);

    addInterface("battery", tr("Battery powered devices"));
    addStateType("battery", "batteryCritical", QVariant::Bool, false, tr("Battery level is critical"), tr("Battery level entered critical state"));

    addInterface("batterylevel", tr("Battery powered devices"), {"battery"});
    addStateType("batterylevel", "batteryLevel", QVariant::Int, false, tr("Battery level"), tr("Battery level changed"), QString(), 0, 100);

    addInterface("blind", tr("Blinds"), {"closable"});

    addInterface("button", tr("Switches"));
    addEventType("button", "pressed", tr("Button pressed"), new ParamTypes());

    addInterface("sensor", tr("Sensors"));

    addInterface("closablesensor", tr("Closable sensors"), {"sensor"});
    addStateType("closablesensor", "closed", QVariant::Bool, false, tr("Closed"), tr("Opened or closed"));

    addInterface("co2sensor", tr("CO2 sensor"), {"sensor"});
    addStateType("co2sensor", "co2", QVariant::Double, false, tr("CO2 level"), tr("CO2 level changed"));

    addInterface("power", tr("Powered things"));
    addStateType("power", "power", QVariant::Bool, true, tr("Thing is turned on"), tr("A thing is turned on or off"), tr("Turn things on or off"));

    addInterface("light", tr("Lights"));
    addStateType("light", "power", QVariant::Bool, true, tr("Light is turned on"), tr("A light is turned on or off"), tr("Turn lights on or off"));

    addInterface("dimmablelight", tr("Dimmable lights"), {"light"});
    addStateType("dimmablelight", "brightness", QVariant::Int, true, tr("Light's brightness is"), tr("A light's brightness has changed"), tr("Set lights brightness"), 0, 100);

    addInterface("colortemperaturelight", tr("Color temperature light"), {"light", "dimmablelight"});
    addStateType("colortemperaturelight", "colorTemperature", QVariant::Int, true, tr("Lights color temperature is"), tr("A lights color temperature has changed"), tr("Set lights color temperature"), 0, 100);

    addInterface("colorlight", tr("Color lights"), {"light", "dimmablelight", "colortemperaturelight"});
    addStateType("colorlight", "color", QVariant::Color, true, tr("Light's color is"), tr("A light's color has changed"), tr("Set lights color"));

    addInterface("conductivitysensor", tr("Conductivity sensors"), {"sensor"});
    addStateType("conductivitysensor", "conductivity", QVariant::Double, false, tr("Conductivity"), tr("Conductivity changed"));

    addInterface("daylightsensor", tr("Daylight sensors"), {"sensor"});
    addStateType("daylightsensor", "daylight", QVariant::Bool, false, tr("Daylight"), tr("Daylight changed"));

    addInterface("doorbell", tr("Doorbells"));
    addEventType("doorbell", "doorbellPressed", tr("Doorbell pressed"), new ParamTypes());

    addInterface("evcharger", tr("EV charger"));
    addStateType("evcharger", "power", QVariant::Bool, true, tr("Charging"), tr("Charging changed"), tr("Enable charging"));

    addInterface("extendedclosable", tr("Closable things"), {"closable"});
    addStateType("extendedclosable", "moving", QVariant::Bool, false, tr("Moving"), tr("Moving changed"));

    addInterface("extendedawning", tr("Awnings"), {"awning", "extendedclosable"});

    addInterface("extendedblind", tr("Blinds"), {"blind", "extendedclosable"});

    addInterface("extendedevcharger", tr("EV chargers"), {"evcharger"});
    addStateType("extendedevcharger", "maxChargingCurrent", QVariant::UInt, true, tr("Maximum charging current"), tr("Maximum charging current changed"), tr("Set maximum charging current"));

    addInterface("heating", tr("Heatings"));
    addStateType("heating", "power", QVariant::Bool, true, tr("Heating enabled"), tr("Heating enabled changed"), tr("Enable heating"));

    addInterface("extendedheating", tr("Heatings"), {"heating"});
    addStateType("extendedheating", "percentage", QVariant::Int, true, tr("Percentage"), tr("Percentage changed"), tr("Set percentage"), 0, 100);

    addInterface("media", tr("Media"));

    addInterface("mediacontroller", tr("Media controllers"), {"media"});
    addActionType("mediacontroller", "play", tr("Start playback"), new ParamTypes());
    addActionType("mediacontroller", "stop", tr("Stop playback"), new ParamTypes());
    addActionType("mediacontroller", "pause", tr("Pause playback"), new ParamTypes());
    addActionType("mediacontroller", "skipBack", tr("Skip back"), new ParamTypes());
    addActionType("mediacontroller", "skipNext", tr("Skip next"), new ParamTypes());

    addInterface("extendedmediacontroller", tr("Media controllers"), {"mediacontroller"});
    addActionType("extendedmediacontroller", "fastForward", tr("Fast forward"), new ParamTypes());
    addActionType("extendedmediacontroller", "fastRewind", tr("Fast rewind"), new ParamTypes());

    addInterface("navigationpad", tr("Navigation pad"));
    pts = createParamTypes("to", tr("To"), QVariant::String, QVariant(), {"up", "down", "left", "right", "enter", "back", "menu", "info", "home"});
    addActionType("navigationpad", "navigate", tr("Navigate"), pts);

    addInterface("extendednavigationpad", tr("Navigation pad"));
    pts = createParamTypes("to", tr("To"), QVariant::String, QVariant(), {"up", "down", "left", "right", "enter", "back", "menu", "info", "home"});
    addActionType("extendednavigationpad", "navigate", tr("Navigate"), pts);

    addInterface("shutter", tr("Shutters"), {"simpleclosable"});

    addInterface("extendedshutter", tr("Shutters"), {"shutter", "extendedclosable"});

    addInterface("smartmeter", tr("Smart meter"));

    addInterface("smartmeterconsumer", tr("Smart meters"), {"smartmeter"});
    addStateType("smartmeterconsumer", "totalEnergyConsumed", QVariant::Double, false, tr("Total energy consumed"), tr("Total energy consumed changed"));

    addInterface("extendedsmartmeterconsumer", tr("Smart meters"), {"smartmeterconsumer"});
    addStateType("extendedsmartmeterconsumer", "currentPower", QVariant::Double, false, tr("Current power"), tr("Current power changed"));

    addInterface("smartmeterproducer", tr("Smart meters"), {"smartmeter"});
    addStateType("smartmeterproducer", "totalEnergyProduced", QVariant::Double, false, tr("Total energy producedd"), tr("Total energy produced changed"));

    addInterface("extendedsmartmeterproducer", tr("Smart meters"), {"smartmeterproducer"});
    addStateType("extendedsmartmeterproducer", "currentPower", QVariant::Double, false, tr("Current power"), tr("Current power changed"));

    addInterface("extendedvolumecontroller", tr("Volume control"), {"media"});
    addStateType("extendedvolumecontroller", "mute", QVariant::Bool, true, tr("Mute"), tr("Muted"), tr("Mute"));
    addStateType("extendedvolumecontroller", "volume", QVariant::Bool, true, tr("Volume"), tr("Volume changed"), tr("Set volume"), 0, 100);

    addInterface("useraccesscontrol", tr("User access control systems"), {"accesscontrol"});
    addStateType("useraccesscontrol", "users", QVariant::StringList, false, tr("Users"), tr("Users changed"));
    pts = createParamTypes("user", tr("User"), QVariant::String);
    addEventType("useraccesscontrol", "accessGranted", tr("Access granted"), pts);
    pts = createParamTypes("user", tr("User"), QVariant::String);
    addActionType("useraccesscontrol", "addUser", tr("Add user"), pts);
    pts = createParamTypes("user", tr("User"), QVariant::String);
    addActionType("useraccesscontrol", "removeUser", tr("Remove user"), pts);

    addInterface("fingerprintreader", tr("Fingerprint readers"), {"useraccesscontrol"});
    addStateType("useraccesscontrol", "users", QVariant::StringList, false, tr("Users"), tr("Users changed"));
    pts = createParamTypes("user", tr("User"), QVariant::String);
    addParamType(pts, "finger", tr("Finger"), QVariant::String);
    addEventType("useraccesscontrol", "accessGranted", tr("Access granted"), pts);
    pts = createParamTypes("user", tr("User"), QVariant::String);
    addParamType(pts, "finger", tr("Finger"), QVariant::String);
    addActionType("useraccesscontrol", "addUser", tr("Add user"), pts);
    pts = createParamTypes("user", tr("User"), QVariant::String);
    addActionType("useraccesscontrol", "removeUser", tr("Remove user"), pts);

    addInterface("garagegate", tr("Garage doors"), {"closable"});
    addStateType("garagegate", "state", QVariant::String, false, tr("State"), tr("State changed"));
    addStateType("garagegate", "intermediatePosition", QVariant::Bool, false, tr("Intermediate position"), tr("Intermediate position changed"));

    addInterface("humiditysensor", tr("Humidity sensors"), {"sensor"});
    addStateType("humiditysensor", "humidity", QVariant::Double, false, tr("Humidity"), tr("Humidity changed"));

    addInterface("inputtrigger", tr("Incoming events"));
    addEventType("inputtrigger", "triggered", tr("Triggered"), new ParamTypes());

    addInterface("irrigation", tr("Irrigation"), {"power"});

    addInterface("lightsensor", tr("Light sensors"), {"sensor"});
    addStateType("lightsensor", "lightIntensity", QVariant::Double, false, tr("Light intensity"), tr("Light intensity changed"));

    addInterface("longpressbutton", tr("Buttons"), {"button"});
    addEventType("longpressbutton", "longPressed", tr("Long pressed"), new ParamTypes());

    addInterface("mediametadataprovider", tr("Media sources"), {"media"});
    addStateType("mediametadataprovider", "title", QVariant::String, false, tr("Title"), tr("Title changed"));
    addStateType("mediametadataprovider", "artist", QVariant::String, false, tr("Artist"), tr("Artist changed"));
    addStateType("mediametadataprovider", "collection", QVariant::String, false, tr("Collection"), tr("Collection changed"));
    addStateType("mediametadataprovider", "artwork", QVariant::String, false, tr("Artwork"), tr("Artwork changed"));

    addInterface("mediaplayer", tr("Media players"), {"media"});
    addStateType("mediaplayer", "playbackStatus", QVariant::String, true, tr("Playback status"), tr("Playback status changed"), tr("Set playback status"));

    addInterface("moisturesensor", tr("Moisture sensors"), {"sensor"});
    addStateType("moisturesensor", "moisture", QVariant::Double, false, tr("Moisture"), tr("Moisture changed"));

    addInterface("multibutton", tr("Switches"), {"button"});
    pts = createParamTypes("buttonName", tr("Button name"), QVariant::String);
    addEventType("multibutton", "pressed", tr("Pressed"), pts);

    addInterface("noisesensor", tr("Noise sensors"), {"sensor"});
    addStateType("noisesensor", "noise", QVariant::Double, false, tr("Noise level"), tr("Noise level changed"));

    addInterface("notifications", tr("Notification services"));
    pts = createParamTypes("title", tr("Title"), QVariant::String);
    addParamType(pts, "body", tr("Message body"), QVariant::String);
    addActionType("notifications", "notify", tr("Send notification"), pts);

    addInterface("outputtrigger", tr("Outgoing events"));
    addActionType("outputtrigger", "trigger", tr("Trigger"), new ParamTypes());

    addInterface("powersocket", tr("Power sockets"));
    addStateType("powersocket", "power", QVariant::Bool, true, tr("Powered"), tr("Turned on/off"), tr("Turn on/off"));

    addInterface("powerswitch", tr("Power switches"), {"button", "power"});

    addInterface("presencesensor", tr("Presence sensors"), {"sensor"});
    addStateType("presencesensor", "isPresent", QVariant::Bool, false, tr("Is present"), tr("Presence changed"));

    addInterface("pressuresensor", tr("Pressure sensors"), {"sensor"});
    addStateType("pressuresensor", "pressure", QVariant::Double, false, tr("Pressure"), tr("Pressure changed"));

    addInterface("shufflerepeat", tr("Media player"));
    addStateType("shufflerepeat", "shuffle", QVariant::Bool, true, tr("Shuffle"), tr("Shuffle changed"), tr("Set shuffle"));
    addStateType("shufflerepeat", "repeat", QVariant::Bool, true, tr("Repeat"), tr("Repeat changed"), tr("Set repeat"));

    addInterface("smartlock", tr("Smart locks"));
    addStateType("smartlock", "state", QVariant::String, false, tr("State"), tr("State changed"));
    addActionType("smartlock", "unlatch", tr("Unlatch"), new ParamTypes());

    addInterface("temperaturesensor", tr("Temperature sensors"), {"sensor"});
    addStateType("temperaturesensor", "temperature", QVariant::Double, false, tr("Temperature"), tr("Temperature has changed"));

    addInterface("thermostat", tr("Thermostats"));
    addStateType("thermostat", "targetTemperature", QVariant::Double, true, tr("Target temperature"), tr("Target temperature changed"), tr("Set target temperature"));

    addInterface("volumecontroller", tr("Speakers"));
    addActionType("volumecontroller", "increaseVolume", tr("Increase volume"), new ParamTypes());
    addActionType("volumecontroller", "decreaseVolume", tr("Decrease volume"), new ParamTypes());

    addInterface("weather", tr("Weather"));
    addStateType("weather", "weatherCondition", QVariant::String, false, tr("Weather description"), tr("Weather description changed"));
    addStateType("weather", "weatherDescription", QVariant::String, false, tr("Weather condition"), tr("Weather condition changed"));
    addStateType("weather", "temperature", QVariant::Double, false, tr("Temperature"), tr("Temperature changed"));
    addStateType("weather", "humidity", QVariant::Double, false, tr("Humidity"), tr("Humidity changed"));
    addStateType("weather", "humidity", QVariant::Double, false, tr("Pressure"), tr("Pressure changed"));
    addStateType("weather", "windSpeed", QVariant::Double, false, tr("Wind speed"), tr("Wind speed changed"));
    addStateType("weather", "windDirection", QVariant::Int, false, tr("Wind direction"), tr("Wind direction changed"));

    addInterface("windspeedsensor", tr("Wind speed sensors"), {"sensor"});
    addStateType("windspeedsensor", "windSpeed", QVariant::Double, false, tr("Wind speed"), tr("Wind speed changed"));

    addInterface("wirelessconnectable", tr("Wireless devices"), {"connectable"});
    addStateType("wirelessconnectable", "signalStrength", QVariant::UInt, false, tr("Signal strength"), tr("Signal strength changed"));

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

void Interfaces::addInterface(const QString &name, const QString &displayName, const QStringList &extends)
{
    Interface *newIface = new Interface(name, displayName, this);
    foreach (const QString &extend, extends) {
        Interface *extendIface = m_hash.value(extend);
        for (int i = 0; i < extendIface->stateTypes()->rowCount(); i++) {
            newIface->stateTypes()->addStateType(extendIface->stateTypes()->get(i));
        }
        for (int i = 0; i < extendIface->actionTypes()->rowCount(); i++) {
            newIface->actionTypes()->addActionType(extendIface->actionTypes()->get(i));
        }
        for (int i = 0; i < extendIface->eventTypes()->rowCount(); i++) {
            newIface->eventTypes()->addEventType(extendIface->eventTypes()->get(i));
        }
    }
    m_list.append(newIface);
    m_hash.insert(name, newIface);
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
    et->setId(QUuid::createUuid());
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
    at->setId(QUuid::createUuid());
    at->setName(name);
    at->setDisplayName(displayName);
    at->setParamTypes(paramTypes);
    iface->actionTypes()->addActionType(at);
}

void Interfaces::addStateType(const QString &interfaceName, const QString &name, QVariant::Type type, bool writable, const QString &displayName, const QString &displayNameEvent, const QString &displayNameAction, const QVariant &min, const QVariant &max)
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
    st->setId(QUuid::createUuid());
    st->setName(name);
    st->setDisplayName(displayName);
    st->setType(type);
    st->setMinValue(min);
    st->setMaxValue(max);
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

ParamTypes *Interfaces::createParamTypes(const QString &name, const QString &displayName, QVariant::Type type, const QVariant &defaultValue, const QVariantList &allowedValues)
{
    ParamTypes *pts = new ParamTypes();
    ParamType *pt = new ParamType(name, type, defaultValue);
    pt->setDisplayName(displayName);
    pt->setAllowedValues(allowedValues);
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

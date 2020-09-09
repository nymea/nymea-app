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

#include "jsontypes.h"
#include "engine.h"
#include "types/vendors.h"
#include "deviceclasses.h"
#include "types/params.h"
#include "types/paramtypes.h"
#include "types/rule.h"
#include "types/ruleaction.h"
#include "types/ruleactions.h"
#include "types/eventdescriptor.h"
#include "types/eventdescriptors.h"
#include "types/ruleactionparam.h"
#include "types/ruleactionparams.h"
#include "types/stateevaluator.h"
#include "types/stateevaluators.h"
#include "types/statedescriptor.h"
#include "types/timeeventitem.h"
#include "types/timeeventitems.h"
#include "types/timedescriptor.h"
#include "types/repeatingoption.h"
#include "types/calendaritems.h"
#include "types/calendaritem.h"

#include <QMetaEnum>

JsonTypes::JsonTypes(QObject *parent) :
    QObject(parent)
{
}

Vendor *JsonTypes::unpackVendor(const QVariantMap &vendorMap)
{
    Vendor *v = new Vendor(vendorMap.value("id").toString(), vendorMap.value("name").toString());
    v->setDisplayName(vendorMap.value("displayName").toString());
    return v;
}

Plugin *JsonTypes::unpackPlugin(const QVariantMap &pluginMap, QObject *parent)
{
    Plugin *plugin = new Plugin(parent);
    plugin->setName(pluginMap.value("name").toString());
    plugin->setPluginId(pluginMap.value("id").toUuid());
    ParamTypes *paramTypes = new ParamTypes(plugin);
    foreach (QVariant paramType, pluginMap.value("paramTypes").toList()) {
        paramTypes->addParamType(JsonTypes::unpackParamType(paramType.toMap(), paramTypes));
    }
    plugin->setParamTypes(paramTypes);
    return plugin;
}

DeviceClass *JsonTypes::unpackDeviceClass(const QVariantMap &deviceClassMap, QObject *parent)
{
    DeviceClass *deviceClass = new DeviceClass(parent);
    deviceClass->setName(deviceClassMap.value("name").toString());
    deviceClass->setDisplayName(deviceClassMap.value("displayName").toString());
    deviceClass->setId(deviceClassMap.value("id").toUuid());
    deviceClass->setVendorId(deviceClassMap.value("vendorId").toUuid());
    deviceClass->setBrowsable(deviceClassMap.value("browsable").toBool());
    QVariantList createMethodsList = deviceClassMap.value("createMethods").toList();
    QStringList createMethods;
    foreach (QVariant method, createMethodsList) {
        createMethods.append(method.toString());
    }
    deviceClass->setCreateMethods(createMethods);
    deviceClass->setSetupMethod(stringToSetupMethod(deviceClassMap.value("setupMethod").toString()));
    deviceClass->setInterfaces(deviceClassMap.value("interfaces").toStringList());

    // ParamTypes
    ParamTypes *paramTypes = new ParamTypes(deviceClass);
    foreach (QVariant paramType, deviceClassMap.value("paramTypes").toList()) {
        paramTypes->addParamType(JsonTypes::unpackParamType(paramType.toMap(), paramTypes));
    }
    deviceClass->setParamTypes(paramTypes);

    // SettingsTypes
    ParamTypes *settingsTypes = new ParamTypes(deviceClass);
    foreach (QVariant settingsType, deviceClassMap.value("settingsTypes").toList()) {
        settingsTypes->addParamType(JsonTypes::unpackParamType(settingsType.toMap(), settingsTypes));
    }
    deviceClass->setSettingsTypes(settingsTypes);

    // discovery ParamTypes
    ParamTypes *discoveryParamTypes = new ParamTypes(deviceClass);
    foreach (QVariant paramType, deviceClassMap.value("discoveryParamTypes").toList()) {
        discoveryParamTypes->addParamType(JsonTypes::unpackParamType(paramType.toMap(), discoveryParamTypes));
    }
    deviceClass->setDiscoveryParamTypes(discoveryParamTypes);

    // StateTypes
    StateTypes *stateTypes = new StateTypes(deviceClass);
    foreach (QVariant stateType, deviceClassMap.value("stateTypes").toList()) {
        stateTypes->addStateType(JsonTypes::unpackStateType(stateType.toMap(), stateTypes));
    }
    deviceClass->setStateTypes(stateTypes);

    // EventTypes
    EventTypes *eventTypes = new EventTypes(deviceClass);
    foreach (QVariant eventType, deviceClassMap.value("eventTypes").toList()) {
        eventTypes->addEventType(JsonTypes::unpackEventType(eventType.toMap(), eventTypes));
    }
    deviceClass->setEventTypes(eventTypes);

    // ActionTypes
    ActionTypes *actionTypes = new ActionTypes(deviceClass);
    foreach (QVariant actionType, deviceClassMap.value("actionTypes").toList()) {
        actionTypes->addActionType(JsonTypes::unpackActionType(actionType.toMap(), actionTypes));
    }
    deviceClass->setActionTypes(actionTypes);

    // BrowserItemActionTypes
    ActionTypes *browserItemActionTypes = new ActionTypes(deviceClass);
    foreach (QVariant actionType, deviceClassMap.value("browserItemActionTypes").toList()) {
        browserItemActionTypes->addActionType(JsonTypes::unpackActionType(actionType.toMap(), actionTypes));
    }
    deviceClass->setBrowserItemActionTypes(browserItemActionTypes);

    return deviceClass;
}

void JsonTypes::unpackParam(const QVariantMap &paramMap, Param *param)
{
    param->setParamTypeId(paramMap.value("paramTypeId").toString());
    param->setValue(paramMap.value("value"));
}

ParamType *JsonTypes::unpackParamType(const QVariantMap &paramTypeMap, QObject *parent)
{
    ParamType *paramType = new ParamType(parent);
    paramType->setId(paramTypeMap.value("id").toString());
    paramType->setName(paramTypeMap.value("name").toString());
    paramType->setDisplayName(paramTypeMap.value("displayName").toString());
    paramType->setType(paramTypeMap.value("type").toString());
    paramType->setIndex(paramTypeMap.value("index").toInt());
    paramType->setDefaultValue(paramTypeMap.value("defaultValue"));
    paramType->setMinValue(paramTypeMap.value("minValue"));
    paramType->setMaxValue(paramTypeMap.value("maxValue"));
    paramType->setAllowedValues(paramTypeMap.value("allowedValues").toList());
    paramType->setInputType(stringToInputType(paramTypeMap.value("inputType").toString()));
    paramType->setReadOnly(paramTypeMap.value("readOnly").toBool());
    QPair<Types::Unit, QString> unit = stringToUnit(paramTypeMap.value("unit").toString());
    paramType->setUnit(unit.first);
    paramType->setUnitString(unit.second);
    return paramType;
}

StateType *JsonTypes::unpackStateType(const QVariantMap &stateTypeMap, QObject *parent)
{
    StateType *stateType = new StateType(parent);
    stateType->setId(stateTypeMap.value("id").toString());
    stateType->setName(stateTypeMap.value("name").toString());
    stateType->setDisplayName(stateTypeMap.value("displayName").toString());
    stateType->setIndex(stateTypeMap.value("index").toInt());
    stateType->setDefaultValue(stateTypeMap.value("defaultValue"));
    stateType->setAllowedValues(stateTypeMap.value("possibleValues").toList());
    stateType->setType(stateTypeMap.value("type").toString());
    stateType->setMinValue(stateTypeMap.value("minValue"));
    stateType->setMaxValue(stateTypeMap.value("maxValue"));

    QPair<Types::Unit, QString> unit = stringToUnit(stateTypeMap.value("unit").toString());
    stateType->setUnit(unit.first);
    stateType->setUnitString(unit.second);

    QMetaEnum metaEnum = QMetaEnum::fromType<Types::IOType>();
    Types::IOType ioType = static_cast<Types::IOType>(metaEnum.keyToValue(stateTypeMap.value("ioType").toByteArray()));
    stateType->setIOType(ioType);

    return stateType;
}

EventType *JsonTypes::unpackEventType(const QVariantMap &eventTypeMap, QObject *parent)
{
    EventType *eventType = new EventType(parent);
    eventType->setId(eventTypeMap.value("id").toString());
    eventType->setName(eventTypeMap.value("name").toString());
    eventType->setDisplayName(eventTypeMap.value("displayName").toString());
    eventType->setIndex(eventTypeMap.value("index").toInt());
    ParamTypes *paramTypes = new ParamTypes(eventType);
    foreach (QVariant paramType, eventTypeMap.value("paramTypes").toList()) {
        paramTypes->addParamType(JsonTypes::unpackParamType(paramType.toMap(), paramTypes));
    }
    eventType->setParamTypes(paramTypes);
    return eventType;
}

ActionType *JsonTypes::unpackActionType(const QVariantMap &actionTypeMap, QObject *parent)
{
    ActionType *actionType = new ActionType(parent);
    actionType->setId(actionTypeMap.value("id").toString());
    actionType->setName(actionTypeMap.value("name").toString());
    actionType->setDisplayName(actionTypeMap.value("displayName").toString());
    actionType->setIndex(actionTypeMap.value("index").toInt());
    ParamTypes *paramTypes = new ParamTypes(actionType);
    foreach (QVariant paramType, actionTypeMap.value("paramTypes").toList()) {
        paramTypes->addParamType(JsonTypes::unpackParamType(paramType.toMap(), paramTypes));
    }
    actionType->setParamTypes(paramTypes);
    return actionType;
}

Device* JsonTypes::unpackDevice(DeviceManager *deviceManager, const QVariantMap &deviceMap, DeviceClasses *deviceClasses, Device *oldDevice)
{
    QUuid deviceClassId = deviceMap.value("deviceClassId").toUuid();
    DeviceClass *deviceClass = deviceClasses->getDeviceClass(deviceClassId);
    if (!deviceClass) {
        qWarning() << "Cannot find a device class for this device";
        return nullptr;
    }

    QUuid parentDeviceId = deviceMap.value("parentId").toUuid();
    Device *device = nullptr;
    if (oldDevice) {
        device = oldDevice;
    } else {
        device = new Device(deviceManager, deviceClass, parentDeviceId);
    }
    device->setName(deviceMap.value("name").toString());
    device->setId(deviceMap.value("id").toUuid());
    // As of JSONRPC 4.2 setupComplete is deprecated and setupStatus is new
    if (deviceMap.contains("setupStatus")) {
        QString setupStatus = deviceMap.value("setupStatus").toString();
        QString setupDisplayMessage = deviceMap.value("setupDisplayMessage").toString();
        if (setupStatus == "DeviceSetupStatusNone" || setupStatus == "ThingSetupStatusNone") {
            device->setSetupStatus(Device::ThingSetupStatusNone, setupDisplayMessage);
        } else if (setupStatus == "DeviceSetupStatusInProgress" || setupStatus == "ThingSetupStatusInProgress") {
            device->setSetupStatus(Device::ThingSetupStatusInProgress, setupDisplayMessage);
        } else if (setupStatus == "DeviceSetupStatusComplete" || setupStatus == "ThingSetupStatusComplete") {
            device->setSetupStatus(Device::ThingSetupStatusComplete, setupDisplayMessage);
        } else if (setupStatus == "DeviceSetupStatusFailed" || setupStatus == "ThingSetupStatusFailed") {
            device->setSetupStatus(Device::ThingSetupStatusFailed, setupDisplayMessage);
        }
    } else {
        device->setSetupStatus(deviceMap.value("setupComplete").toBool() ? Device::ThingSetupStatusComplete : Device::ThingSetupStatusNone, QString());
    }

    Params *params = device->params();
    if (!params) {
        params = new Params(device);
    }
    foreach (QVariant param, deviceMap.value("params").toList()) {
        Param *p = params->getParam(param.toMap().value("paramTypeId").toString());
        if (!p) {
            p = new Param();
            params->addParam(p);
        }
        JsonTypes::unpackParam(param.toMap(), p);
    }
    device->setParams(params);

    Params *settings = device->settings();
    if (!settings) {
        settings = new Params(device);
    }
    foreach (QVariant setting, deviceMap.value("settings").toList()) {
        Param *p = settings->getParam(setting.toMap().value("paramTypeId").toString());
        if (!p) {
            p = new Param();
            settings->addParam(p);
        }
        JsonTypes::unpackParam(setting.toMap(), p);
    }
    device->setSettings(settings);

    States *states = device->states();
    if (!states) {
        states = new States(device);
    }
    foreach (const QVariant &stateVariant, deviceMap.value("states").toList()) {
        State *state = states->getState(stateVariant.toMap().value("stateTypeId").toUuid());
        if (!state) {
            state = new State(device->id(), stateVariant.toMap().value("stateTypeId").toUuid(), stateVariant.toMap().value("value"), states);
            states->addState(state);
        } else {
            state->setValue(stateVariant.toMap().value("value"));
        }
    }
    device->setStates(states);

    return device;
}




QVariantMap JsonTypes::packParam(Param *param)
{
    QVariantMap ret;
    ret.insert("paramTypeId", param->paramTypeId());
    ret.insert("value", param->value());
    return ret;
}

DeviceClass::SetupMethod JsonTypes::stringToSetupMethod(const QString &setupMethodString)
{
    if (setupMethodString == "SetupMethodJustAdd") {
        return DeviceClass::SetupMethodJustAdd;
    } else if (setupMethodString == "SetupMethodDisplayPin") {
        return DeviceClass::SetupMethodDisplayPin;
    } else if (setupMethodString == "SetupMethodEnterPin") {
        return DeviceClass::SetupMethodEnterPin;
    } else if (setupMethodString == "SetupMethodPushButton") {
        return DeviceClass::SetupMethodPushButton;
    } else if (setupMethodString == "SetupMethodOAuth") {
        return DeviceClass::SetupMethodOAuth;
    } else if (setupMethodString == "SetupMethodUserAndPassword") {
        return DeviceClass::SetupMethodUserAndPassword;
    }
    return DeviceClass::SetupMethodJustAdd;
}

QPair<Types::Unit, QString> JsonTypes::stringToUnit(const QString &unitString)
{
    if (unitString == "UnitNone") {
        return QPair<Types::Unit, QString>(Types::UnitNone, "");
    } else if (unitString == "UnitSeconds") {
        return QPair<Types::Unit, QString>(Types::UnitSeconds, "s");
    } else if (unitString == "UnitMinutes") {
        return QPair<Types::Unit, QString>(Types::UnitMinutes, "m");
    } else if (unitString == "UnitHours") {
        return QPair<Types::Unit, QString>(Types::UnitHours, "h");
    } else if (unitString == "UnitUnixTime") {
        return QPair<Types::Unit, QString>(Types::UnitUnixTime, "datetime");
    } else if (unitString == "UnitMeterPerSecond") {
        return QPair<Types::Unit, QString>(Types::UnitMeterPerSecond, "m/s");
    } else if (unitString == "UnitKiloMeterPerHour") {
        return QPair<Types::Unit, QString>(Types::UnitKiloMeterPerHour, "km/h");
    } else if (unitString == "UnitDegree") {
        return QPair<Types::Unit, QString>(Types::UnitDegree, "°");
    } else if (unitString == "UnitRadiant") {
        return QPair<Types::Unit, QString>(Types::UnitRadiant, "rad");
    } else if (unitString == "UnitDegreeCelsius") {
        return QPair<Types::Unit, QString>(Types::UnitDegreeCelsius, "°C");
    } else if (unitString == "UnitDegreeKelvin") {
        return QPair<Types::Unit, QString>(Types::UnitDegreeKelvin, "°K");
    } else if (unitString == "UnitMired") {
        return QPair<Types::Unit, QString>(Types::UnitMired, "mir");
    } else if (unitString == "UnitMilliBar") {
        return QPair<Types::Unit, QString>(Types::UnitMilliBar, "mbar");
    } else if (unitString == "UnitBar") {
        return QPair<Types::Unit, QString>(Types::UnitBar, "bar");
    } else if (unitString == "UnitPascal") {
        return QPair<Types::Unit, QString>(Types::UnitPascal, "Pa");
    } else if (unitString == "UnitHectoPascal") {
        return QPair<Types::Unit, QString>(Types::UnitHectoPascal, "hPa");
    } else if (unitString == "UnitAtmosphere") {
        return QPair<Types::Unit, QString>(Types::UnitAtmosphere, "atm");
    } else if (unitString == "UnitLumen") {
        return QPair<Types::Unit, QString>(Types::UnitLumen, "lm");
    } else if (unitString == "UnitLux") {
        return QPair<Types::Unit, QString>(Types::UnitLux, "lx");
    } else if (unitString == "UnitCandela") {
        return QPair<Types::Unit, QString>(Types::UnitCandela, "cd");
    } else if (unitString == "UnitMilliMeter") {
        return QPair<Types::Unit, QString>(Types::UnitMilliMeter, "mm");
    } else if (unitString == "UnitCentiMeter") {
        return QPair<Types::Unit, QString>(Types::UnitCentiMeter, "cm");
    } else if (unitString == "UnitMeter") {
        return QPair<Types::Unit, QString>(Types::UnitMeter, "m");
    } else if (unitString == "UnitKiloMeter") {
        return QPair<Types::Unit, QString>(Types::UnitKiloMeter, "km");
    } else if (unitString == "UnitGram") {
        return QPair<Types::Unit, QString>(Types::UnitGram, "g");
    } else if (unitString == "UnitKiloGram") {
        return QPair<Types::Unit, QString>(Types::UnitKiloGram, "kg");
    } else if (unitString == "UnitDezibel") {
        return QPair<Types::Unit, QString>(Types::UnitDezibel, "db");
    } else if (unitString == "UnitBpm") {
        return QPair<Types::Unit, QString>(Types::UnitBpm, "bpm");
    } else if (unitString == "UnitKiloByte") {
        return QPair<Types::Unit, QString>(Types::UnitKiloByte, "kB");
    } else if (unitString == "UnitMegaByte") {
        return QPair<Types::Unit, QString>(Types::UnitMegaByte, "MB");
    } else if (unitString == "UnitGigaByte") {
        return QPair<Types::Unit, QString>(Types::UnitGigaByte, "GB");
    } else if (unitString == "UnitTeraByte") {
        return QPair<Types::Unit, QString>(Types::UnitTeraByte, "TB");
    } else if (unitString == "UnitMilliWatt") {
        return QPair<Types::Unit, QString>(Types::UnitMilliWatt, "mW");
    } else if (unitString == "UnitWatt") {
        return QPair<Types::Unit, QString>(Types::UnitWatt, "W");
    } else if (unitString == "UnitKiloWatt") {
        return QPair<Types::Unit, QString>(Types::UnitKiloWatt, "kW");
    } else if (unitString == "UnitKiloWattHour") {
        return QPair<Types::Unit, QString>(Types::UnitKiloWattHour, "kWh");
    } else if (unitString == "UnitEuroPerMegaWattHour") {
        return QPair<Types::Unit, QString>(Types::UnitEuroPerMegaWattHour, "€/MWh");
    } else if (unitString == "UnitEuroCentPerKiloWattHour") {
        return QPair<Types::Unit, QString>(Types::UnitEuroCentPerKiloWattHour, "ct/kWh");
    } else if (unitString == "UnitPercentage") {
        return QPair<Types::Unit, QString>(Types::UnitPercentage, "%");
    } else if (unitString == "UnitPartsPerMillion") {
        return QPair<Types::Unit, QString>(Types::UnitPartsPerMillion, "ppm");
    } else if (unitString == "UnitEuro") {
        return QPair<Types::Unit, QString>(Types::UnitEuro, "€");
    } else if (unitString == "UnitDollar") {
        return QPair<Types::Unit, QString>(Types::UnitDollar, "$");
    } else if (unitString == "UnitHerz") { // legacy
        return QPair<Types::Unit, QString>(Types::UnitHertz, "Hz");
    } else if (unitString == "UnitHertz") {
        return QPair<Types::Unit, QString>(Types::UnitHertz, "Hz");
    } else if (unitString == "UnitAmpere") {
        return QPair<Types::Unit, QString>(Types::UnitAmpere, "A");
    } else if (unitString == "UnitMilliAmpere") {
        return QPair<Types::Unit, QString>(Types::UnitMilliAmpere, "mA");
    } else if (unitString == "UnitVolt") {
        return QPair<Types::Unit, QString>(Types::UnitVolt, "V");
    } else if (unitString == "UnitMilliVolt") {
        return QPair<Types::Unit, QString>(Types::UnitMilliVolt, "mV");
    } else if (unitString == "UnitVoltAmpere") {
        return QPair<Types::Unit, QString>(Types::UnitVoltAmpere, "VA");
    } else if (unitString == "UnitVoltAmpereReactive") {
        return QPair<Types::Unit, QString>(Types::UnitVoltAmpereReactive, "VAR");
    } else if (unitString == "UnitAmpereHour") {
        return QPair<Types::Unit, QString>(Types::UnitAmpereHour, "Ah");
    } else if (unitString == "UnitMicroSiemensPerCentimeter") {
        return QPair<Types::Unit, QString>(Types::UnitMicroSiemensPerCentimeter, "µS/cm");
    } else if (unitString == "UnitDuration") {
        return QPair<Types::Unit, QString>(Types::UnitDuration, "s");
    }

    return QPair<Types::Unit, QString>(Types::UnitNone, "");
}

Types::InputType JsonTypes::stringToInputType(const QString &inputTypeString)
{
    if (inputTypeString == "InputTypeNone") {
        return Types::InputTypeNone;
    } else if (inputTypeString == "InputTypeTextLine") {
        return Types::InputTypeTextLine;
    } else if (inputTypeString == "InputTypeTextArea") {
        return Types::InputTypeTextArea;
    } else if (inputTypeString == "InputTypePassword") {
        return Types::InputTypePassword;
    } else if (inputTypeString == "InputTypeSearch") {
        return Types::InputTypeSearch;
    } else if (inputTypeString == "InputTypeMail") {
        return Types::InputTypeMail;
    } else if (inputTypeString == "InputTypeIPv4Address") {
        return Types::InputTypeIPv4Address;
    } else if (inputTypeString == "InputTypeIPv6Address") {
        return Types::InputTypeIPv6Address;
    } else if (inputTypeString == "InputTypeUrl") {
        return Types::InputTypeUrl;
    } else if (inputTypeString == "InputTypeMacAddress") {
        return Types::InputTypeMacAddress;
    }
    return Types::InputTypeNone;
}

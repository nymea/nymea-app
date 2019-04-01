/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *                                                                         *
 *  Copyright (C) 2017 Simon Stuerz <simon.stuerz@guh.io>                  *
 *                                                                         *
 *  This file is part of nymea:app.                                      *
 *                                                                         *
 *  nymea:app is free software: you can redistribute it and/or modify    *
 *  it under the terms of the GNU General Public License as published by   *
 *  the Free Software Foundation, version 3 of the License.                *
 *                                                                         *
 *  nymea:app is distributed in the hope that it will be useful,         *
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of         *
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the           *
 *  GNU General Public License for more details.                           *
 *                                                                         *
 *  You should have received a copy of the GNU General Public License      *
 *  along with nymea:app. If not, see <http://www.gnu.org/licenses/>.    *
 *                                                                         *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

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

Device* JsonTypes::unpackDevice(const QVariantMap &deviceMap, DeviceClasses *deviceClasses, Device *oldDevice)
{
    QUuid deviceClassId = deviceMap.value("deviceClassId").toUuid();
    DeviceClass *deviceClass = deviceClasses->getDeviceClass(deviceClassId);
    if (!deviceClass) {
        qWarning() << "Cannot find a device class for this device";
        return nullptr;
    }

    Device *device = nullptr;
    if (oldDevice) {
        device = oldDevice;
    } else {
        device = new Device(deviceClass);
    }
    device->setName(deviceMap.value("name").toString());
    device->setId(deviceMap.value("id").toUuid());
    device->setSetupComplete(deviceMap.value("setupComplete").toBool());

    Params *params = device->params();
    if (!params) {
        params = new Params(device);
        device->setParams(params);
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

QVariantMap JsonTypes::packRule(Rule *rule)
{
    QVariantMap ret;
    if (!rule->id().isNull()) {
        ret.insert("ruleId", rule->id());
    }
    ret.insert("name", rule->name());
    ret.insert("enabled", rule->enabled());
    ret.insert("executable", rule->executable());

    if (rule->actions()->rowCount() > 0) {
        ret.insert("actions", packRuleActions(rule->actions()));
    }
    if (rule->exitActions()->rowCount() > 0) {
        ret.insert("exitActions", packRuleActions(rule->exitActions()));
    }

    if (rule->eventDescriptors()->rowCount() > 0) {
        ret.insert("eventDescriptors", packEventDescriptors(rule->eventDescriptors()));
    }

    if (rule->timeDescriptor()->timeEventItems()->rowCount() > 0 || rule->timeDescriptor()->calendarItems()->rowCount() > 0) {
        ret.insert("timeDescriptor", packTimeDescriptor(rule->timeDescriptor()));
    }

    if (rule->stateEvaluator()) {
        ret.insert("stateEvaluator", packStateEvaluator(rule->stateEvaluator()));
    }

    return ret;
}

QVariantList JsonTypes::packRuleActions(RuleActions *ruleActions)
{
    QVariantList ret;
    for (int i = 0; i < ruleActions->rowCount(); i++) {
        QVariantMap ruleAction;
        RuleAction *ra = ruleActions->get(i);
        if (!ra->actionTypeId().isNull() && !ra->deviceId().isNull()) {
            ruleAction.insert("deviceId", ra->deviceId());
            ruleAction.insert("actionTypeId", ra->actionTypeId());
        } else {
            ruleAction.insert("interface", ra->interfaceName());
            ruleAction.insert("interfaceAction", ra->interfaceAction());
        }
        if (ra->ruleActionParams()->rowCount() > 0) {
            QVariantList ruleActionParams;
            for (int j = 0; j < ra->ruleActionParams()->rowCount(); j++) {
                QVariantMap ruleActionParam;
                RuleActionParam *rap = ruleActions->get(i)->ruleActionParams()->get(j);
                if (!rap->paramTypeId().isNull()) {
                    ruleActionParam.insert("paramTypeId", rap->paramTypeId());
                } else {
                    ruleActionParam.insert("paramName", rap->paramName());
                }
                if (rap->isValueBased()) {
                    ruleActionParam.insert("value", rap->value());
                } else if (rap->isEventParamBased()) {
                    ruleActionParam.insert("eventTypeId", rap->eventTypeId());
                    ruleActionParam.insert("eventParamTypeId", rap->eventParamTypeId());
                } else {
                    ruleActionParam.insert("stateDeviceId", rap->stateDeviceId());
                    ruleActionParam.insert("stateTypeId", rap->stateTypeId());
                }
                ruleActionParams.append(ruleActionParam);
            }
            ruleAction.insert("ruleActionParams", ruleActionParams);
        }
        ret.append(ruleAction);
    }

    return ret;
}

QVariantList JsonTypes::packEventDescriptors(EventDescriptors *eventDescriptors)
{
    QVariantList ret;
    for (int i = 0; i < eventDescriptors->rowCount(); i++) {
        QVariantMap eventDescriptorMap;
        EventDescriptor* eventDescriptor = eventDescriptors->get(i);
        if (!eventDescriptor->deviceId().isNull() && !eventDescriptor->eventTypeId().isNull()) {
            eventDescriptorMap.insert("eventTypeId", eventDescriptor->eventTypeId());
            eventDescriptorMap.insert("deviceId", eventDescriptor->deviceId());
        } else {
            eventDescriptorMap.insert("interface", eventDescriptor->interfaceName());
            eventDescriptorMap.insert("interfaceEvent", eventDescriptor->interfaceEvent());
        }
        if (eventDescriptor->paramDescriptors()->rowCount() > 0) {
            QVariantList paramDescriptors;
            for (int j = 0; j < eventDescriptor->paramDescriptors()->rowCount(); j++) {
                QVariantMap paramDescriptor;
                if (!eventDescriptor->paramDescriptors()->get(j)->paramTypeId().isEmpty()) {
                    paramDescriptor.insert("paramTypeId", eventDescriptor->paramDescriptors()->get(j)->paramTypeId());
                } else {
                    paramDescriptor.insert("paramName", eventDescriptor->paramDescriptors()->get(j)->paramName());
                }
                paramDescriptor.insert("value", eventDescriptor->paramDescriptors()->get(j)->value());
                QMetaEnum operatorEnum = QMetaEnum::fromType<ParamDescriptor::ValueOperator>();
                paramDescriptor.insert("operator", operatorEnum.valueToKey(eventDescriptor->paramDescriptors()->get(j)->operatorType()));
                paramDescriptors.append(paramDescriptor);
            }
            eventDescriptorMap.insert("paramDescriptors", paramDescriptors);
        }
        ret.append(eventDescriptorMap);
    }
    return ret;
}

QVariantMap JsonTypes::packParam(Param *param)
{
    QVariantMap ret;
    ret.insert("paramTypeId", param->paramTypeId());
    ret.insert("value", param->value());
    return ret;
}

QVariantMap JsonTypes::packStateEvaluator(StateEvaluator *stateEvaluator)
{
    QVariantMap ret;
    QMetaEnum stateOperatorEnum = QMetaEnum::fromType<StateEvaluator::StateOperator>();
    ret.insert("operator", stateOperatorEnum.valueToKey(stateEvaluator->stateOperator()));
    QVariantMap stateDescriptor;
    if (!stateEvaluator->stateDescriptor()->deviceId().isNull() && !stateEvaluator->stateDescriptor()->stateTypeId().isNull()) {
        stateDescriptor.insert("deviceId", stateEvaluator->stateDescriptor()->deviceId());
        stateDescriptor.insert("stateTypeId", stateEvaluator->stateDescriptor()->stateTypeId());
    } else {
        stateDescriptor.insert("interface", stateEvaluator->stateDescriptor()->interfaceName());
        stateDescriptor.insert("interfaceState", stateEvaluator->stateDescriptor()->interfaceState());
    }
    QMetaEnum valueOperatorEnum = QMetaEnum::fromType<StateDescriptor::ValueOperator>();
    stateDescriptor.insert("operator", valueOperatorEnum.valueToKeys(stateEvaluator->stateDescriptor()->valueOperator()));
    stateDescriptor.insert("value", stateEvaluator->stateDescriptor()->value());
    ret.insert("stateDescriptor", stateDescriptor);
    QVariantList childEvaluators;
    for (int i = 0; i < stateEvaluator->childEvaluators()->rowCount(); i++) {
        childEvaluators.append(packStateEvaluator(stateEvaluator->childEvaluators()->get(i)));
    }
    ret.insert("childEvaluators", childEvaluators);
    return ret;
}

QVariantMap JsonTypes::packTimeDescriptor(TimeDescriptor *timeDescriptor)
{
    QVariantMap ret;
    QVariantList timeEventItems;
    for (int i = 0; i < timeDescriptor->timeEventItems()->rowCount(); i++) {
        timeEventItems.append(packTimeEventItem(timeDescriptor->timeEventItems()->get(i)));
    }
    if (!timeEventItems.isEmpty()) {
        ret.insert("timeEventItems", timeEventItems);
    }
    QVariantList calendarItems;
    for (int i = 0; i < timeDescriptor->calendarItems()->rowCount(); i++) {
        calendarItems.append(packCalendarItem(timeDescriptor->calendarItems()->get(i)));
    }
    if (!calendarItems.isEmpty()) {
        ret.insert("calendarItems", calendarItems);
    }
    return ret;
}

QVariantMap JsonTypes::packTimeEventItem(TimeEventItem *timeEventItem)
{
    QVariantMap ret;
    if (!timeEventItem->time().isNull()) {
        ret.insert("time", timeEventItem->time().toString("hh:mm"));
    }
    if (!timeEventItem->dateTime().isNull()) {
        ret.insert("dateTime", timeEventItem->dateTime().toSecsSinceEpoch());
    }
    ret.insert("repeating", packRepeatingOption(timeEventItem->repeatingOption()));
    return ret;
}

QVariantMap JsonTypes::packCalendarItem(CalendarItem *calendarItem)
{
    QVariantMap ret;
    ret.insert("duration", calendarItem->duration());
    if (!calendarItem->dateTime().isNull()) {
        ret.insert("datetime", calendarItem->dateTime().toSecsSinceEpoch());
    }
    if (!calendarItem->startTime().isNull()) {
        ret.insert("startTime", calendarItem->startTime().toString("hh:mm"));
    }
    ret.insert("repeating", packRepeatingOption(calendarItem->repeatingOption()));
    return ret;
}

QVariantMap JsonTypes::packRepeatingOption(RepeatingOption *repeatingOption)
{
    QVariantMap ret;
    QMetaEnum repeatingModeEnum = QMetaEnum::fromType<RepeatingOption::RepeatingMode>();
    ret.insert("mode", repeatingModeEnum.valueToKey(repeatingOption->repeatingMode()));
    if (!repeatingOption->weekDays().isEmpty()) {
        ret.insert("weekDays", repeatingOption->weekDays());
    }
    if (!repeatingOption->monthDays().isEmpty()) {
        ret.insert("monthDays", repeatingOption->monthDays());
    }
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
    }
    return DeviceClass::SetupMethodJustAdd;
}

QPair<Types::Unit, QString> JsonTypes::stringToUnit(const QString &unitString)
{
    if (unitString == "UnitNone") {
        return QPair<Types::Unit, QString>(Types::UnitNone, "-");
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
    } else if (unitString == "UnitHerz") {
        return QPair<Types::Unit, QString>(Types::UnitHerz, "Hz");
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

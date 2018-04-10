/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *                                                                         *
 *  Copyright (C) 2017 Simon Stuerz <simon.stuerz@guh.io>                  *
 *                                                                         *
 *  This file is part of mea.                                      *
 *                                                                         *
 *  mea is free software: you can redistribute it and/or modify    *
 *  it under the terms of the GNU General Public License as published by   *
 *  the Free Software Foundation, version 3 of the License.                *
 *                                                                         *
 *  mea is distributed in the hope that it will be useful,         *
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of         *
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the           *
 *  GNU General Public License for more details.                           *
 *                                                                         *
 *  You should have received a copy of the GNU General Public License      *
 *  along with mea. If not, see <http://www.gnu.org/licenses/>.    *
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

#include <QMetaEnum>

JsonTypes::JsonTypes(QObject *parent) :
    QObject(parent)
{
}

Vendor *JsonTypes::unpackVendor(const QVariantMap &vendorMap, QObject *parent)
{
    Vendor *v = new Vendor(vendorMap.value("id").toUuid(), vendorMap.value("name").toString(), parent);
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
    deviceClass->setBasicTags(stringListToBasicTags(deviceClassMap.value("basicTags").toStringList()));
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
    stateType->setId(stateTypeMap.value("id").toUuid());
    stateType->setName(stateTypeMap.value("name").toString());
    stateType->setDisplayName(stateTypeMap.value("displayName").toString());
    stateType->setIndex(stateTypeMap.value("index").toInt());
    stateType->setDefaultValue(stateTypeMap.value("defaultValue"));
    stateType->setType(stateTypeMap.value("type").toString());
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

bool JsonTypes::unpackDevice(const QVariantMap &deviceMap, Device *device)
{
    device->setName(deviceMap.value("name").toString());
    device->setId(deviceMap.value("id").toUuid());
    device->setDeviceClassId(deviceMap.value("deviceClassId").toUuid());
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

    DeviceClass *deviceClass = Engine::instance()->deviceManager()->deviceClasses()->getDeviceClass(device->deviceClassId());
    if (!deviceClass) {
        qWarning() << "Cannot find a device class for this device..." << device->deviceClassId() << "Skipping...";
        return false;
    }
    States *states = new States(device);
    foreach (StateType *stateType, deviceClass->stateTypes()->stateTypes()) {
        State *state = new State(device->id(), stateType->id(), stateType->defaultValue(), states);
        states->addState(state);
    }
    device->setStates(states);

    return true;
}

QVariantMap JsonTypes::packRule(Rule *rule)
{
    QVariantMap ret;
    if (!rule->id().isNull()) {
        ret.insert("ruleId", rule->id());
    }
    ret.insert("name", rule->name());
    ret.insert("enabled", rule->enabled());

    if (rule->actions()->rowCount() > 0) {
        ret.insert("actions", packRuleActions(rule->actions()));
    }
    if (rule->exitActions()->rowCount() > 0) {
        ret.insert("exitActions", packRuleActions(rule->exitActions()));
    }

    if (rule->eventDescriptors()->rowCount() > 0) {
        ret.insert("eventDescriptors", packEventDescriptors(rule->eventDescriptors()));
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
        ruleAction.insert("actionTypeId", ruleActions->get(i)->actionTypeId());
        ruleAction.insert("deviceId", ruleActions->get(i)->deviceId());
        if (ruleActions->get(i)->ruleActionParams()->rowCount() > 0) {
            QVariantList ruleActionParams;
            for (int j = 0; j < ruleActions->get(i)->ruleActionParams()->rowCount(); j++) {
                QVariantMap ruleActionParam;
                ruleActionParam.insert("paramTypeId", ruleActions->get(i)->ruleActionParams()->get(j)->paramTypeId());
                if (!ruleActions->get(i)->ruleActionParams()->get(j)->eventTypeId().isEmpty() && !ruleActions->get(i)->ruleActionParams()->get(j)->eventParamTypeId().isEmpty()) {
                    ruleActionParam.insert("eventTypeId", ruleActions->get(i)->ruleActionParams()->get(j)->eventTypeId());
                    ruleActionParam.insert("eventParamTypeId", ruleActions->get(i)->ruleActionParams()->get(j)->eventParamTypeId());
                } else {
                    ruleActionParam.insert("value", ruleActions->get(i)->ruleActionParams()->get(j)->value());
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
                paramDescriptor.insert("paramTypeId", eventDescriptor->paramDescriptors()->get(j)->paramTypeId());
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
    stateDescriptor.insert("deviceId", stateEvaluator->stateDescriptor()->deviceId());
    QMetaEnum valueOperatorEnum = QMetaEnum::fromType<StateDescriptor::ValueOperator>();
    stateDescriptor.insert("operator", valueOperatorEnum.valueToKeys(stateEvaluator->stateDescriptor()->valueOperator()));
    stateDescriptor.insert("stateTypeId", stateEvaluator->stateDescriptor()->stateTypeId());
    stateDescriptor.insert("value", stateEvaluator->stateDescriptor()->value());
    ret.insert("stateDescriptor", stateDescriptor);
    QVariantList childEvaluators;
    for (int i = 0; i < stateEvaluator->childEvaluators()->rowCount(); i++) {
        childEvaluators.append(packStateEvaluator(stateEvaluator->childEvaluators()->get(i)));
    }
    ret.insert("childEvaluators", childEvaluators);
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

QList<DeviceClass::BasicTag> JsonTypes::stringListToBasicTags(const QStringList &basicTagsStringList)
{
    QList<DeviceClass::BasicTag> ret;
    if (basicTagsStringList.contains("BasicTagService"))
        ret << DeviceClass::BasicTagService;
    if (basicTagsStringList.contains("BasicTagDevice"))
        ret << DeviceClass::BasicTagDevice;
    if (basicTagsStringList.contains("BasicTagSensor"))
        ret << DeviceClass::BasicTagSensor;
    if (basicTagsStringList.contains("BasicTagActuator"))
        ret << DeviceClass::BasicTagActuator;
    if (basicTagsStringList.contains("BasicTagLighting"))
        ret << DeviceClass::BasicTagLighting;
    if (basicTagsStringList.contains("BasicTagEnergy"))
        ret << DeviceClass::BasicTagEnergy;
    if (basicTagsStringList.contains("BasicTagMultimedia"))
        ret << DeviceClass::BasicTagMultimedia;
    if (basicTagsStringList.contains("BasicTagWeather"))
        ret << DeviceClass::BasicTagWeather;
    if (basicTagsStringList.contains("BasicTagGateway"))
        ret << DeviceClass::BasicTagGateway;
    if (basicTagsStringList.contains("BasicTagHeating"))
        ret << DeviceClass::BasicTagHeating;
    if (basicTagsStringList.contains("BasicTagCooling"))
        ret << DeviceClass::BasicTagCooling;
    if (basicTagsStringList.contains("BasicTagNotification"))
        ret << DeviceClass::BasicTagNotification;
    if (basicTagsStringList.contains("BasicTagSecurity"))
        ret << DeviceClass::BasicTagSecurity;
    if (basicTagsStringList.contains("BasicTagTime"))
        ret << DeviceClass::BasicTagTime;
    if (basicTagsStringList.contains("BasicTagShading"))
        ret << DeviceClass::BasicTagShading;
    if (basicTagsStringList.contains("BasicTagAppliance"))
        ret << DeviceClass::BasicTagAppliance;
    if (basicTagsStringList.contains("BasicTagCamera"))
        ret << DeviceClass::BasicTagCamera;
    if (basicTagsStringList.contains("BasicTagLock"))
        ret << DeviceClass::BasicTagLock;

    return ret;

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
        return QPair<Types::Unit, QString>(Types::UnitUnixTime, "");
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
    } else if (unitString == "UnitPercentage") {
        return QPair<Types::Unit, QString>(Types::UnitPercentage, "%");
    } else if (unitString == "UnitEuro") {
        return QPair<Types::Unit, QString>(Types::UnitEuro, "€");
    } else if (unitString == "UnitDollar") {
        return QPair<Types::Unit, QString>(Types::UnitDollar, "$");
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

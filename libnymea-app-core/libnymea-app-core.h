#ifndef LIBNYMEAAPPCORE_H
#define LIBNYMEAAPPCORE_H

#include "engine.h"
#include "vendorsproxy.h"
#include "deviceclassesproxy.h"
#include "devicesproxy.h"
#include "pluginsproxy.h"
#include "devicediscovery.h"
#include "discovery/nymeadiscovery.h"
#include "discovery/discoverymodel.h"
#include "discovery/discoverydevice.h"
#include "interfacesmodel.h"
#include "rulemanager.h"
#include "models/rulesfiltermodel.h"
#include "types/ruleactions.h"
#include "types/ruleaction.h"
#include "types/ruleactionparams.h"
#include "types/ruleactionparam.h"
#include "types/eventdescriptors.h"
#include "types/eventdescriptor.h"
#include "types/timedescriptor.h"
#include "types/timeeventitems.h"
#include "types/timeeventitem.h"
#include "types/repeatingoption.h"
#include "types/calendaritems.h"
#include "types/calendaritem.h"
#include "types/rule.h"
#include "types/interfaces.h"
#include "types/interface.h"
#include "types/statedescriptor.h"
#include "types/stateevaluator.h"
#include "types/stateevaluators.h"
#include "models/logsmodel.h"
#include "models/logsmodelng.h"
#include "models/valuelogsproxymodel.h"
#include "models/interfacesproxy.h"
#include "configuration/basicconfiguration.h"
#include "wifisetup/networkmanagercontroller.h"
#include "wifisetup/wirelessaccesspoint.h"
#include "wifisetup/wirelessaccesspoints.h"
#include "wifisetup/wirelessaccesspointsproxy.h"
#include "tagsmanager.h"
#include "models/tagsproxymodel.h"
#include "types/tag.h"
#include "ruletemplates/ruletemplates.h"
#include "ruletemplates/ruletemplate.h"
#include "ruletemplates/eventdescriptortemplate.h"
#include "ruletemplates/stateevaluatortemplate.h"
#include "ruletemplates/statedescriptortemplate.h"
#include "ruletemplates/ruleactiontemplate.h"
#include "ruletemplates/ruleactionparamtemplate.h"
#include "connection/awsclient.h"

#include <QtQml/qqml.h>

static QObject* interfacesModel_provider(QQmlEngine *engine, QJSEngine *scriptEngine)
{
    Q_UNUSED(engine)
    Q_UNUSED(scriptEngine)

    return new Interfaces();
}

static QObject* awsClientProvider(QQmlEngine *engine, QJSEngine *scriptEngine)
{
    Q_UNUSED(engine)
    Q_UNUSED(scriptEngine)

    return AWSClient::instance();
}

void registerQmlTypes() {

    const char uri[] = "Nymea";

    qmlRegisterType<Engine>(uri, 1, 0, "Engine");

    qmlRegisterUncreatableType<DeviceManager>(uri, 1, 0, "DeviceManager", "Can't create this in QML. Get it from the Engine.");
    qmlRegisterUncreatableType<JsonRpcClient>(uri, 1, 0, "JsonRpcClient", "Can't create this in QML. Get it from the Engine.");
    qmlRegisterUncreatableType<NymeaConnection>(uri, 1, 0, "NymeaConnection", "Can't create this in QML. Get it from the Engine.");

    // libnymea-common
    qmlRegisterUncreatableType<Types>(uri, 1, 0, "Types", "Can't create this in QML. Get it from the Engine.");

    qmlRegisterUncreatableType<ParamType>(uri, 1, 0, "ParamType", "Can't create this in QML. Get it from the ParamTypes.");
    qmlRegisterUncreatableType<ParamTypes>(uri, 1, 0, "ParamTypes", "Can't create this in QML. Get it from the DeviceClass.");
    qmlRegisterUncreatableType<EventType>(uri, 1, 0, "EventType", "Can't create this in QML. Get it from the EventTypes.");
    qmlRegisterUncreatableType<EventTypes>(uri, 1, 0, "EventTypes", "Can't create this in QML. Get it from the DeviceClass.");
    qmlRegisterUncreatableType<StateType>(uri, 1, 0, "StateType", "Can't create this in QML. Get it from the StateTypes.");
    qmlRegisterUncreatableType<StateTypes>(uri, 1, 0, "StateTypes", "Can't create this in QML. Get it from the DeviceClass.");
    qmlRegisterUncreatableType<ActionType>(uri, 1, 0, "ActionType", "Can't create this in QML. Get it from the ActionTypes.");
    qmlRegisterUncreatableType<ActionTypes>(uri, 1, 0, "ActionTypes", "Can't create this in QML. Get it from the DeviceClass.");

    qmlRegisterUncreatableType<State>(uri, 1, 0, "State", "Can't create this in QML. Get it from the States.");
    qmlRegisterUncreatableType<States>(uri, 1, 0, "States", "Can't create this in QML. Get it from the Device.");

    qmlRegisterUncreatableType<Vendor>(uri, 1, 0, "Vendor", "Can't create this in QML. Get it from the Vendors.");
    qmlRegisterUncreatableType<Vendors>(uri, 1, 0, "Vendors", "Can't create this in QML. Get it from the DeviceManager.");
    qmlRegisterType<VendorsProxy>(uri, 1, 0, "VendorsProxy");

    qmlRegisterUncreatableType<Device>(uri, 1, 0, "Device", "Can't create this in QML. Get it from the Devices.");
    qmlRegisterUncreatableType<Devices>(uri, 1, 0, "Devices", "Can't create this in QML. Get it from the DeviceManager.");
    qmlRegisterType<DevicesProxy>(uri, 1, 0, "DevicesProxy");
    qmlRegisterType<InterfacesModel>(uri, 1, 0, "InterfacesModel");
    qmlRegisterType<InterfacesSortModel>(uri, 1, 0, "InterfacesSortModel");

    qmlRegisterUncreatableType<DeviceClass>(uri, 1, 0, "DeviceClass", "Can't create this in QML. Get it from the DeviceClasses.");
    qmlRegisterUncreatableType<DeviceClasses>(uri, 1, 0, "DeviceClasses", "Can't create this in QML. Get it from the DeviceManager.");
    qmlRegisterType<DeviceClassesProxy>(uri, 1, 0, "DeviceClassesProxy");
    qmlRegisterType<DeviceDiscovery>(uri, 1, 0, "DeviceDiscovery");

    qmlRegisterUncreatableType<RuleManager>(uri, 1, 0, "RuleManager", "Get it from the Engine");
    qmlRegisterUncreatableType<Rules>(uri, 1, 0, "Rules", "Get it from RuleManager");
    qmlRegisterUncreatableType<Rule>(uri, 1, 0, "Rule", "Get it from Rules");
    qmlRegisterUncreatableType<RuleActions>(uri, 1, 0, "RuleActions", "Get them from the rule");
    qmlRegisterUncreatableType<RuleAction>(uri, 1, 0, "RuleAction", "Get it from RuleActions");
    qmlRegisterUncreatableType<RuleActionParams>(uri, 1, 0, "RuleActionParams", "Get it from RuleActions");
    qmlRegisterUncreatableType<RuleActionParam>(uri, 1, 0, "RuleActionParam", "Get it from RuleActionParams");
    qmlRegisterType<RulesFilterModel>(uri, 1, 0, "RulesFilterModel");
    qmlRegisterUncreatableType<EventDescriptors>(uri, 1, 0, "EventDescriptors", "Get them from rules");
    qmlRegisterUncreatableType<EventDescriptor>(uri, 1, 0, "EventDescriptor", "Get them from rules");
    qmlRegisterUncreatableType<ParamTypes>(uri, 1, 0, "ParamTypes", "Uncreatable");
    qmlRegisterUncreatableType<ParamType>(uri, 1, 0, "ParamType", "Uncreatable");
    qmlRegisterType<Param>(uri, 1, 0, "Param");
    qmlRegisterUncreatableType<ParamDescriptor>(uri, 1, 0, "ParamDescriptor", "Uncreatable");
    qmlRegisterUncreatableType<ParamDescriptors>(uri, 1, 0, "ParamDescriptors", "Uncreatable");
    qmlRegisterUncreatableType<StateDescriptor>(uri, 1, 0, "StateDescriptor", "Uncreatable");
    qmlRegisterUncreatableType<StateEvaluator>(uri, 1, 0, "StateEvaluator", "Uncreatable");
    qmlRegisterUncreatableType<StateEvaluators>(uri, 1, 0, "StateEvaluators", "Uncreatable");
    qmlRegisterUncreatableType<TimeDescriptor>(uri, 1, 0, "TimeDescriptor", "Uncreatable");
    qmlRegisterUncreatableType<TimeEventItems>(uri, 1, 0, "TimeEventItems", "Uncreatable");
    qmlRegisterUncreatableType<TimeEventItem>(uri, 1, 0, "TimeEventItem", "Uncreatable");
    qmlRegisterUncreatableType<RepeatingOption>(uri, 1, 0, "RepeatingOption", "Uncreatable");
    qmlRegisterUncreatableType<CalendarItems>(uri, 1, 0, "CalendarItems", "Uncreatable");
    qmlRegisterUncreatableType<CalendarItem>(uri, 1, 0, "CalendarItem", "Uncreatable");

    qmlRegisterUncreatableType<Interface>(uri, 1, 0, "Interface", "Uncreatable");
    qmlRegisterSingletonType<Interfaces>(uri, 1, 0, "Interfaces", interfacesModel_provider);
    qmlRegisterType<InterfacesProxy>(uri, 1, 0, "InterfacesProxy");

    qmlRegisterUncreatableType<Plugin>(uri, 1, 0, "Plugin", "Can't create this in QML. Get it from the Plugins.");
    qmlRegisterUncreatableType<Plugins>(uri, 1, 0, "Plugins", "Can't create this in QML. Get it from the DeviceManager.");
    qmlRegisterType<PluginsProxy>(uri, 1, 0, "PluginsProxy");

    qmlRegisterUncreatableType<BasicConfiguration>(uri, 1, 0, "BasicConfiguration", "Uncreatable");

    qmlRegisterType<NymeaDiscovery>(uri, 1, 0, "NymeaDiscovery");
    qmlRegisterUncreatableType<DiscoveryModel>(uri, 1, 0, "DiscoveryModel", "Get it from NymeaDiscovery");
    qmlRegisterUncreatableType<DiscoveryDevice>(uri, 1, 0, "DiscoveryDevice", "Get it from DiscoveryModel");
    qmlRegisterUncreatableType<Connection>(uri, 1, 0, "Connection", "Get it from DiscoveryDevice");


    qmlRegisterType<LogsModel>(uri, 1, 0, "LogsModel");
    qmlRegisterType<LogsModelNg>(uri, 1, 0, "LogsModelNg");
    qmlRegisterType<ValueLogsProxyModel>(uri, 1, 0, "ValueLogsProxyModel");
    qmlRegisterUncreatableType<LogEntry>(uri, 1, 0, "LogEntry", "Get them from LogsModel");

    qmlRegisterUncreatableType<TagsManager>(uri, 1, 0, "TagsManager", "Get it from Engine");
    qmlRegisterUncreatableType<Tags>(uri, 1, 0, "Tags", "Get it from TagsManager");
    qmlRegisterUncreatableType<Tag>(uri, 1, 0, "Tag", "Get it from Tags");
    qmlRegisterType<TagsProxyModel>(uri, 1, 0, "TagsProxyModel");

    qmlRegisterType<NetworkManagerController>(uri, 1, 0, "NetworkManagerController");
    qmlRegisterType<BluetoothDiscovery>(uri, 1, 0, "BluetoothDiscovery");
    qmlRegisterUncreatableType<BluetoothDeviceInfo>(uri, 1, 0, "BluetoothDeviceInfo", "Can't create this in QML. Get it from the DeviceInfos.");
    qmlRegisterUncreatableType<BluetoothDeviceInfos>(uri, 1, 0, "BluetoothDeviceInfos", "Can't create this in QML. Get it from the BluetoothDiscovery.");
    qmlRegisterUncreatableType<WirelessSetupManager>(uri, 1, 0, "WirelessSetupManager", "Can't create this in QML. Get it from the NetworkManagerControler.");
    qmlRegisterUncreatableType<WirelessAccessPoint>(uri, 1, 0, "WirelessAccessPoints", "Can't create this in QML. Get it from the WirelessAccessPoints.");
    qmlRegisterUncreatableType<WirelessAccessPoints>(uri, 1, 0, "WirelessAccessPoints", "Can't create this in QML. Get it from the Engine instance.");
    qmlRegisterType<WirelessAccessPointsProxy>(uri, 1, 0, "WirelessAccessPointsProxy");

    qmlRegisterSingletonType<AWSClient>(uri, 1, 0, "AWSClient", awsClientProvider);
    qmlRegisterUncreatableType<AWSDevice>(uri, 1, 0, "AWSDevice", "Can't create this in QML. Get it from AWSClient");

    qmlRegisterType<RuleTemplates>(uri, 1, 0, "RuleTemplates");
    qmlRegisterType<RuleTemplatesFilterModel>(uri, 1, 0, "RuleTemplatesFilterModel");
    qmlRegisterUncreatableType<RuleTemplate>(uri, 1, 0, "RuleTemplate", "Get them from RuleTemplates");
    qmlRegisterUncreatableType<EventDescriptorTemplates>(uri, 1, 0, "EventDescriptorTemplates", "Get it from RuleTemplate");
    qmlRegisterUncreatableType<EventDescriptorTemplate>(uri, 1, 0, "EventDescriptorTemplate", "Get it from EventDescriptorTemplates");
    qmlRegisterUncreatableType<StateEvaluatorTemplate>(uri, 1, 0, "StateEvaluatorTemplate", "Get it from RuleTemplate");
    qmlRegisterUncreatableType<StateDescriptorTemplate>(uri, 1, 0, "StateDescriptorTemplate", "Get it from StateEvaluatorTemplate");
    qmlRegisterUncreatableType<RuleActionTemplates>(uri, 1, 0, "RuleActionTemplates", "Get it from RuleTemplate");
    qmlRegisterUncreatableType<RuleActionTemplate>(uri, 1, 0, "RuleActionTemplate", "Get it from RuleActionTemplates");
    qmlRegisterUncreatableType<RuleActionParamTemplates>(uri, 1, 0, "RuleActionParamTemplates", "Get it from RuleActionTemplate");
    qmlRegisterUncreatableType<RuleActionParamTemplate>(uri, 1, 0, "RuleActionParamTemplate", "Get it from RuleActionParamTemplates");
}

#endif // LIBNYMEAAPPCORE_H

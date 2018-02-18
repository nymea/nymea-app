/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *                                                                         *
 *  Copyright (C) 2017 Simon Stuerz <simon.stuerz@guh.io>                  *
 *                                                                         *
 *  This file is part of guh-control.                                      *
 *                                                                         *
 *  guh-control is free software: you can redistribute it and/or modify    *
 *  it under the terms of the GNU General Public License as published by   *
 *  the Free Software Foundation, version 3 of the License.                *
 *                                                                         *
 *  guh-control is distributed in the hope that it will be useful,         *
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of         *
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the           *
 *  GNU General Public License for more details.                           *
 *                                                                         *
 *  You should have received a copy of the GNU General Public License      *
 *  along with guh-control. If not, see <http://www.gnu.org/licenses/>.    *
 *                                                                         *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#include <QGuiApplication>
#include <QCommandLineParser>
#include <QtQml/QQmlContext>
#include <QQmlApplicationEngine>
#include <QtQuickControls2>

#include "engine.h"
#include "vendorsproxy.h"
#include "deviceclassesproxy.h"
#include "devicesproxy.h"
#include "pluginsproxy.h"
#include "devicediscovery.h"
#include "discovery/upnpdiscovery.h"
#include "discovery/zeroconfdiscovery.h"
#include "interfacesmodel.h"
#include "rulemanager.h"
#include "models/rulesfiltermodel.h"
#include "types/ruleactions.h"
#include "types/ruleaction.h"
#include "types/ruleactionparams.h"
#include "types/ruleactionparam.h"
#include "types/eventdescriptors.h"
#include "types/eventdescriptor.h"
#include "types/rule.h"
#include "models/logsmodel.h"
#include "models/valuelogsproxymodel.h"

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QGuiApplication application(argc, argv);
    application.setApplicationName("guh-control");
    application.setOrganizationName("guh");

    QQuickStyle::setStyle("Material");

    const char uri[] = "Guh";

    qmlRegisterSingletonType<Engine>(uri, 1, 0, "Engine", Engine::qmlInstance);

    qmlRegisterUncreatableType<DeviceManager>(uri, 1, 0, "DeviceManager", "Can't create this in QML. Get it from the Core.");
    qmlRegisterUncreatableType<JsonRpcClient>(uri, 1, 0, "JsonRpcClient", "Can't create this in QML. Get it from the Core.");
    qmlRegisterUncreatableType<GuhConnection>(uri, 1, 0, "GuhConnection", "Can't create this in QML. Get it from the Core.");

    // libguh-common
    qmlRegisterUncreatableType<Types>(uri, 1, 0, "Types", "Can't create this in QML. Get it from the Core.");

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
    qmlRegisterUncreatableType<StatesProxy>(uri, 1, 0, "StatesProxy", "Can't create this in QML. Get it from the Device.");

    qmlRegisterUncreatableType<Vendor>(uri, 1, 0, "Vendor", "Can't create this in QML. Get it from the Vendors.");
    qmlRegisterUncreatableType<Vendors>(uri, 1, 0, "Vendors", "Can't create this in QML. Get it from the DeviceManager.");
    qmlRegisterType<VendorsProxy>(uri, 1, 0, "VendorsProxy");

    qmlRegisterUncreatableType<Device>(uri, 1, 0, "Device", "Can't create this in QML. Get it from the Devices.");
    qmlRegisterUncreatableType<Devices>(uri, 1, 0, "Devices", "Can't create this in QML. Get it from the DeviceManager.");
    qmlRegisterType<DevicesProxy>(uri, 1, 0, "DevicesProxy");
    qmlRegisterType<DevicesBasicTagsModel>(uri, 1, 0, "DevicesBasicTagsModel");
    qmlRegisterType<InterfacesModel>(uri, 1, 0, "InterfacesModel");

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
    qmlRegisterUncreatableType<ParamDescriptor>(uri, 1, 0, "ParamDescriptor", "Uncreatable");
    qmlRegisterUncreatableType<ParamDescriptors>(uri, 1, 0, "ParamDescriptors", "Uncreatable");

    qmlRegisterUncreatableType<Plugin>(uri, 1, 0, "Plugin", "Can't create this in QML. Get it from the Plugins.");
    qmlRegisterUncreatableType<Plugins>(uri, 1, 0, "Plugins", "Can't create this in QML. Get it from the DeviceManager.");
    qmlRegisterType<PluginsProxy>(uri, 1, 0, "PluginsProxy");

    qmlRegisterType<UpnpDiscovery>(uri, 1, 0, "UpnpDiscovery");
    qmlRegisterType<ZeroconfDiscovery>(uri, 1, 0, "ZeroconfDiscovery");

    qmlRegisterType<LogsModel>(uri, 1, 0, "LogsModel");
    qmlRegisterType<ValueLogsProxyModel>(uri, 1, 0, "ValueLogsProxyModel");
    qmlRegisterUncreatableType<LogEntry>(uri, 1, 0, "LogEntry", "Get them from LogsModel");

    Engine::instance();

    QQmlApplicationEngine engine;
    engine.load(QUrl(QLatin1String("qrc:/ui/main.qml")));

    return application.exec();
}

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

#include <QGuiApplication>
#include <QCommandLineParser>
#include <QtQml/QQmlContext>
#include <QQmlApplicationEngine>
#include <QtQuickControls2>
#include <QSysInfo>

#include "engine.h"
#include "vendorsproxy.h"
#include "deviceclassesproxy.h"
#include "devicesproxy.h"
#include "pluginsproxy.h"
#include "devicediscovery.h"
#include "discovery/nymeadiscovery.h"
#include "discovery/discoverymodel.h"
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
#include "types/interfaces.h"
#include "types/interface.h"
#include "types/statedescriptor.h"
#include "types/stateevaluator.h"
#include "types/stateevaluators.h"
#include "models/logsmodel.h"
#include "models/valuelogsproxymodel.h"
#include "models/eventdescriptorparamsfiltermodel.h"
#include "basicconfiguration.h"

static QObject* interfacesModel_provider(QQmlEngine *engine, QJSEngine *scriptEngine)
{
    Q_UNUSED(engine)
    Q_UNUSED(scriptEngine)

    return new Interfaces();
}

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QGuiApplication application(argc, argv);
    application.setApplicationName("mea");
    application.setOrganizationName("nymea");

    foreach (const QFileInfo &fi, QDir(":/ui/fonts/").entryInfoList()) {
        int id = QFontDatabase::addApplicationFont(fi.absoluteFilePath());
        qDebug() << "Added font" << fi.absoluteFilePath() << QFontDatabase::applicationFontFamilies(id);
    }

    QFont applicationFont;
    applicationFont.setFamily("Ubuntu");
    applicationFont.setCapitalization(QFont::MixedCase);
    applicationFont.setPixelSize(16);
    applicationFont.setWeight(QFont::Normal);
    QGuiApplication::setFont(applicationFont);

    QSettings settings;
    QQuickStyle::setStyle(settings.value("style", "Material").toString());

    const char uri[] = "Mea";

    qDebug() << "Running on" << QSysInfo::machineHostName() << QSysInfo::prettyProductName() << QSysInfo::productType() << QSysInfo::productVersion();

    qmlRegisterSingletonType<Engine>(uri, 1, 0, "Engine", Engine::qmlInstance);

    qmlRegisterUncreatableType<DeviceManager>(uri, 1, 0, "DeviceManager", "Can't create this in QML. Get it from the Core.");
    qmlRegisterUncreatableType<JsonRpcClient>(uri, 1, 0, "JsonRpcClient", "Can't create this in QML. Get it from the Core.");
    qmlRegisterUncreatableType<NymeaConnection>(uri, 1, 0, "NymeaConnection", "Can't create this in QML. Get it from the Core.");

    // libnymea-common
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
    qmlRegisterType<Param>(uri, 1, 0, "Param");
    qmlRegisterUncreatableType<ParamDescriptor>(uri, 1, 0, "ParamDescriptor", "Uncreatable");
    qmlRegisterUncreatableType<ParamDescriptors>(uri, 1, 0, "ParamDescriptors", "Uncreatable");
    qmlRegisterUncreatableType<StateDescriptor>(uri, 1, 0, "StateDescriptor", "Uncreatable");
    qmlRegisterUncreatableType<StateEvaluator>(uri, 1, 0, "StateEvaluator", "Uncreatable");
    qmlRegisterUncreatableType<StateEvaluators>(uri, 1, 0, "StateEvaluators", "Uncreatable");

    qmlRegisterUncreatableType<Interface>(uri, 1, 0, "Interface", "Uncreatable");
    qmlRegisterSingletonType<Interfaces>(uri, 1, 0, "Interfaces", interfacesModel_provider);

    qmlRegisterUncreatableType<Plugin>(uri, 1, 0, "Plugin", "Can't create this in QML. Get it from the Plugins.");
    qmlRegisterUncreatableType<Plugins>(uri, 1, 0, "Plugins", "Can't create this in QML. Get it from the DeviceManager.");
    qmlRegisterType<PluginsProxy>(uri, 1, 0, "PluginsProxy");

    qmlRegisterUncreatableType<BasicConfiguration>(uri, 1, 0, "BasicConfiguration", "Uncreatable");

    qmlRegisterType<NymeaDiscovery>(uri, 1, 0, "NymeaDiscovery");
    qmlRegisterUncreatableType<DiscoveryModel>(uri, 1, 0, "DiscoveryModel", "Get it from NymeaDiscovery");

    qmlRegisterType<EventDescriptorParamsFilterModel>(uri, 1, 0, "EventDescriptorParamsFilterModel");

    qmlRegisterType<LogsModel>(uri, 1, 0, "LogsModel");
    qmlRegisterType<ValueLogsProxyModel>(uri, 1, 0, "ValueLogsProxyModel");
    qmlRegisterUncreatableType<LogEntry>(uri, 1, 0, "LogEntry", "Get them from LogsModel");

    Engine::instance();

    QQmlApplicationEngine engine;
    engine.load(QUrl(QLatin1String("qrc:/ui/main.qml")));

    return application.exec();
}

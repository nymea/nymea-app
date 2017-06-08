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

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QGuiApplication application(argc, argv);

    // backend
    qmlRegisterSingletonType<Engine>("Guh", 1, 0, "Engine", Engine::qmlInstance);

    qmlRegisterUncreatableType<DeviceManager>("Guh", 1, 0, "DeviceManager", "Can't create this in QML. Get it from the Core.");
    qmlRegisterUncreatableType<JsonRpcClient>("Guh", 1, 0, "JsonRpcClient", "Can't create this in QML. Get it from the Core.");
    qmlRegisterUncreatableType<GuhInterface>("Guh", 1, 0, "GuhInterface", "Can't create this in QML. Get it from the Core.");
    qmlRegisterUncreatableType<WebsocketInterface>("Guh", 1, 0, "WebsocketInterface", "Can't create this in QML. Get it from the Core.");

    // libguh-common
    qmlRegisterUncreatableType<Types>("Guh", 1, 0, "Types", "Can't create this in QML. Get it from the Core.");

    qmlRegisterUncreatableType<ParamType>("Guh", 1, 0, "ParamType", "Can't create this in QML. Get it from the ParamTypes.");
    qmlRegisterUncreatableType<ParamTypes>("Guh", 1, 0, "ParamTypes", "Can't create this in QML. Get it from the DeviceClass.");
    qmlRegisterUncreatableType<EventType>("Guh", 1, 0, "EventType", "Can't create this in QML. Get it from the EventTypes.");
    qmlRegisterUncreatableType<EventTypes>("Guh", 1, 0, "EventTypes", "Can't create this in QML. Get it from the DeviceClass.");
    qmlRegisterUncreatableType<StateType>("Guh", 1, 0, "StateType", "Can't create this in QML. Get it from the StateTypes.");
    qmlRegisterUncreatableType<StateTypes>("Guh", 1, 0, "StateTypes", "Can't create this in QML. Get it from the DeviceClass.");
    qmlRegisterUncreatableType<ActionType>("Guh", 1, 0, "ActionType", "Can't create this in QML. Get it from the ActionTypes.");
    qmlRegisterUncreatableType<ActionTypes>("Guh", 1, 0, "ActionTypes", "Can't create this in QML. Get it from the DeviceClass.");

    qmlRegisterUncreatableType<State>("Guh", 1, 0, "State", "Can't create this in QML. Get it from the States.");
    qmlRegisterUncreatableType<States>("Guh", 1, 0, "States", "Can't create this in QML. Get it from the Device.");
    qmlRegisterUncreatableType<StatesProxy>("Guh", 1, 0, "StatesProxy", "Can't create this in QML. Get it from the Device.");

    qmlRegisterUncreatableType<Vendor>("Guh", 1, 0, "Vendor", "Can't create this in QML. Get it from the Vendors.");
    qmlRegisterUncreatableType<Vendors>("Guh", 1, 0, "Vendors", "Can't create this in QML. Get it from the DeviceManager.");
    qmlRegisterUncreatableType<VendorsProxy>("Guh", 1, 0, "VendorsProxy", "Can't create this in QML. Get it from the DeviceManager.");

    qmlRegisterUncreatableType<Device>("Guh", 1, 0, "Device", "Can't create this in QML. Get it from the Devices.");
    qmlRegisterUncreatableType<Devices>("Guh", 1, 0, "Devices", "Can't create this in QML. Get it from the DeviceManager.");
    qmlRegisterUncreatableType<DevicesProxy>("Guh", 1, 0, "DevicesProxy", "Can't create this in QML. Get it from the DeviceManager.");

    qmlRegisterUncreatableType<DeviceClass>("Guh", 1, 0, "DeviceClass", "Can't create this in QML. Get it from the DeviceClasses.");
    qmlRegisterUncreatableType<DeviceClasses>("Guh", 1, 0, "DeviceClasses", "Can't create this in QML. Get it from the DeviceManager.");
    qmlRegisterUncreatableType<DeviceClassesProxy>("Guh", 1, 0, "DeviceClassesProxy", "Can't create this in QML. Get it from the DeviceManager.");

    qmlRegisterUncreatableType<Plugin>("Guh", 1, 0, "Plugin", "Can't create this in QML. Get it from the Plugins.");
    qmlRegisterUncreatableType<Plugins>("Guh", 1, 0, "Plugins", "Can't create this in QML. Get it from the DeviceManager.");
    qmlRegisterUncreatableType<PluginsProxy>("Guh", 1, 0, "PluginsProxy", "Can't create this in QML. Get it from the DeviceManager.");

    QQmlApplicationEngine engine;
    engine.load(QUrl(QLatin1String("qrc:/main.qml")));


    Engine::instance();

    return application.exec();
}

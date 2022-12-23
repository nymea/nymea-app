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

import QtQuick 2.5
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.1
import Nymea 1.0
import NymeaApp.Utils 1.0
import "components"

Page {
    id: root
    header: NymeaHeader {
        text: qsTr("System settings")
        backButtonVisible: true
        onBackPressed: pageStack.pop()
    }

    Flickable {
        anchors.fill: parent
        contentHeight: layout.implicitHeight + app.margins
        clip: true

        GridLayout {
            id: layout
            property bool isGrid: columns > 1
            anchors { left: parent.left; top: parent.top; right: parent.right; margins: Style.smallMargins }
            columns: Math.max(1, Math.floor(parent.width / 300))
            rowSpacing: 0
            columnSpacing: 0

            SettingsTile {
                Layout.fillWidth: true
                iconSource: "../images/configure.svg"
                text: qsTr("General")
                subText: qsTr("Change system name and time zone")
                visible: NymeaUtils.hasPermissionScope(engine.jsonRpcClient.permissions, UserInfo.PermissionScopeAdmin)
                onClicked: pageStack.push(Qt.resolvedUrl("system/GeneralSettingsPage.qml"))
            }

            SettingsTile {
                Layout.fillWidth: true
                iconSource: "../images/account.svg"
                text: qsTr("User settings")
                subText: qsTr("Configure who can log in")
                visible: engine.jsonRpcClient.ensureServerVersion("4.2")
                         // Makes user settings menu available with push button auth.
                         && (engine.jsonRpcClient.authenticated || engine.jsonRpcClient.pushButtonAuthAvailable)
                onClicked: pageStack.push(Qt.resolvedUrl("system/ConsolinnoUsersSettingsPage.qml"))
            }

            SettingsTile {
                Layout.fillWidth: true
                iconSource: "../images/connections/network-wifi.svg"
                text: qsTr("Networking")
                subText: qsTr("Configure the system's network connection")
                visible: NymeaUtils.hasPermissionScope(engine.jsonRpcClient.permissions, UserInfo.PermissionScopeAdmin) && Configuration.networkSettingsEnabled
                onClicked: pageStack.push(Qt.resolvedUrl("system/NetworkSettingsPage.qml"))
            }

            SettingsTile {
                Layout.fillWidth: true
                iconSource: "../images/connections/network-vpn.svg"
                text: qsTr("Connection settings")
                subText: qsTr("Configure how applications can connect to this system")
                visible: NymeaUtils.hasPermissionScope(engine.jsonRpcClient.permissions, UserInfo.PermissionScopeAdmin) && Configuration.apiSettingsEnabled
                onClicked: pageStack.push(Qt.resolvedUrl("system/ConnectionInterfacesPage.qml"))
            }

            SettingsTile {
                Layout.fillWidth: true
                iconSource: "../images/mqtt.svg"
                text: qsTr("MQTT broker")
                subText: qsTr("Configure the MQTT broker")
                visible: engine.jsonRpcClient.ensureServerVersion("1.11") && NymeaUtils.hasPermissionScope(engine.jsonRpcClient.permissions, UserInfo.PermissionScopeAdmin) && Configuration.mqttSettingsEnabled
                onClicked: pageStack.push(Qt.resolvedUrl("system/MqttBrokerSettingsPage.qml"))
            }

            SettingsTile {
                Layout.fillWidth: true
                iconSource: "../images/stock_website.svg"
                text: qsTr("Web server")
                subText: qsTr("Configure the web server")
                visible: NymeaUtils.hasPermissionScope(engine.jsonRpcClient.permissions, UserInfo.PermissionScopeAdmin)
                         && Configuration.webServerSettingsEnabled
                onClicked: pageStack.push(Qt.resolvedUrl("system/WebServerSettingsPage.qml"))
            }

            SettingsTile {
                Layout.fillWidth: true
                iconSource: "../images/zigbee.svg"
                text: qsTr("ZigBee")
                subText: qsTr("Configure ZigBee networks")
                visible: engine.jsonRpcClient.ensureServerVersion("5.3") && NymeaUtils.hasPermissionScope(engine.jsonRpcClient.permissions, UserInfo.PermissionScopeAdmin) && Configuration.zigbeeSettingsEnabled
                onClicked: pageStack.push(Qt.resolvedUrl("system/zigbee/ZigbeeSettingsPage.qml"))
            }

            SettingsTile {
                Layout.fillWidth: true
                iconSource: "../images/z-wave.svg"
                text: qsTr("Z-Wave")
                subText: qsTr("Configure Z-Wave networks")
                visible: engine.jsonRpcClient.ensureServerVersion("6.1") && NymeaUtils.hasPermissionScope(engine.jsonRpcClient.permissions, UserInfo.PermissionScopeAdmin) && Configuration.zwaveSettingsEnabled
                onClicked: pageStack.push(Qt.resolvedUrl("system/zwave/ZWaveSettingsPage.qml"))
            }

            SettingsTile {
                Layout.fillWidth: true
                iconSource: "../images/modbus.svg"
                text: qsTr("Modbus RTU")
                subText: qsTr("Configure Modbus RTU master interfaces")
                visible: engine.jsonRpcClient.ensureServerVersion("5.6") && NymeaUtils.hasPermissionScope(engine.jsonRpcClient.permissions, UserInfo.PermissionScopeAdmin) && Configuration.modbusSettingsEnabled
                onClicked: pageStack.push(Qt.resolvedUrl("system/ModbusRtuSettingsPage.qml"))
            }

            SettingsTile {
                Layout.fillWidth: true
                iconSource: "../images/plugin.svg"
                text: qsTr("Plugins")
                subText: qsTr("List and cofigure installed plugins")
                visible: NymeaUtils.hasPermissionScope(engine.jsonRpcClient.permissions, UserInfo.PermissionScopeAdmin) && Configuration.pluginSettingsEnabled
                onClicked:pageStack.push(Qt.resolvedUrl("system/PluginsPage.qml"))
            }

            SettingsTile {
                Layout.fillWidth: true
                iconSource: "../images/sdk.svg"
                text: qsTr("Developer tools")
                subText: qsTr("Access tools for debugging and error reporting")
                visible: NymeaUtils.hasPermissionScope(engine.jsonRpcClient.permissions, UserInfo.PermissionScopeAdmin)
                onClicked: pageStack.push(Qt.resolvedUrl("system/DeveloperTools.qml"))
            }

            SettingsTile {
                Layout.fillWidth: true
                iconSource: "../images/system-update.svg"
                text: qsTr("System update")
                subText: qsTr("Update your %1 system").arg(Configuration.systemName)
                visible: engine.systemController.updateManagementAvailable &&
                         NymeaUtils.hasPermissionScope(engine.jsonRpcClient.permissions, UserInfo.PermissionScopeAdmin)
                onClicked: pageStack.push(Qt.resolvedUrl("system/SystemUpdatePage.qml"))
            }

            SettingsTile {
                Layout.fillWidth: true
                iconSource: "../images/logs.svg"
                text: qsTr("Log viewer")
                subText: qsTr("View system log")
                visible: NymeaUtils.hasPermissionScope(engine.jsonRpcClient.permissions, UserInfo.PermissionScopeAdmin)
                onClicked: pageStack.push(Qt.resolvedUrl("system/LogViewerPage.qml"))
            }

            SettingsTile {
                Layout.fillWidth: true
                iconSource: "../images/info.svg"
                text: qsTr("About %1").arg(Configuration.systemName)
                subText: qsTr("Find server UUID and versions")
                onClicked: pageStack.push(Qt.resolvedUrl("system/AboutNymeaPage.qml"))
            }
        }
    }
}

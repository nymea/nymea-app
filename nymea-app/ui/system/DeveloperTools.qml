// SPDX-License-Identifier: GPL-3.0-or-later

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
* Copyright (C) 2013 - 2024, nymea GmbH
* Copyright (C) 2024 - 2025, chargebyte austria GmbH
*
* This file is part of nymea-app.
*
* nymea-app is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* nymea-app is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with nymea-app. If not, see <https://www.gnu.org/licenses/>.
*
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import Nymea 1.0
import "../components"

SettingsPageBase {
    id: root
    title: qsTr("Developer tools")

    property WebServerConfiguration usedConfig: {
        var config = null
        for (var i = 0; i < engine.nymeaConfiguration.webServerConfigurations.count; i++) {
            var tmp = engine.nymeaConfiguration.webServerConfigurations.get(i)
            print("checking config:", tmp.id, tmp.address, tmp.port, tmp.sslEnabled)
            if (tmp.address === engine.jsonRpcClient.currentConnection.hostAddress || tmp.address === "0.0.0.0") {

                // This one prefers https over http...
                //                if (config === null || (!config.sslEnabled && tmp.sslEnabled)) {

                // ...but for now, prefer http because self signed certs cause trouble and this is meant for local debugging only anyways...
                if (config === null || (config.sslEnabled && !tmp.sslEnabled)) {
                    config = tmp;
                }
                continue;
            }
        }
        return config;
    }


    SettingsPageSectionHeader {
        text: qsTr("Debug server")
    }

    SwitchDelegate {
        id: debugServerEnabledSwitch
        Layout.fillWidth: true
        text: qsTr("Debug server enabled")
        checked: engine.nymeaConfiguration.debugServerEnabled
        onToggled: engine.nymeaConfiguration.debugServerEnabled = checked
    }

    Label {
        Layout.fillWidth: true
        Layout.leftMargin: app.margins
        Layout.rightMargin: app.margins
        text: qsTr("In order to access the debug interface, please enable the web server.")
        font.pixelSize: app.smallFont
        color: "red"
        wrapMode: Text.WordWrap
        visible: engine.nymeaConfiguration.webServerConfigurations.count === 0
    }

    Label {
        Layout.fillWidth: true
        Layout.leftMargin: app.margins
        Layout.rightMargin: app.margins
        text: qsTr("The web server cannot be reached on %1.").arg(engine.jsonRpcClient.currentConnection.hostAddress)
        wrapMode: Text.WordWrap
        font.pixelSize: app.smallFont
        color: "red"
        visible: engine.nymeaConfiguration.webServerConfigurations.count > 0 && root.usedConfig === null
    }

    Label {
        Layout.fillWidth: true
        Layout.leftMargin: app.margins
        Layout.rightMargin: app.margins
        text: qsTr("Please enable the web server to be accessed on this address.")
        wrapMode: Text.WordWrap
        font.pixelSize: app.smallFont
        visible: engine.nymeaConfiguration.webServerConfigurations.count > 0 && root.usedConfig == null
    }

    Label {
        Layout.fillWidth: true
        Layout.margins: Style.margins
        wrapMode: Text.WordWrap
        visible: debugServerEnabledSwitch.checked && root.usedConfig != null
        text: {
            var proto = "http" + (root.usedConfig.sslEnabled ? "s" : "") + "://"
            var path = engine.jsonRpcClient.currentConnection.hostAddress + ":" + root.usedConfig.port + "/debug"
            return qsTr("Debug interface active at %1.").arg('<a href="' + proto + path + '">' + proto + path + '</a>')
        }
        onLinkActivated: Qt.openUrlExternally(link)
    }

    SettingsPageSectionHeader {
        text: qsTr("Server logging")
    }


    NymeaSwipeDelegate {
        Layout.fillWidth: true
        text: qsTr("Server logging categories")
        progressive: true
        onClicked: pageStack.push(Qt.resolvedUrl("ServerLoggingCategoriesPage.qml"))
    }

    // NymeaSwipeDelegate {
    //     Layout.fillWidth: true
    //     text: qsTr("Server live logs")
    //     progressive: true
    //     //onClicked: pageStack.push(Qt.resolvedUrl("PluginParamsPage.qml"), {plugin: plugin})
    // }

}

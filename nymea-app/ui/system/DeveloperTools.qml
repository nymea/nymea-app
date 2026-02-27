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

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Nymea

import "../components"

SettingsPageBase {
    id: root
    title: qsTr("Developer tools")

    readonly property string serverIpAddress: resolveServerIpAddress()
    readonly property var webServerConfiguration: resolveWebServerConfiguration()

    readonly property string dashboardUrl: {
        if (root.serverIpAddress === "" || root.webServerConfiguration === null) {
            return ""
        }

        var protocol = root.webServerConfiguration.sslEnabled ? "https" : "http"
        return protocol + "://" + root.serverIpAddress + ":" + root.webServerConfiguration.port + "/debug"
    }

    function normalizeAddress(address) {
        if (!address) {
            return ""
        }

        var normalizedAddress = address.toString().trim()
        var slashIndex = normalizedAddress.indexOf("/")
        if (slashIndex >= 0) {
            normalizedAddress = normalizedAddress.slice(0, slashIndex)
        }

        return normalizedAddress
    }

    NetworkManager {
        id: networkManager
        engine: _engine
    }

    function getActiveIpv4Address(networkDevices) {
        if (!networkDevices)
            return ""

        for (var i = 0; i < networkDevices.count; i++) {
            var networkDevice = networkDevices.get(i)
            if (!networkDevice || networkDevice.state !== NetworkDevice.NetworkDeviceStateActivated)
                continue

            for (var j = 0; j < networkDevice.ipv4Addresses.length; j++) {
                var address = root.normalizeAddress(networkDevice.ipv4Addresses[j])
                if (address !== "") {
                    return address
                }
            }
        }

        return ""
    }

    function resolveServerIpAddress() {
        var address = root.getActiveIpv4Address(networkManager.wiredNetworkDevices)
        if (address !== "") {
            console.log("--> server IP (LAN):", address)
            return address
        }

        address = root.getActiveIpv4Address(networkManager.wirelessNetworkDevices)
        if (address !== "")
            console.log("--> server IP (WLAN):", address)

        return address
    }

    function preferredConfiguration(currentConfiguration, candidateConfiguration) {
        if (currentConfiguration === null) {
            return candidateConfiguration
        }

        // Prefer http over https to avoid local self-signed certificate issues.
        if (currentConfiguration.sslEnabled && !candidateConfiguration.sslEnabled) {
            return candidateConfiguration
        }

        return currentConfiguration
    }

    function resolveWebServerConfiguration() {
        if (!engine || !engine.nymeaConfiguration)
            return null

        var exactMatchConfiguration = null
        var wildcardConfiguration = null

        for (var i = 0; i < engine.nymeaConfiguration.webServerConfigurations.count; i++) {
            var configuration = engine.nymeaConfiguration.webServerConfigurations.get(i)
            console.log("--->", (configuration.sslEnabled ? "https" : "http"), configuration.address, configuration.port)
            if (!configuration || configuration.address === "127.0.0.1")
                continue

            if (configuration.address === root.serverIpAddress) {
                exactMatchConfiguration = root.preferredConfiguration(exactMatchConfiguration, configuration)
                continue
            }

            if (configuration.address === "0.0.0.0") {
                wildcardConfiguration = root.preferredConfiguration(wildcardConfiguration, configuration)
            }
        }

        return exactMatchConfiguration !== null ? exactMatchConfiguration : wildcardConfiguration
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
        Layout.margins: Style.margins
        wrapMode: Text.WordWrap
        visible: engine.nymeaConfiguration.debugServerEnabled && root.serverIpAddress === ""
        color: "red"
        text: qsTr("No active LAN IPv4 address was found in the network settings.")
    }

    Label {
        Layout.fillWidth: true
        Layout.margins: Style.margins
        wrapMode: Text.WordWrap
        visible: engine.nymeaConfiguration.debugServerEnabled && root.serverIpAddress !== "" && root.webServerConfiguration === null
        color: "red"
        text: qsTr("No reachable web server configuration was found for %1. Please enable the web server on this address or on 0.0.0.0.").arg(root.serverIpAddress)
    }

    Label {
        Layout.fillWidth: true
        Layout.margins: Style.margins
        wrapMode: Text.WordWrap
        visible: engine.nymeaConfiguration.debugServerEnabled && root.dashboardUrl !== ""
        text: qsTr("The debug interface can only be reached from the LAN. If you are using the remote connection, the following link might not work.")
    }

    NymeaSwipeDelegate {
        Layout.fillWidth: true
        iconName: "qrc:/icons/stock_website.svg"
        text: qsTr("Open debug interface")
        subText: root.dashboardUrl
        prominentSubText: true
        wrapTexts: false
        visible: engine.nymeaConfiguration.debugServerEnabled && root.dashboardUrl !== ""
        progressive: true
        onClicked: { Qt.openUrlExternally(root.dashboardUrl) }
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
}

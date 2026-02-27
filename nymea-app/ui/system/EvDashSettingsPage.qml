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
import NymeaApp.Utils

import Nymea.EvDash

import "qrc:/ui/components"

SettingsPageBase {
    id: root

    readonly property string serverIpAddress: resolveServerIpAddress()
    readonly property var webServerConfiguration: resolveWebServerConfiguration()
    readonly property string dashboardUrl: {
        if (root.serverIpAddress === "" || root.webServerConfiguration === null) {
            return ""
        }

        var protocol = root.webServerConfiguration.sslEnabled ? "https" : "http"
        return protocol + "://" + root.serverIpAddress + ":" + root.webServerConfiguration.port + "/evdash"
    }

    function normalizeAddress(address) {
        if (!address)
            return ""

        var normalizedAddress = address.toString().trim()
        var slashIndex = normalizedAddress.indexOf("/")
        if (slashIndex >= 0)
            normalizedAddress = normalizedAddress.slice(0, slashIndex)

        return normalizedAddress
    }

    function getActiveIpv4Address(networkDevices) {
        if (!networkDevices) {
            return ""
        }

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
        if (currentConfiguration === null)
            return candidateConfiguration

        // Prefer non-SSL to avoid local self-signed certificate issues.
        if (currentConfiguration.sslEnabled && !candidateConfiguration.sslEnabled)
            return candidateConfiguration

        return currentConfiguration
    }

    function resolveWebServerConfiguration() {
        if (!evDashManager.engine || !evDashManager.engine.nymeaConfiguration)
            return null

        var exactMatchConfiguration = null
        var wildcardConfiguration = null

        for (var i = 0; i < evDashManager.engine.nymeaConfiguration.webServerConfigurations.count; i++) {
            var configuration = evDashManager.engine.nymeaConfiguration.webServerConfigurations.get(i)
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

    header: NymeaHeader {
        text: qsTr("EV Dash")
        onBackPressed: pageStack.pop()

        HeaderButton {
            imageSource: Qt.resolvedUrl("qrc:/icons/add.svg")
            onClicked: {
                var popup = addUserPopup.createObject(app);
                popup.open();
            }
        }
    }

    EvDashManager {
        id: evDashManager
        engine: _engine
    }

    NetworkManager {
        id: networkManager
        engine: _engine
    }

    Component {
        id: errorDialog
        ErrorDialog { }
    }

    Component {
        id: removeUserPopup

        NymeaDialog {
            id: removeUserDialog

            property string username

            headerIcon: "qrc:/icons/dialog-warning-symbolic.svg"
            standardButtons: Dialog.Yes | Dialog.No
            title: qsTr("Remove user")
            text: qsTr("Are you sure you want to remove \"%1\"?").arg(username)

            onAccepted:  {
                evDashManager.removeUser(username);
                removeUserDialog.close();
            }
        }
    }

    Connections {
        target: evDashManager
        onAddUserReply: (commandId, error) => {
            if (error === EvDashManager.EvDashErrorNoError)
                return

            var text;
            switch (error) {
            case EvDashManager.EvDashErrorDuplicateUser:
                text = qsTr("The given username is already in use. Please choose a different username.");
                break;
            case EvDashManager.EvDashErrorBadPassword:
                text = qsTr("The given password is not valid.");
                break;
            default:
                text = qsTr("Un unexpected error happened when creating the user. We're sorry for this. (Error code: %1)").arg(error);
                break;
            }

            var popup = errorDialog.createObject(app, {text: text});
            popup.open()
        }

        onRemoveUserReply: (commandId, error) => {
            if (error === EvDashManager.EvDashErrorNoError)
                return

            var text;
            switch (error) {
            case EvDashManager.EvDashErrorDuplicateUser:
                text = qsTr("The given username is already in use. Please choose a different username.");
                break;
            case EvDashManager.EvDashErrorBadPassword:
                text = qsTr("The given password is not valid.");
                break;
            default:
                text = qsTr("Un unexpected error happened when creating the user. We're sorry for this. (Error code: %1)").arg(error);
                break;
            }

            var popup = errorDialog.createObject(app, {text: text});
            popup.open()
        }
    }

    SwitchDelegate {
        text: qsTr("Dashboard enabled")
        checked: evDashManager.enabled
        onCheckedChanged: evDashManager.enabled = checked
        Layout.fillWidth: true
    }

    Label {
        Layout.fillWidth: true
        Layout.margins: Style.margins
        wrapMode: Text.WordWrap
        visible: evDashManager.enabled
        text: qsTr("The dashboard can only be reached from the LAN. If you are using the remote connection, the following link might not work.")
    }

    Label {
        Layout.fillWidth: true
        Layout.margins: Style.margins
        wrapMode: Text.WordWrap
        visible: evDashManager.enabled && root.serverIpAddress === ""
        color: "red"
        text: qsTr("No active LAN IPv4 address was found in the network settings.")
    }

    Label {
        Layout.fillWidth: true
        Layout.margins: Style.margins
        wrapMode: Text.WordWrap
        visible: evDashManager.enabled && root.serverIpAddress !== "" && root.webServerConfiguration === null
        color: "red"
        text: qsTr("No reachable web server configuration was found for %1. Please enable the web server on this address or on 0.0.0.0.").arg(root.serverIpAddress)
    }

    NymeaSwipeDelegate {
        Layout.fillWidth: true
        iconName: "qrc:/icons/stock_website.svg"
        text: qsTr("Open EVDash")
        subText: root.dashboardUrl
        prominentSubText: true
        wrapTexts: false
        visible: evDashManager.enabled && root.dashboardUrl !== ""
        progressive: true
        onClicked: { Qt.openUrlExternally(root.dashboardUrl) }
    }

    SettingsPageSectionHeader {
        text: qsTr("Manage users")
    }

    Repeater {
        id: usersList

        model: evDashManager.users
        delegate: NymeaItemDelegate {
            Layout.fillWidth: true
            text: model.name
            iconName: "account"
            progressive: false
            additionalItem: ColorIcon {
                name: "delete"
                color: Style.foregroundColor
                anchors.verticalCenter:  parent.verticalCenter
            }

            onClicked: {
                var popup = removeUserPopup.createObject(app, {username: model.name});
                popup.open()
            }
        }
    }

    Component {
        id: addUserPopup

        NymeaDialog {
            id: addUserDialog

            title: qsTr("Create a new user")
            standardButtons: Dialog.NoButton

            NymeaTextField {
                id: usernameTextField
                placeholderText: qsTr("Username")
                Layout.fillWidth: true
            }

            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: Style.margins
            }

            PasswordTextField {
                id: passwordTextField

                Layout.fillWidth: true
                minPasswordLength: 4
                requireSpecialChar: false
                requireNumber: false
                requireUpperCaseLetter: false
                requireLowerCaseLetter: false
            }

            Button {
                Layout.fillWidth: true
                text: qsTr("Add user")
                onClicked: {
                    evDashManager.addUser(usernameTextField.text, passwordTextField.password)
                    addUserDialog.close()
                }
            }

            Button {
                Layout.fillWidth: true
                text: qsTr("Cancel")
                onClicked: {
                    addUserDialog.close()
                }
            }
        }
    }
}

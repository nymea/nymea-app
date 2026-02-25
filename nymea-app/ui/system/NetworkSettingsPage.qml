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
import QtQuick.Controls.Material
import QtQuick.Layouts
import QtCore

import Nymea
import "qrc:/ui/components"

SettingsPageBase {
    id: root
    title: qsTr("Network settings")
    busy: networkManager.loading || d.pendingCallId !== -1

    NetworkManager {
        id: networkManager
        engine: _engine
        onEnableNetworkingReply: handleReply(id, status)
        onEnableWirelessNetworkingReply: handleReply(id, status)
        onConnectToWiFiReply: handleReply(id, status)
        onStartAccessPointReply: handleReply(id, status)
        onDisconnectReply: handleReply(id, status)
        onCreateWiredAutoConnectionReply: handleReply(id, status)
        onCreateWiredManualConnectionReply: handleReply(id, status)
        onCreateWiredSharedConnectionReply: handleReply(id, status)

        function handleReply(id, status) {
            if (id === d.pendingCallId) {
                d.pendingCallId = -1
            }

            var errorMessage;
            switch (status) {
            case "NetworkManagerErrorNoError":
                return;
            case "NetworkManagerErrorWirelessNotAvailable":
                errorMessage = qsTr("No wireless hardware available.")
                break;
            case "NetworkManagerErrorAccessPointNotFound":
                errorMessage = qsTr("The access point cannot be found.")
                break;
            case "NetworkManagerErrorNetworkInterfaceNotFound":
                errorMessage = qsTr("The network interface cannot be found.")
                break;
            case "NetworkManagerErrorInvalidNetworkDeviceType":
                errorMessage = qsTr("Invalid network device type.")
                break;
            case "NetworkManagerErrorWirelessNetworkingDisabled":
                errorMessage = qsTr("Wireless networking is disabled.")
                break;
            case "NetworkManagerErrorWirelessConnectionFailed":
                errorMessage = qsTr("The wireless connection failed.")
                break;
            case "NetworkManagerErrorNetworkingDisabled":
                errorMessage = qsTr("Networking is disabled.")
                break;
            case "NetworkManagerErrorNetworkManagerNotAvailable":
                errorMessage = qsTr("The network manager is not available.")
                break;
            case "NetworkManagerErrorInvalidConfiguration":
                errorMessage = qsTr("The network configuration is not valid.")
                break;
            case "NetworkManagerErrorUnsupportedFeature":
                errorMessage = qsTr("This feature is not supported on this platform.")
                break;
            case "NetworkManagerErrorUnknownError":
                errorMessage = qsTr("An unexpected error happened.")
                break;
            }
            print("network config reply:", status, errorMessage)

            var component = Qt.createComponent(Qt.resolvedUrl("../components/ErrorDialog.qml"))
            var popup = component.createObject(root, {text: errorMessage, errorCode: status})
            popup.open();
        }
    }

    QtObject {
        id: d
        property int pendingCallId: -1
    }

    function networkStateToString(networkState, mode) {
        switch (networkState) {
        case NetworkDevice.NetworkDeviceStateUnknown:
            return qsTr("Unknown")
        case NetworkDevice.NetworkDeviceStateUnmanaged:
            return qsTr("Unmanaged")
        case NetworkDevice.NetworkDeviceStateUnavailable:
            return qsTr("Unavailable")
        case NetworkDevice.NetworkDeviceStateDisconnected:
            return qsTr("Disconnected")
        case NetworkDevice.NetworkDeviceStateDeactivating:
            return qsTr("Deactivating")
        case NetworkDevice.NetworkDeviceStateFailed:
            return qsTr("Failed")
        case NetworkDevice.NetworkDeviceStatePrepare:
            return qsTr("Preparing")
        case NetworkDevice.NetworkDeviceStateConfig:
            return qsTr("Configuring")
        case NetworkDevice.NetworkDeviceStateNeedAuth:
            return qsTr("Waiting for password")
        case NetworkDevice.NetworkDeviceStateIpConfig:
            return qsTr("Setting IP configuration")
        case NetworkDevice.NetworkDeviceStateIpCheck:
            return qsTr("Checking IP configuration")
        case NetworkDevice.NetworkDeviceStateSecondaries:
            return qsTr("Secondaries")
        case NetworkDevice.NetworkDeviceStateActivated:
            if (mode === WirelessNetworkDevice.WirelessModeAccessPoint) {
                return qsTr("Hosting access point");
            } else {
                return qsTr("Connected");
            }
        }
    }

    RowLayout {
        Layout.topMargin: app.margins * 6
        Layout.leftMargin: app.margins
        Layout.rightMargin: app.margins
        visible: !networkManager.available && !networkManager.loading
        spacing: app.margins
        ColorIcon {
            Layout.preferredHeight: Style.iconSize
            Layout.preferredWidth: Style.iconSize
            name: "qrc:/icons/connections/network-wired-disabled.svg"
        }
        Label {
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
            text: qsTr("Network management is unavailable on this system.")
        }
    }


    SettingsPageSectionHeader {
        text: qsTr("General")
        visible: networkManager.available
    }

    NymeaItemDelegate {
        Layout.fillWidth: true
        text: qsTr("Current connection state")
        prominentSubText: false
        visible: networkManager.available
        subText: {
            switch (networkManager.state) {
            case NetworkManager.NetworkManagerStateUnknown:
                return qsTr("Unknown");
            case NetworkManager.NetworkManagerStateAsleep:
                return qsTr("Asleep");
            case NetworkManager.NetworkManagerStateDisconnected:
                return qsTr("Disconnected")
            case NetworkManager.NetworkManagerStateDisconnecting:
                return qsTr("Disconnecting")
            case NetworkManager.NetworkManagerStateConnecting:
                return qsTr("Connecting")
            case NetworkManager.NetworkManagerStateConnectedLocal:
                return qsTr("Locally connected")
            case NetworkManager.NetworkManagerStateConnectedSite:
                return qsTr("Site connected")
            case NetworkManager.NetworkManagerStateConnectedGlobal:
                return qsTr("Globally connected")

            }
        }
        progressive: false
        additionalItem: Led {
            anchors.verticalCenter: parent.verticalCenter
            state: {
                switch (networkManager.state) {
                case NetworkManager.NetworkManagerStateUnknown:
                case NetworkManager.NetworkManagerStateAsleep:
                    return "off";
                case NetworkManager.NetworkManagerStateDisconnected:
                case NetworkManager.NetworkManagerStateDisconnecting:
                    return "red"
                case NetworkManager.NetworkManagerStateConnecting:
                case NetworkManager.NetworkManagerStateConnectedLocal:
                case NetworkManager.NetworkManagerStateConnectedSite:
                    return "orange"
                case NetworkManager.NetworkManagerStateConnectedGlobal:
                    return "green";

                }
            }
        }
    }

    NymeaItemDelegate {
        Layout.fillWidth: true
        text: qsTr("Networking enabled")
        subText: qsTr("Enable or disable networking altogether")
        prominentSubText: false
        progressive: false
        visible: networkManager.available
        additionalItem: Switch {
            anchors.verticalCenter: parent.verticalCenter
            checked: networkManager.networkingEnabled
            onClicked: {
                if (!checked) {
                    var dialog = Qt.createComponent(Qt.resolvedUrl("../components/NymeaDialog.qml"));
                    var text = qsTr("Disabling networking will disconnect all connected clients. Be aware that you will not be able to interact remotely with this %1 system any more. Do not proceed unless you know what your are doing.").arg(Configuration.systemName)
                            + "\n\n"
                            + qsTr("Do you want to proceed?")
                    var popup = dialog.createObject(app,
                                                    {
                                                        headerIcon: "qrc:/icons/dialog-warning-symbolic.svg",
                                                        title: qsTr("Disable networking?"),
                                                        text: text,
                                                        standardButtons: Dialog.Ok | Dialog.Cancel
                                                    });
                    popup.open();
                    popup.accepted.connect(function() {
                        d.pendingCallId = networkManager.enableNetworking(false);
                    })
                    popup.rejected.connect(function() {
                        checked = true;
                    })
                } else {
                    d.pendingCallId = networkManager.enableNetworking(true);
                }
            }
        }
    }

    SettingsPageSectionHeader {
        text: qsTr("Wired network")
        visible: networkManager.available && networkManager.networkingEnabled
    }

    Label {
        Layout.fillWidth: true
        Layout.leftMargin: app.margins
        Layout.rightMargin: app.margins
        text: qsTr("No wired network interfaces available")
        wrapMode: Text.WordWrap
        visible: networkManager.available && networkManager.networkingEnabled && networkManager.wiredNetworkDevices.count == 0
    }

    Repeater {
        model: networkManager.wiredNetworkDevices

        NymeaItemDelegate {
            Layout.fillWidth: true
            iconName: model.pluggedIn ? "qrc:/icons/connections/network-wired.svg" : "qrc:/icons/connections/network-wired-offline.svg"
            text: model.interface + " (" + model.macAddress + ")"
            visible: networkManager.available && networkManager.networkingEnabled
            subText: {
                var ret = model.pluggedIn ? qsTr("Plugged in") : qsTr("Unplugged")
                ret += " - "
                ret += networkStateToString(model.state)
                return ret;
            }
            progressive: engine.jsonRpcClient.ensureServerVersion("6.2")
            onClicked: {
                if (!engine.jsonRpcClient.ensureServerVersion("6.2")) {
                    return;
                }

                var wiredNetworkDevice = networkManager.wiredNetworkDevices.getWiredNetworkDevice(model.interface);
                if (wiredNetworkDevice.state === NetworkDevice.NetworkDeviceStateDisconnected) {
                    pageStack.push(createWiredConnectionPageComponent, {wiredNetworkDevice: wiredNetworkDevice})
                } else {
                    pageStack.push(currentEthernetConnectionPageComponent, {wiredNetworkDevice: wiredNetworkDevice})
                }
            }
        }
    }

    SettingsPageSectionHeader {
        text: qsTr("Wireless network")
        visible: networkManager.available && networkManager.networkingEnabled
    }

    NymeaItemDelegate {
        Layout.fillWidth: true
        text: qsTr("Enabled")
        subText: qsTr("Enable or disable WiFi")
        progressive: false
        prominentSubText: false
        visible: networkManager.available && networkManager.networkingEnabled
        additionalItem: Switch {
            anchors.verticalCenter: parent.verticalCenter
            checked: networkManager.wirelessNetworkingEnabled
            visible: networkManager.available && networkManager.networkingEnabled
            onClicked: {
                if (!checked) {
                    var dialog = Qt.createComponent(Qt.resolvedUrl("../components/NymeaDialog.qml"));
                    var text = qsTr("Disabling WiFi will disconnect all clients connected via WiFi. Be aware that you will not be able to interact remotely with this %1 system any more unless a LAN cable is connected.").arg(Configuration.systemName)
                            + "\n\n"
                            + qsTr("Do you want to proceed?")
                    var popup = dialog.createObject(app,
                                                    {
                                                        headerIcon: "qrc:/icons/dialog-warning-symbolic.svg",
                                                        title: qsTr("Disable WiFi?"),
                                                        text: text,
                                                        standardButtons: Dialog.Ok | Dialog.Cancel
                                                    });
                    popup.open();
                    popup.accepted.connect(function() {
                        d.pendingCallId = networkManager.enableWirelessNetworking(false);
                    })
                    popup.rejected.connect(function() {
                        checked = true;
                    })
                } else {
                    d.pendingCallId = networkManager.enableWirelessNetworking(true);
                }
            }
        }
    }

    Label {
        Layout.fillWidth: true
        Layout.leftMargin: app.margins
        Layout.rightMargin: app.margins
        text: qsTr("No wireless network interfaces available")
        wrapMode: Text.WordWrap
        visible: networkManager.available && networkManager.wirelessNetworkDevices.count == 0
    }

    Repeater {
        model: networkManager.wirelessNetworkDevices
        NymeaSwipeDelegate {
            Layout.fillWidth: true
            visible: networkManager.available && networkManager.networkingEnabled
            iconName: {
                switch (model.state) {
                case NetworkDevice.NetworkDeviceStateUnknown:
                case NetworkDevice.NetworkDeviceStateUnmanaged:
                case NetworkDevice.NetworkDeviceStateUnavailable:
                case NetworkDevice.NetworkDeviceStateDisconnected:
                case NetworkDevice.NetworkDeviceStateDeactivating:
                case NetworkDevice.NetworkDeviceStateFailed:
                    return "qrc:/icons/connections/network-wifi-offline.svg"
                case NetworkDevice.NetworkDeviceStatePrepare:
                    return "qrc:/icons/connections/network-wifi.svg";
                case NetworkDevice.NetworkDeviceStateConfig:
                    return "qrc:/icons/connections/network-wifi-offline.svg"
                case NetworkDevice.NetworkDeviceStateNeedAuth:
                    return "qrc:/icons/connections/network-wifi.svg";
                case NetworkDevice.NetworkDeviceStateIpConfig:
                    return "qrc:/icons/connections/network-wifi-offline.svg"
                case NetworkDevice.NetworkDeviceStateIpCheck:
                    return "qrc:/icons/connections/network-wifi.svg";
                case NetworkDevice.NetworkDeviceStateSecondaries:
                    return "qrc:/icons/connections/network-wifi-offline.svg"
                case NetworkDevice.NetworkDeviceStateActivated:
                    return "qrc:/icons/connections/network-wifi.svg";

                }
                console.warn("Unhandled enum", model.state)
            }
            text: model.interface + " (" + model.macAddress + ")"
            subText: networkStateToString(model.state, model.wirelessMode)
            onClicked: {
                print("*** --", model.wirelessMode)
                var wirelessNetworkDevice = networkManager.wirelessNetworkDevices.getWirelessNetworkDevice(model.interface);
                if (wirelessNetworkDevice.state === NetworkDevice.NetworkDeviceStateDisconnected) {
                    networkManager.refreshWifis(model.interface)
                    pageStack.push(wirelessAccessPointsPageComponent, {wirelessNetworkDevice: wirelessNetworkDevice})
                } else {
                    pageStack.push(currentApPageComponent, {wirelessNetworkDevice: wirelessNetworkDevice})
                }
            }
        }
    }

    Component {
        id: wirelessAccessPointsPageComponent
        SettingsPageBase {
            id: wirelessAccessPointsPage
            title: qsTr("WiFi networks")

            property WirelessNetworkDevice wirelessNetworkDevice: null

            property bool apFeatureAvailable: wirelessNetworkDevice &&
                                              wirelessNetworkDevice.wirelessCapabilities !== WirelessNetworkDevice.WirelessCapabilityNone &&
                                              wirelessNetworkDevice.wirelessCapabilities | WirelessNetworkDevice.WirelessCapabilityAP

            SettingsPageSectionHeader {
                text: qsTr("Access Point")
                visible: apFeatureAvailable
            }

            TextField {
                id: ssidTextField
                Layout.fillWidth: true
                maximumLength: 32
                Layout.leftMargin: app.margins
                Layout.rightMargin: app.margins
                placeholderText: qsTr("SSID")
                visible: apFeatureAvailable
            }

            ConsolinnoPasswordTextField {
                id: passwordTextField
                Layout.fillWidth: true
                minPasswordLength: 8
                Layout.leftMargin: app.margins
                Layout.rightMargin: app.margins
                requireLowerCaseLetter: false
                requireUpperCaseLetter: false
                requireNumber: false
                requireSpecialChar: false
                signup: false
                visible: apFeatureAvailable
            }

            Button {
                Layout.fillWidth: true
                Layout.margins: app.margins
                Layout.leftMargin: app.margins
                Layout.rightMargin: app.margins
                text: qsTr("Create Access Point")
                enabled: ssidTextField.displayText.length > 0 && passwordTextField.isValidPassword
                visible: apFeatureAvailable
                onClicked: {
                    d.pendingCallId = networkManager.startAccessPoint(wirelessAccessPointsPage.wirelessNetworkDevice.interface, ssidTextField.text, passwordTextField.password)
                    pageStack.pop(root);
                }
            }

            Settings {
                id: settings
                property bool wirelessShowDuplicates: false
            }

            WirelessAccessPointsProxy {
                id: apProxy
                accessPoints: wirelessAccessPointsPage.wirelessNetworkDevice ? wirelessAccessPointsPage.wirelessNetworkDevice.accessPoints : null
                showDuplicates: settings.wirelessShowDuplicates
            }

            RowLayout {
                Layout.fillWidth: true
                SettingsPageSectionHeader {
                    Layout.fillWidth: true
                    text: qsTr("Connect to wireless network")
                }

                HeaderButton {
                    id: filterButton
                    imageSource: "qrc:/icons/filters.svg"
                    color: Style.iconColor
                    onClicked: pageStack.push(Qt.createComponent("/ui/system/WirelessNetworksFilterSettingsPage.qml"),
                                                                      { wirelessAccessPointsProxy: apProxy });
                }
            }

            Repeater {
                id: listView
                model: apProxy
                delegate: NymeaSwipeDelegate {
                    Layout.fillWidth: true
                    text: model.ssid !== "" ? model.ssid : qsTr("Hidden Network")
                    subText: "%1 (%2)".arg(model.macAddress).arg(model.frequency < 3 ? "2.4GHz" : "5GHz")
                    prominentSubText: false
                    iconName: {
                        var ret = "qrc:/icons/connections/nm-signal-";
                        if (model.signalStrength > 90) {
                            ret += "100";
                        } else if (model.signalStrength > 60) {
                            ret += "75";
                        } else if (model.signalStrength > 40) {
                            ret += "50";
                        } else if (model.signalStrength > 20) {
                            ret += "25";
                        } else {
                            ret += "00";
                        }
                        if (model.isProtected) {
                            ret += "-secure"
                        }
                        ret += ".svg";
                        return ret;
                    }

                    onClicked: {
                        print("pushing", wirelessAccessPointsPage.wirelessNetworkDevice.state)
                        pageStack.push(authPageComponent, {wirelessNetworkDevice: wirelessAccessPointsPage.wirelessNetworkDevice, wirelessAccessPoint: apProxy.get(index)})
                    }
                }
            }
        }
    }

    Component {
        id: createWiredConnectionPageComponent
        SettingsPageBase {
            id: createWiredConnectionPage
            title: qsTr("New wired connection")

            property WiredNetworkDevice wiredNetworkDevice: null

            SettingsPageSectionHeader {
                text: qsTr("Method")
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.leftMargin: app.margins
                Layout.rightMargin: app.margins
                spacing: 0

                RadioButton {
                    id: dhcpClientRadioButton
                    Layout.fillWidth: true
                    checked: true
                    text: qsTr("Automatic (DHCP client)")
                }
                RadioButton {
                    id: manualClientRadioButton
                    Layout.fillWidth: true
                    text: qsTr("Manual")
                }
                RadioButton {
                    id: dhcpServerRadioButton
                    Layout.fillWidth: true
                    text: qsTr("Shared (DHCP server)")
                }
            }

            SettingsPageSectionHeader {
                text: qsTr("Address settings")
                visible: manualClientRadioButton.checked
            }

            GridLayout {
                Layout.fillWidth: true
                Layout.leftMargin: app.margins
                Layout.rightMargin: app.margins
                columns: 2
                visible: manualClientRadioButton.checked


                Label {
                    text: qsTr("IP Address")
                }

                RowLayout {
                    TextField {
                        id: ipTextField
                        maximumLength: 32
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignRight
                        validator: RegularExpressionValidator {
                            regularExpression:  /^((?:[0-1]?[0-9]?[0-9]|2[0-4][0-9]|25[0-5])\.){0,3}(?:[0-1]?[0-9]?[0-9]|2[0-4][0-9]|25[0-5])$/
                        }
                    }

                    Label {
                        text: "/"
                    }
                    TextField {
                        id: prefixTextField
                        text: "24"
                        Layout.fillWidth: false
                        validator: IntValidator {
                            bottom: 8
                            top: 32
                        }
                    }
                }

                Label {
                    text: qsTr("Gateway")
                }

                TextField {
                    id: defaultGwTextField
                    maximumLength: 32
                    Layout.fillWidth: true
                    validator: RegularExpressionValidator {
                        regularExpression:  /^((?:[0-1]?[0-9]?[0-9]|2[0-4][0-9]|25[0-5])\.){0,3}(?:[0-1]?[0-9]?[0-9]|2[0-4][0-9]|25[0-5])$/
                    }
                }

                Label {
                    text: qsTr("DNS")
                }

                TextField {
                    id: dnsTextField
                    maximumLength: 32
                    Layout.fillWidth: true
                    validator: RegularExpressionValidator {
                        regularExpression:  /^((?:[0-1]?[0-9]?[0-9]|2[0-4][0-9]|25[0-5])\.){0,3}(?:[0-1]?[0-9]?[0-9]|2[0-4][0-9]|25[0-5])$/
                    }
                }
            }

            Button {
                Layout.fillWidth: true
                Layout.margins: app.margins
                Layout.leftMargin: app.margins
                Layout.rightMargin: app.margins
                text: qsTr("Create connection")
                enabled: {
                    if (dhcpClientRadioButton.checked || dhcpServerRadioButton.checked) {
                        return true;
                    }
                    return ipTextField.acceptableInput && prefixTextField.acceptableInput
                }

                onClicked: {
                    if (dhcpClientRadioButton.checked) {
                        d.pendingCallId = networkManager.createWiredAutoConnection(createWiredConnectionPage.wiredNetworkDevice.interface)
                    } else if (manualClientRadioButton.checked) {
                        d.pendingCallId = networkManager.createWiredManualConnection(createWiredConnectionPage.wiredNetworkDevice.interface, ipTextField.text, prefixTextField.text, defaultGwTextField.text, dnsTextField.text)
                    } else if (dhcpServerRadioButton.checked) {
                        d.pendingCallId = networkManager.createWiredSharedConnection(createWiredConnectionPage.wiredNetworkDevice.interface)
                    }

                    pageStack.pop(root);
                }
            }
        }
    }

    Component {
        id: authPageComponent
        SettingsPageBase {
            id: authPage
            title: qsTr("Authenticate")

            property var wirelessNetworkDevice: null
            property var wirelessAccessPoint: null


            Label {
                Layout.fillWidth: true
                Layout.margins: app.margins
                text: qsTr("Enter the password for %1").arg(authPage.wirelessAccessPoint.ssid)
                wrapMode: Text.WordWrap
            }
            RowLayout {
                Layout.leftMargin: app.margins; Layout.rightMargin: app.margins
                TextField {
                    id: passwordTextField
                    Layout.fillWidth: true
                    property bool showPassword: false
                    echoMode: showPassword ? TextInput.Normal : TextInput.Password
                }

                ColorIcon {
                    Layout.preferredHeight: Style.iconSize
                    Layout.preferredWidth: Style.iconSize
                    name: "qrc:/icons/eye.svg"
                    color: passwordTextField.showPassword ? Style.accentColor : Style.iconColor
                    MouseArea {
                        anchors.fill: parent
                        onClicked: passwordTextField.showPassword = !passwordTextField.showPassword
                    }
                }
            }
            Button {
                Layout.fillWidth: true
                Layout.margins: app.margins
                text: qsTr("OK")
                enabled: passwordTextField.displayText.length >= 8
                onClicked: {
                    d.pendingCallId = networkManager.connectToWiFi(authPage.wirelessNetworkDevice.interface, authPage.wirelessAccessPoint.ssid, passwordTextField.text)
                    pageStack.pop(root);
                }
            }

        }
    }

    Component {
        id: currentEthernetConnectionPageComponent
        SettingsPageBase {
            id: currentEthernetConnectionPage
            title: qsTr("Current connection")

            property WiredNetworkDevice wiredNetworkDevice: null

            SettingsPageSectionHeader {
                text: qsTr("Connected to")
            }

            NymeaItemDelegate {
                Layout.fillWidth: true
                text: qsTr("IPv4 Address")
                subText: currentEthernetConnectionPage.wiredNetworkDevice.ipv4Addresses.join(", ")
                progressive: false
            }
            NymeaItemDelegate {
                Layout.fillWidth: true
                text: qsTr("IPv6 Address")
                subText: currentEthernetConnectionPage.wiredNetworkDevice.ipv6Addresses.join(", ")
                visible: subText.length > 0
                progressive: false
            }
            NymeaItemDelegate {
                Layout.fillWidth: true
                text: qsTr("MAC Address")
                subText: currentEthernetConnectionPage.wiredNetworkDevice.macAddress
                progressive: false
            }

            Button {
                Layout.fillWidth: true
                Layout.margins: app.margins
                text: qsTr("Disconnect")
                onClicked: {
                    d.pendingCallId = networkManager.disconnectInterface(currentEthernetConnectionPage.wiredNetworkDevice.interface)
                    pageStack.pop(root);
                }
            }
        }
    }

    Component {
        id: currentApPageComponent
        SettingsPageBase {
            id: currentApPage
            title: qsTr("Current connection")

            property WirelessNetworkDevice wirelessNetworkDevice: null

            SettingsPageSectionHeader {
                text: wirelessNetworkDevice.wirelessMode === WirelessNetworkDevice.WirelessModeAccessPoint ? qsTr("Hosting access point") : qsTr("Connected to")
            }

            NymeaSwipeDelegate {
                Layout.fillWidth: true
                text: qsTr("SSID")
                subText: currentApPage.wirelessNetworkDevice.currentAccessPoint.ssid
                progressive: false
            }

            NymeaSwipeDelegate {
                Layout.fillWidth: true
                text: qsTr("IPv4 Address")
                subText: currentApPage.wirelessNetworkDevice.ipv4Addresses.join(", ")
                progressive: false
            }
            NymeaSwipeDelegate {
                Layout.fillWidth: true
                text: qsTr("IPv6 Address")
                subText: currentApPage.wirelessNetworkDevice.ipv6Addresses.join(", ")
                visible: subText.length > 0
                progressive: false
            }
            NymeaSwipeDelegate {
                Layout.fillWidth: true
                text: qsTr("MAC Address")
                subText: currentApPage.wirelessNetworkDevice.currentAccessPoint.macAddress
                progressive: false
            }
            NymeaSwipeDelegate {
                Layout.fillWidth: true
                text: qsTr("Signal strength")
                subText: currentApPage.wirelessNetworkDevice.currentAccessPoint.signalStrength + " %"
                progressive: false
            }
            NymeaSwipeDelegate {
                Layout.fillWidth: true
                text: qsTr("WiFi frequency")
                subText: currentApPage.wirelessNetworkDevice.currentAccessPoint.frequency + " GHz"
                progressive: false
            }

            Button {
                Layout.fillWidth: true
                Layout.margins: app.margins
                text: qsTr("Disconnect")
                onClicked: {
                    d.pendingCallId = networkManager.disconnectInterface(currentApPage.wirelessNetworkDevice.interface)
                    pageStack.pop(root);
                }
            }
        }
    }
}

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

import QtQuick 2.9
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.1
import Nymea 1.0
import "../components"

SettingsPageBase {
    id: root
    title: qsTr("Network settings")

    NetworkManager {
        id: networkManager
        engine: _engine
    }

    function networkStateToString(networkState) {
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
            return qsTr("Connected");
        }
    }

    SettingsPageSectionHeader {
        text: qsTr("General")
    }

    NymeaListItemDelegate {
        Layout.fillWidth: true
        text: qsTr("Current connection state")
        prominentSubText: false
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

    NymeaListItemDelegate {
        Layout.fillWidth: true
        text: qsTr("Networking enabled")
        subText: qsTr("Enable or disable networking altogether")
        prominentSubText: false
        progressive: false
        additionalItem: Switch {
            anchors.verticalCenter: parent.verticalCenter
            checked: networkManager.networkingEnabled
            onClicked: {
                if (!checked) {
                    var dialog = Qt.createComponent(Qt.resolvedUrl("../components/MeaDialog.qml"));
                    var text = qsTr("Disabling networking will disconnect all connected clients. Be aware that you will not be able to interact remotely with this %1 system any more. Do not proceed unless you know what your are doing.").arg(app.systemName)
                            + "\n\n"
                            + qsTr("Do you want to proceed?")
                    var popup = dialog.createObject(app,
                                                    {
                                                        headerIcon: "../images/dialog-warning-symbolic.svg",
                                                        title: qsTr("Disable networking?"),
                                                        text: text,
                                                        standardButtons: Dialog.Ok | Dialog.Cancel
                                                    });
                    popup.open();
                    popup.accepted.connect(function() {
                        networkManager.enableNetworking(false);
                    })
                    popup.rejected.connect(function() {
                        checked = true;
                    })
                } else {
                    networkManager.enableNetworking(true);
                }
            }
        }
    }

    SettingsPageSectionHeader {
        text: qsTr("Wired network")
    }

    Label {
        Layout.fillWidth: true
        Layout.leftMargin: app.margins
        Layout.rightMargin: app.margins
        text: qsTr("No wired network interfaces available")
        wrapMode: Text.WordWrap
        visible: networkManager.wiredNetworkDevices.count == 0
    }

    Repeater {
        model: networkManager.wiredNetworkDevices
        NymeaListItemDelegate {
            Layout.fillWidth: true
            iconName: model.pluggedIn ? "../images/network-wired.svg" : "../images/network-wired-offline.svg"
            text: model.interface + " (" + model.macAddress + ")"
            subText: {
                var ret = model.pluggedIn ? qsTr("Plugged in") : qsTr("Unplugged")
                ret += " - "
                ret += networkStateToString(model.state)
                return ret;
            }
            progressive: false
        }
    }

    SettingsPageSectionHeader {
        text: qsTr("Wireless network")
    }

    NymeaListItemDelegate {
        Layout.fillWidth: true
        text: qsTr("Enabled")
        subText: qsTr("Enable or disable WiFi")
        progressive: false
        prominentSubText: false
        additionalItem: Switch {
            anchors.verticalCenter: parent.verticalCenter
            checked: networkManager.wirelessNetworkingEnabled
            onClicked: {
                if (!checked) {
                    var dialog = Qt.createComponent(Qt.resolvedUrl("../components/MeaDialog.qml"));
                    var text = qsTr("Disabling WiFi will disconnect all clients connected via WiFi. Be aware that you will not be able to interact remotely with this %1 system any more unless a LAN cable is connected.").arg(app.systemName)
                            + "\n\n"
                            + qsTr("Do you want to proceed?")
                    var popup = dialog.createObject(app,
                                                    {
                                                        headerIcon: "../images/dialog-warning-symbolic.svg",
                                                        title: qsTr("Disable WiFi?"),
                                                        text: text,
                                                        standardButtons: Dialog.Ok | Dialog.Cancel
                                                    });
                    popup.open();
                    popup.accepted.connect(function() {
                        networkManager.enableWirelessNetworking(false);
                    })
                    popup.rejected.connect(function() {
                        checked = true;
                    })
                } else {
                    networkManager.enableWirelessNetworking(true);
                }
            }
        }
    }

    Label {
        Layout.fillWidth: true
        Layout.leftMargin: app.margins
        Layout.rightMargin: app.margins
        text: qsTr("No wired network interfaces available")
        wrapMode: Text.WordWrap
        visible: networkManager.wirelessNetworkDevices.count == 0
    }

    Repeater {
        model: networkManager.wirelessNetworkDevices
        NymeaListItemDelegate {
            Layout.fillWidth: true
            iconName: {
                switch (model.state) {
                case NetworkDevice.NetworkDeviceStateUnknown:
                case NetworkDevice.NetworkDeviceStateUnmanaged:
                case NetworkDevice.NetworkDeviceStateUnavailable:
                case NetworkDevice.NetworkDeviceStateDisconnected:
                case NetworkDevice.NetworkDeviceStateDeactivating:
                case NetworkDevice.NetworkDeviceStateFailed:
                    return "../images/network-wifi-offline.svg"
                case NetworkDevice.NetworkDeviceStatePrepare:
                    return "../images/network-wifi.svg";
                case NetworkDevice.NetworkDeviceStateConfig:
                    return "../images/network-wifi-offline.svg"
                case NetworkDevice.NetworkDeviceStateNeedAuth:
                    return "../images/network-wifi.svg";
                case NetworkDevice.NetworkDeviceStateIpConfig:
                    return "../images/network-wifi-offline.svg"
                case NetworkDevice.NetworkDeviceStateIpCheck:
                    return "../images/network-wifi.svg";
                case NetworkDevice.NetworkDeviceStateSecondaries:
                    return "../images/network-wifi-offline.svg"
                case NetworkDevice.NetworkDeviceStateActivated:
                    return "../images/network-wifi.svg";

                }
                console.warn("Unhandled enum", model.state)
            }
            text: model.interface + " (" + model.macAddress + ")"
            subText: networkStateToString(model.state)
            onClicked: {
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

            property var wirelessNetworkDevice: null

            WirelessAccessPointsProxy {
                id: apProxy
                accessPoints: wirelessAccessPointsPage.wirelessNetworkDevice.accessPoints
            }

            Repeater {
                id: listView
                model: apProxy
                delegate: NymeaListItemDelegate {
                    Layout.fillWidth: true
                    text: model.ssid
                    subText: model.macAddress
                    iconName: {
                        var ret = "../images/nm-signal-";
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

                    progressive: false
                    prominentSubText: false
                    onClicked: {
                        print("pushing", wirelessAccessPointsPage.wirelessNetworkDevice.state)
                        pageStack.push(authPageComponent, {wirelessNetworkDevice: wirelessAccessPointsPage.wirelessNetworkDevice, wirelessAccessPoint: apProxy.get(index)})
                    }
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
                    Layout.preferredHeight: app.iconSize
                    Layout.preferredWidth: app.iconSize
                    name: "../images/eye.svg"
                    color: passwordTextField.showPassword ? app.accentColor : keyColor
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
                    networkManager.connectToWiFi(authPage.wirelessNetworkDevice.interface, authPage.wirelessAccessPoint.ssid, passwordTextField.text)
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


            NymeaListItemDelegate {
                Layout.fillWidth: true
                text: qsTr("SSID")
                subText: currentApPage.wirelessNetworkDevice.currentAccessPoint.ssid
                progressive: false
            }
            NymeaListItemDelegate {
                Layout.fillWidth: true
                text: qsTr("MAC Address")
                subText: currentApPage.wirelessNetworkDevice.currentAccessPoint.macAddress
                progressive: false
            }
            NymeaListItemDelegate {
                Layout.fillWidth: true
                text: qsTr("Signal strength")
                subText: currentApPage.wirelessNetworkDevice.currentAccessPoint.signalStrength
                progressive: false
            }

            Button {
                Layout.fillWidth: true
                Layout.margins: app.margins
                text: qsTr("Disconnect")
                onClicked: {
                    networkManager.disconnectInterface(currentApPage.wirelessNetworkDevice.interface)
                    pageStack.pop(root);
                }
            }

        }
    }
}

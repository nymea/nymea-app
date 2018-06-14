import QtQuick 2.4
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.2
import QtQuick.Controls.Material 2.1

import "components"
import Mea 1.0

Page {
    id: root

    property string name
    property string address
    property QtObject networkManger

    header: GuhHeader {
        text: qsTr("Wireless network")
        onBackPressed: {
            pageStack.pop()
            pageStack.pop()
        }

        HeaderButton {
            imageSource: Qt.resolvedUrl("images/refresh.svg")
            onClicked:  networkManger.manager.loadNetworks()
        }

        HeaderButton {
            imageSource: Qt.resolvedUrl("images/settings.svg")
            onClicked: pageStack.push(settingsPage)
        }

    }

    Component.onCompleted: networkManger.manager.loadNetworks()

    Connections {
        target: networkManger.manager
        onErrorOccured: {
            print("Error occured", errorMessage)
            var errorDialog = Qt.createComponent(Qt.resolvedUrl("components/ErrorDialog.qml"));
            var popup = errorDialog.createObject(app, {text: errorMessage})
            popup.open()
        }

        onWirelessStatusChanged: {
            switch(networkManger.manager.wirelessStatus) {
            case WirelessSetupManager.WirelessStatusDisconnected:
                networkManger.manager.accessPoints.setSelectedNetwork("", "")
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        visible: networkManger.manager.initialized

        Label {
            wrapMode: Text.WordWrap
            Layout.alignment: Qt.AlignHCenter
            text:{
                switch (networkManger.manager.networkStatus) {
                case WirelessSetupManager.NetworkStatusUnknown:
                    return qsTr("Unknown status.");
                case WirelessSetupManager.NetworkStatusAsleep:
                    return qsTr("Asleep.");
                case WirelessSetupManager.NetworkStatusDisconnected:
                    return qsTr("Disconnected.");
                case WirelessSetupManager.NetworkStatusDisconnecting:
                    return qsTr("Disconnecting...");
                case WirelessSetupManager.NetworkStatusConnecting:
                    return qsTr("Connecting...");
                case WirelessSetupManager.NetworkStatusLocal:
                    return qsTr("Connected local.");
                case WirelessSetupManager.NetworkStatusConnectedSite:
                    return qsTr("Connected site.");
                case WirelessSetupManager.NetworkStatusGlobal:
                    return qsTr("Online.");
                }
            }
        }

        BusyIndicator {
            Layout.alignment: Qt.AlignHCenter
            running: networkManger.manager.working
        }

        ThinDivider { }

        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true

            model: networkManger.manager.accessPoints
            clip: true

            delegate: ItemDelegate {
                width: parent.width
                height: model.selectedNetwork ? app.delegateHeight * 1.5 : app.delegateHeight

                Rectangle {
                    anchors.fill: parent
                    color: guhAccent
                    visible: model.selectedNetwork
                }

                RowLayout {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.right: parent.right

                    Item {
                        Layout.preferredHeight: app.delegateHeight
                        Layout.preferredWidth: height

                        ColorIcon {
                            id: image
                            anchors.fill: parent
                            anchors.margins: app.margins / 2
                            name:  {
                                if (model.protected) {
                                    if (model.signalStrength <= 25)
                                        return  Qt.resolvedUrl("images/nm-signal-25-secure.svg")

                                    if (model.signalStrength <= 50)
                                        return  Qt.resolvedUrl("images/nm-signal-50-secure.svg")

                                    if (model.signalStrength <= 75)
                                        return  Qt.resolvedUrl("images/nm-signal-75-secure.svg")

                                    if (model.signalStrength <= 100)
                                        return  Qt.resolvedUrl("images/nm-signal-100-secure.svg")

                                } else {

                                    if (model.signalStrength <= 25)
                                        return  Qt.resolvedUrl("images/nm-signal-25.svg")

                                    if (model.signalStrength <= 50)
                                        return  Qt.resolvedUrl("images/nm-signal-50.svg")

                                    if (model.signalStrength <= 75)
                                        return  Qt.resolvedUrl("images/nm-signal-75.svg")

                                    if (model.signalStrength <= 100)
                                        return  Qt.resolvedUrl("images/nm-signal-100.svg")

                                }
                            }
                        }
                    }

                    Label {
                        Layout.alignment: Qt.AlignVCenter
                        text: model.signalStrength + "%"
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter
                        Label {
                            text: model.ssid
                        }

                        Label {
                            text: model.macAddress
                            font.pixelSize: app.smallFont
                        }

                        Label {
                            text: {
                                switch (networkManger.manager.wirelessStatus) {
                                case WirelessSetupManager.WirelessStatusUnknown:
                                    return qsTr("Unknown status.");
                                case WirelessSetupManager.WirelessStatusUnmanaged:
                                    return qsTr("Network unmanaged.");
                                case WirelessSetupManager.WirelessStatusUnavailable:
                                    return qsTr("Network unavailable.");
                                case WirelessSetupManager.WirelessStatusDisconnected:
                                    return qsTr("Disconnected.");
                                case WirelessSetupManager.WirelessStatusPrepare:
                                    return qsTr("Prepare connection...");
                                case WirelessSetupManager.WirelessStatusConfig:
                                    return qsTr("Configure network...");
                                case WirelessSetupManager.WirelessStatusNeedAuth:
                                    return qsTr("Authentication needed");
                                case WirelessSetupManager.WirelessStatusIpConfig:
                                    return qsTr("Configuration IP...");
                                case WirelessSetupManager.WirelessStatusIpCheck:
                                    return qsTr("Check IP...");
                                case WirelessSetupManager.WirelessStatusSecondaries:
                                    return qsTr("Secondaries...");
                                case WirelessSetupManager.WirelessStatusActivated:
                                    return qsTr("Network connected.");
                                case WirelessSetupManager.WirelessStatusDeactivating:
                                    return qsTr("Network disconnecting...");
                                case WirelessSetupManager.WirelessStatusFailed:
                                    return qsTr("Network connection failed.");
                                }
                            }

                            font.pixelSize: app.smallFont
                            visible: model.selectedNetwork
                        }
                    }

                    Button {
                        text: qsTr("Disconnect")
                        visible: model.selectedNetwork && networkManger.manager.wirelessStatus === WirelessSetupManager.WirelessStatusActivated
                        onClicked: networkManger.manager.disconnectWirelessNetwork()
                    }
                }

                onClicked: {
                    print("Connect to ", model.ssid, " --> ", model.macAddress)
                    pageStack.push(authenticationPage, { ssid: model.ssid, macAddress: model.macAddress })
                }
            }
        }
    }

    Component {
        id: authenticationPage

        Page {
            id: root

            property string ssid
            property string macAddress

            header: GuhHeader {
                text: qsTr("Wireless authentication")
                onBackPressed: pageStack.pop()
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: app.margins

                Label {
                    wrapMode: Text.WordWrap
                    font.pixelSize: app.largeFont
                    Layout.fillWidth: true
                    text: ssid + " (" + macAddress + ")"
                }

                Label {
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                    text: qsTr("Please enter the password for the Wifi network.")
                }

                RowLayout {
                    Layout.fillWidth: true

                    TextField {
                        id: passwordTextField
                        Layout.fillWidth: true
                        echoMode: TextInput.Password
                    }

                    Button {
                        text: qsTr("Show password")
                        onClicked: {
                            if (passwordTextField.echoMode === TextInput.Normal) {
                                text = qsTr("Show password")
                                passwordTextField.echoMode = TextInput.Password
                            } else {
                                text = qsTr("Hide password")
                                passwordTextField.echoMode = TextInput.Normal
                            }
                        }
                    }
                }

                Button {
                    Layout.fillWidth: true
                    text: qsTr("Connect")
                    onPressed: {
                        networkManger.manager.connectWirelessNetwork(ssid, passwordTextField.text)
                        networkManger.manager.accessPoints.setSelectedNetwork(ssid, macAddress)
                        pageStack.pop()
                    }
                }

            }
        }
    }


    Component {
        id: settingsPage

        Page {
            id: root
            header: GuhHeader {
                text: qsTr("Network settings")
                onBackPressed: pageStack.pop()
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: app.margins

                RowLayout {
                    anchors.margins: app.margins
                    Layout.fillWidth: true

                    Label {
                        Layout.fillWidth: true
                        text: qsTr("Networking")
                    }

                    Switch {
                        id: networkingSwitch
                        checked: networkManger.manager.networkingEnabled
                        onCheckedChanged: networkManger.manager.enableNetworking(checked)
                    }
                }

                RowLayout {
                    anchors.margins: app.margins
                    Layout.fillWidth: true

                    Label {
                        Layout.fillWidth: true
                        text: qsTr("Wireless networking")
                    }

                    Switch {
                        id: wirelessNetworkingSwitch
                        checked: networkManger.manager.wirelessEnabled
                        onCheckedChanged: networkManger.manager.enableWireless(checked)
                    }
                }

                ThinDivider { }

                Label {
                    Layout.fillWidth: true
                    text: qsTr("Bluetooth device information")
                }

                ThinDivider { }

                RowLayout {
                    anchors.margins: app.margins
                    Layout.fillWidth: true

                    Label {
                        Layout.fillWidth: true
                        text: qsTr("System UUID")
                    }

                    Label {
                        text: networkManger.manager.modelNumber
                    }
                }

                RowLayout {
                    Layout.fillWidth: true

                    Label {
                        Layout.fillWidth: true
                        text: qsTr("Manufacturer")
                    }
                    Label {
                        text: networkManger.manager.manufacturer
                    }
                }

                RowLayout {
                    anchors.margins: app.margins
                    Layout.fillWidth: true

                    Label {
                        Layout.fillWidth: true
                        text: qsTr("Software revision")
                    }
                    Label {
                        text: networkManger.manager.softwareRevision
                    }
                }

                RowLayout {
                    anchors.margins: app.margins
                    Layout.fillWidth: true

                    Label {
                        Layout.fillWidth: true
                        text: qsTr("Firmware revision")
                    }
                    Label {
                        text: networkManger.manager.firmwareRevision
                    }
                }

                RowLayout {
                    anchors.margins: app.margins
                    Layout.fillWidth: true

                    Label {
                        Layout.fillWidth: true
                        text: qsTr("Hardware revision")
                    }
                    Label {
                        text: networkManger.manager.hardwareRevision
                    }
                }
            }
        }
    }
}

import QtQuick 2.4
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.2

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

    ColumnLayout {
        anchors.fill: parent
        visible: networkManger.manager.initialized

        Label {
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
            text: qsTr("Network status: ") +  networkManger.manager.networkStatus
        }


        Label {
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
            text: qsTr("Wireless status: ") +  networkManger.manager.wirelessStatus
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
                height: app.delegateHeight

                RowLayout {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.right: parent.right

                    Item {
                        Layout.fillHeight: true
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

                        Label {
                            text: model.ssid
                        }

                        Label {
                            text: model.macAddress
                            font.pixelSize: app.smallFont
                        }
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

                TextField {
                    Layout.fillWidth: true
                    id: passwordTextField
                    echoMode: TextInput.Password
                }

                Button {
                    Layout.fillWidth: true
                    text: qsTr("Connect")
                    onPressed: {
                        networkManger.manager.connectWirelessNetwork(ssid, passwordTextField.text)
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
                text: qsTr("Network manager settings")
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

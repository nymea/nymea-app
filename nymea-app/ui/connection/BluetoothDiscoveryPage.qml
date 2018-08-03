import QtQuick 2.4
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.2
import "../components"
import Nymea 1.0


Page {
    id: root
    header: GuhHeader {
        text: qsTr("Bluetooth discovery")
        onBackPressed: pageStack.pop()
    }

    Component.onCompleted: Engine.bluetoothDiscovery.start()

    function setupDevice(name, btAddress) {
        Engine.bluetoothDiscovery.stop()
        pageStack.push(connectingPageComponent, { name: name, address: btAddress } )
    }

    Connections {
        target: pageStack
        onCurrentItemChanged: {
            if (pageStack.currentItem === root) {
                Engine.bluetoothDiscovery.start();
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: app.margins

        RowLayout {
            spacing: app.margins
            Layout.leftMargin: app.margins
            Layout.topMargin: app.margins
            Layout.rightMargin: app.rightMargin

            Label {
                Layout.fillWidth: true
                text: {

                    if (Qt.platform.os === "ios") {
                        if (Engine.bluetoothDiscovery.bluetoothAvailable && Engine.bluetoothDiscovery.bluetoothEnabled) {
                            return qsTr("Searching for %1 boxes via Bluetooth LE.").arg(app.systemName)
                        } if (Engine.bluetoothDiscovery.bluetoothAvailable && !Engine.bluetoothDiscovery.bluetoothEnabled)  {
                            return qsTr("Uh oh! Bluetooth is not enabled. Please enable the Bluetooth on this device and restart the application.")
                        } else {
                            return qsTr("Uh oh! Bluetooth is not available. Please make sure Bluetooth is enabled on this device and restart the application.")
                        }
                    } else {
                        if (Engine.bluetoothDiscovery.bluetoothAvailable && Engine.bluetoothDiscovery.bluetoothEnabled) {
                            return qsTr("Searching for %1 boxes via Bluetooth LE.").arg(app.systemName)
                        } if (Engine.bluetoothDiscovery.bluetoothAvailable && !Engine.bluetoothDiscovery.bluetoothEnabled)  {
                            return qsTr("Uh oh! Bluetooth is not enabled. Please enable the Bluetooth on this device.")
                        } else {
                            return qsTr("Uh oh! Bluetooth is not available. Please make sure Bluetooth is enabled on this device.")
                        }
                    }


                }

                wrapMode: Text.WordWrap
            }

            BusyIndicator {
                running: Engine.bluetoothDiscovery.discovering
            }
        }

        ThinDivider {}

        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true

            model: Engine.bluetoothDiscovery.deviceInfos
            clip: true

            delegate: MeaListItemDelegate {
                width: parent.width
                iconName: Qt.resolvedUrl("../images/bluetooth.svg")
                text: model.name
                subText: model.address

                onClicked: {
                    root.setupDevice(model.name, model.address)
                }
            }
        }

        ThinDivider {}

        RowLayout {
            Layout.fillWidth: true
            Layout.leftMargin: app.margins
            Layout.rightMargin: app.margins
            Layout.bottomMargin: app.margins
            spacing: app.margins
            Label {
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                maximumLineCount: 2
                elide: Text.ElideRight
                text: qsTr("Troubles finding your box? Try this!")
            }
            Button {
                text: qsTr("Help")
                onClicked: pageStack.push(helpPageComponent)
            }
        }
    }

    Component {
        id: helpPageComponent
        Page {
            id: helpPage
            header: GuhHeader {
                text: qsTr("Setup help")
                onBackPressed: pageStack.pop()
            }

            Flickable {
                anchors.fill: parent
                contentHeight: helpColumn.implicitHeight

                ColumnLayout {
                    id: helpColumn
                    width: parent.width
                    spacing: app.margins

                    Label {
                        Layout.fillWidth: true
                        Layout.leftMargin: app.margins
                        Layout.rightMargin: app.margins
                        Layout.topMargin: app.margins
                        wrapMode: Text.WordWrap
                        font.bold: true
                        text: "Raspberry Pi™"
                    }
                    Label {
                        Layout.fillWidth: true
                        Layout.leftMargin: app.margins
                        Layout.rightMargin: app.margins
                        wrapMode: Text.WordWrap
                        text: qsTr("After having installed the nymea community image to your Raspberry Pi, all you need to do is to plug it into a power socket. Note that the Wireless setup will only be available if the Raspberry Pi is not connected to a wired network.")
                    }
                    Image {
                        Layout.preferredWidth: app.iconSize * 8
                        Layout.preferredHeight: width * 540 / 800
                        sourceSize.width: 800
                        sourceSize.height: 540
                        fillMode: Image.PreserveAspectFit
                        Layout.alignment: Qt.AlignHCenter
                        source: "../images/rpi-setup.svg"
                    }
                    ThinDivider {}
                    Label {
                        Layout.fillWidth: true
                        Layout.leftMargin: app.margins
                        Layout.rightMargin: app.margins
                        wrapMode: Text.WordWrap
                        font.bold: true
                        text: "%1 box".arg(systemName)
                    }
                    Label {
                        Layout.fillWidth: true
                        Layout.leftMargin: app.margins
                        Layout.rightMargin: app.margins
                        wrapMode: Text.WordWrap
                        text: qsTr("If you have a %1 box, plug it into a power socket and wait for it to be booted. Once the LED pulses slowly, press the button for 3 seconds until the LED changes.").arg(app.systemName)
                    }
                    Image {
                        Layout.preferredWidth: app.iconSize * 5
                        Layout.preferredHeight: width
                        Layout.bottomMargin: app.margins
                        sourceSize.width: width
                        sourceSize.height: width
                        fillMode: Image.PreserveAspectFit
                        Layout.alignment: Qt.AlignHCenter
                        source: "../images/nymea-box-setup.svg"
                    }
                }
            }
        }
    }

    Component {
        id: connectingPageComponent

        Page {
            id: connectingPage
            header: GuhHeader {
                text: qsTr("Establish bluetooth connection")
                onBackPressed: pageStack.pop()
            }

            property string name
            property string address

            NetworkManagerControler {
                id: networkManger
                name: connectingPage.name
                address: connectingPage.address

                Component.onCompleted: networkManger.connectDevice()
            }

            Connections {
                target: networkManger.manager
                onInitializedChanged: {
                    if (networkManger.manager.initialized) {
                        pageStack.push(Qt.resolvedUrl("../WirelessControlerPage.qml"), { name: connectingPage.name, address: connectingPage.address, networkManger: networkManger } )
                    } else {
                        pageStack.pop(root)
                    }
                }

                onConnectedChanged: {
                    if (!networkManger.manager.connected) {
                        pageStack.pop(root)
                    }
                }
            }

            ColumnLayout {
                anchors.centerIn: parent

                BusyIndicator {
                    Layout.alignment: Qt.AlignHCenter
                    running: true
                }

                Label {
                    id: workingMessage
                    Layout.alignment: Qt.AlignHCenter
                    text: networkManger.manager.statusText
                }

                Label {
                    id: initializingMessage
                    Layout.alignment: Qt.AlignHCenter
                    text: networkManger.manager.initializing ? qsTr("Initialize services...") : ""
                }
            }
        }
    }
}

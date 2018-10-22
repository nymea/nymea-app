import QtQuick 2.4
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.2
import "../../components"
import Nymea 1.0

Page {
    id: root
    header: GuhHeader {
        text: qsTr("Wireless Box setup")
        onBackPressed: pageStack.pop()
    }

    property var nymeaDiscovery: null

    BluetoothDiscovery {
        id: bluetoothDiscovery
        discoveryEnabled: pageStack.currentItem === root
    }

    NetworkManagerController {
        id: networkManager
    }

    function setupDevice(btDeviceInfo) {
        networkManager.bluetoothDeviceInfo = btDeviceInfo
        networkManager.connectDevice();
        pageStack.push(connectingPageComponent)
    }

    Connections {
        target: networkManager.manager
        onInitializedChanged: {
            if (networkManager.manager.initialized) {
                if (networkManager.manager.currentConnection) {
                    print("***** pushing WirelessSetupPage with networkManager:", networkManager)
                    pageStack.replace(Qt.resolvedUrl("WirelessSetupPage.qml"), { networkManagerController: networkManager, nymeaDiscovery: root.nymeaDiscovery } )
                } else {
                    var page = pageStack.replace(Qt.resolvedUrl("ConnectWiFiPage.qml"), { networkManagerController: networkManager } )
                    page.connected.connect(function() {
                        print("connected signal received")
                        pageStack.replace(page, Qt.resolvedUrl("WirelessSetupPage.qml", {NetworkManagerController: networkManager, nymeaDiscovery: root.nymeaDiscovery}))
                    })
                }
            } else {
                pageStack.pop(root)
            }
        }

        onConnectedChanged: {
            if (!networkManager.manager.connected) {
                pageStack.pop(root)
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        visible: bluetoothDiscovery.bluetoothAvailable && bluetoothDiscovery.bluetoothEnabled

        RowLayout {
            Layout.margins: app.margins
            Label {
                Layout.fillWidth: true
                text: qsTr("Searching for %1 boxes.").arg(app.systemName)
                wrapMode: Text.WordWrap
            }
            BusyIndicator {
                running: bluetoothDiscovery.discovering
            }
        }
        ThinDivider {}

        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true

            model: bluetoothDiscovery.deviceInfos
            clip: true

            delegate: MeaListItemDelegate {
                width: parent.width
                iconName: Qt.resolvedUrl("../../images/bluetooth.svg")
                text: model.name
                subText: model.address

                onClicked: {
                    root.setupDevice(bluetoothDiscovery.deviceInfos.get(index))
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
                text: qsTr("Troubles finding your box?")
            }
            Button {
                text: qsTr("Help")
                onClicked: pageStack.push(helpPageComponent)
            }
        }
    }

    ColumnLayout {
        anchors { left: parent.left; right: parent.right; verticalCenter: parent.verticalCenter; margins: app.margins }
        visible: !bluetoothDiscovery.bluetoothAvailable || !bluetoothDiscovery.bluetoothEnabled
        spacing: app.margins * 2

        Label {
            Layout.fillWidth: true
            text: qsTr("Uh oh")
            color: app.accentColor
            font.pixelSize: app.largeFont
        }

        Label {
            Layout.fillWidth: true
            wrapMode: Text.WordWrap

            text: !bluetoothDiscovery.bluetoothAvailable
                  ? qsTr("Bluetooth doesn't seem to be available on this device. The wireless network setup requires a working Bluetooth connection.")
                  : qsTr("Bluetooth seems to be disabled. Please enable Bluetooth on your device in order to use the wireless network setup.")
        }
    }


    Component {
        id: helpPageComponent
        Page {
            id: helpPage
            header: GuhHeader {
                text: qsTr("Wireless setup help")
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
                        source: "../../images/rpi-setup.svg"
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
                        source: "../../images/nymea-box-setup.svg"
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
                text: qsTr("Connecting...")
                onBackPressed: pageStack.pop()
            }

            ColumnLayout {
                anchors { left: parent.left; right: parent.right; verticalCenter: parent.verticalCenter; margins: app.margins }
                spacing: app.margins

                BusyIndicator {
                    Layout.alignment: Qt.AlignHCenter
                    running: true
                }

                Label {
                    id: workingMessage
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignHCenter
                    text: networkManager.manager.statusText
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                }

                Label {
                    id: initializingMessage
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignHCenter
                    text: networkManager.manager.initializing ? qsTr("Initializing services...") : ""
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                }
            }
        }
    }
}

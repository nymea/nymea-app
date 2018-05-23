import QtQuick 2.5
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.1
import Mea 1.0
import "components"

Page {
    id: root

    readonly property bool haveHosts: discovery.discoveryModel.count > 0

    header: GuhHeader {
        text: qsTr("Connect nymea")
        backButtonVisible: false
        menuButtonVisible: true
        onMenuPressed: connectionMenu.open()
    }

    Menu {
        id: connectionMenu
        width: implicitWidth + app.margins

        IconMenuItem {
            iconSource: "../images/network-vpn.svg"
            text: qsTr("Manual connect")
            onTriggered: pageStack.push(manualConnectPage)
        }

        MenuSeparator {}

        IconMenuItem {
            iconSource: "../images/bluetooth.svg"
            text: qsTr("Wireless setup")
            onTriggered: pageStack.push(Qt.resolvedUrl("BluetoothDiscoveryPage.qml"))
        }



    }

    Component.onCompleted: {
        print("completed connectPage. last connected host:", settings.lastConnectedHost)
        if (settings.lastConnectedHost.length > 0) {
            pageStack.push(connectingPage)
            Engine.connection.connect(settings.lastConnectedHost)
        }
    }

    Connections {
        target: Engine.connection
        onVerifyConnectionCertificate: {
            print("verify cert!")
            certDialog.issuerInfo = issuerInfo
            certDialog.fingerprint = fingerprint
            certDialog.open();
        }
        onConnectionError: {
            pageStack.pop(root)
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.topMargin: app.bigMargins
        spacing: app.margins

        ColumnLayout {
            Layout.fillWidth: true
            Layout.margins: app.margins
            spacing: app.margins

            Label {
                Layout.fillWidth: true
                text: root.haveHosts ? qsTr("Oh, look!") : qsTr("Uh oh")
                //color: "black"
                font.pixelSize: app.largeFont
            }

            Label {
                Layout.fillWidth: true
                text: root.haveHosts ?
                          qsTr("There are %1 nymea boxes in your network! Which one would you like to use?").arg(discovery.discoveryModel.count)
                        : qsTr("There doesn't seem to be a nymea box installed in your network. Please make sure your nymea box is correctly set up and connected.")
                wrapMode: Text.WordWrap
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: Material.accent
        }

        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            model: discovery.discoveryModel
            clip: true

            delegate: ItemDelegate {
                width: parent.width
                height: app.delegateHeight
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: app.margins
                    Label {
                        text: model.name
                    }
                    Label {
                        text: model.hostAddress
                        font.pixelSize: app.smallFont
                    }
                }
                onClicked: {
                    print("Should connect to", model.nymeaRpcUrl)
                    Engine.connection.connect(model.nymeaRpcUrl)
                    pageStack.push(connectingPage)
                }
            }

            Column {
                anchors.centerIn: parent
                spacing: app.margins
                visible: !root.haveHosts

                Label {
                    text: qsTr("Searching for nymea boxes...")
                }

                BusyIndicator {
                    running: visible
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }

        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: Material.accent
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.margins: app.margins
            visible: root.haveHosts
            Label {
                Layout.fillWidth: true
                text: qsTr("Not the ones you're looking for? We're looking for more!")
                wrapMode: Text.WordWrap
            }

            BusyIndicator { }
        }
    }

    Component {
        id: manualConnectPage

        Page {

            header: GuhHeader {
                text: qsTr("Manual connect to nymea")
                onBackPressed: pageStack.pop()
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: app.margins
                spacing: app.margins

                GridLayout {
                    Layout.fillHeight: true
                    Layout.fillWidth: true

                    columns: 2

                    ComboBox {
                        id: connectionTypeComboBox
                        Layout.fillWidth: true
                        Layout.columnSpan: 2
                        model: [ qsTr("TCP"), qsTr("Websocket") ]
                    }

                    Label { text: qsTr("Address:") }
                    TextField {
                        id: addressTextInput
                        Layout.fillWidth: true
                        placeholderText: "127.0.0.1"
                        validator: RegExpValidator { regExp:  /^((?:[0-1]?[0-9]?[0-9]|2[0-4][0-9]|25[0-5])\.){0,3}(?:[0-1]?[0-9]?[0-9]|2[0-4][0-9]|25[0-5])$/ }
                    }

                    Label { text: qsTr("Port:") }
                    TextField {
                        id: portTextInput
                        Layout.fillWidth: true
                        placeholderText: connectionTypeComboBox.currentIndex === 0 ? "2222" : "4444"
                        validator: IntValidator{bottom: 1; top: 65535;}
                    }

                    Label {
                        Layout.fillWidth: true
                        text: qsTr("Encrypted connection:")
                    }
                    CheckBox {
                        id: secureCheckBox
                        checked: true
                    }
                }


                Button {
                    text: qsTr("Connect")
                    Layout.fillWidth: true
                    onClicked: {
                        var rpcUrl
                        var hostAddress
                        var port

                        // Set default to placeholder
                        if (addressTextInput.text === "") {
                            hostAddress = addressTextInput.placeholderText
                        } else {
                            hostAddress = addressTextInput.text
                        }

                        if (portTextInput.text === "") {
                            port = portTextInput.placeholderText
                        } else {
                            port = portTextInput.text
                        }

                        if (connectionTypeComboBox.currentIndex == 0) {
                            if (secureCheckBox.checked) {
                                rpcUrl = "nymeas://" + hostAddress + ":" + port
                            } else {
                                rpcUrl = "nymea://" + hostAddress + ":" + port
                            }
                        } else if (connectionTypeComboBox.currentIndex == 1) {
                            if (secureCheckBox.checked) {
                                rpcUrl = "wss://" + hostAddress + ":" + port
                            } else {
                                rpcUrl = "ws://" + hostAddress + ":" + port
                            }
                        }

                        print("Try to connect ", rpcUrl)
                        Engine.connection.connect(rpcUrl)
                        pageStack.push(connectingPage)
                    }
                }
            }
        }
    }

    Component {
        id: connectingPage
        Page {
            ColumnLayout {
                anchors.centerIn: parent
                width: parent.width - app.margins * 2
                spacing: app.margins

                Label {
                    text: qsTr("Connecting to your nymea box...")
                    wrapMode: Text.WordWrap
                    font.pixelSize: app.largeFont
                    Layout.fillWidth: true
                }

                Button {
                    text: qsTr("Cancel")
                    Layout.fillWidth: true
                    onClicked: {
                        Engine.connection.disconnect()
                        pageStack.pop();
                    }
                }
            }
        }
    }

    Dialog {
        id: certDialog
        width: Math.min(parent.width * .9, 400)
        x: (parent.width - width) / 2
        y: (parent.height - height) / 2
        standardButtons: Dialog.Yes | Dialog.No

        property var fingerprint
        property var issuerInfo

        ColumnLayout {
            anchors { left: parent.left; right: parent.right; top: parent.top }
            spacing: app.margins

            RowLayout {
                Layout.fillWidth: true
                spacing: app.margins
                ColorIcon {
                    Layout.preferredHeight: app.iconSize * 2
                    Layout.preferredWidth: height
                    name: "../images/dialog-warning-symbolic.svg"
                    color: app.guhAccent
                }

                Label {
                    id: titleLabel
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    text: qsTr("Warning")
                    color: app.guhAccent
                    font.pixelSize: app.largeFont
                }
            }

            Label {
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                text: qsTr("The authenticity of this nymea box cannot be verified.")
            }

            Label {
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                text: qsTr("If this is the first time you connect to this box, this is expected. Once you trust a box, you should never see this message again for that one. If you see this message multiple times for the same box, something suspicious is going on!")
            }

            GridLayout {
                columns: 2

                Repeater {
                    model: certDialog.issuerInfo

                    Label {
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                        text: modelData
                    }
                }
            }

            Label {
                Layout.fillWidth: true
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                text: qsTr("Fingerprint: ") + certDialog.fingerprint
            }

            Label {
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                text: qsTr("Do you want to trust this device?")
                font.bold: true
            }
        }

        onAccepted: {
            Engine.connection.acceptCertificate(certDialog.fingerprint)
        }
    }
}

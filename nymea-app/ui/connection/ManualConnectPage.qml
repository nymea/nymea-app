import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import Nymea 1.0
import "../components"

Page {
    id: root
    objectName: "manualConnectPage"
    header: NymeaHeader {
        text: qsTr("Manual connection")
        onBackPressed: pageStack.pop()
    }

    ColumnLayout {
        anchors { left: parent.left; top: parent.top; right: parent.right }
        anchors.margins: app.margins
        spacing: app.margins

        GridLayout {
            columns: 2

            Label {
                text: qsTr("Protocol")
            }

            ComboBox {
                id: connectionTypeComboBox
                Layout.fillWidth: true
                model: [ qsTr("TCP"), qsTr("Websocket") ]
            }

            Label { text: qsTr("Address:") }
            TextField {
                id: addressTextInput
                objectName: "addressTextInput"
                Layout.fillWidth: true
                placeholderText: "127.0.0.1"
            }

            Label { text: qsTr("Port:") }
            TextField {
                id: portTextInput
                Layout.fillWidth: true
                placeholderText: connectionTypeComboBox.currentIndex === 0 ?
                                     secureCheckBox.checked ? "2223" : "2222"
                                   : secureCheckBox.checked ? "4445" : "4444"
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
            objectName: "connectButton"
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
                var host = discovery.nymeaHosts.createLanHost("Manual connection", rpcUrl);
                engine.connection.connect(host)
            }
        }
    }
}

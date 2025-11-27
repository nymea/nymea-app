import QtQuick 2.3
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.2
import "../components"
import Nymea 1.0

ColumnLayout {

    property string rpcUrl: {
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
        } else if (connectionTypeComboBox.currentIndex == 2) {
            if (secureCheckBox.checked) {
                rpcUrl = "tunnels://" + hostAddress + ":" + port + "?uuid=" + serverUuidTextInput.text
            } else {
                rpcUrl = "tunnel://" + hostAddress + ":" + port + "?uuid=" + serverUuidTextInput.text
            }
        }

        return rpcUrl;
    }

    property bool sslEnabled: secureCheckBox.checked

    GridLayout {
        columns: 2

        Label {
            text: qsTr("Protocol")
        }

        ComboBox {
            id: connectionTypeComboBox
            Layout.fillWidth: true
            model: [ qsTr("TCP"), qsTr("Websocket"), qsTr("Remote proxy") ]
        }

        Label {
            text: connectionTypeComboBox.currentIndex < 2 ? qsTr("Address:") : qsTr("Proxy address:")
        }
        TextField {
            id: addressTextInput
            objectName: "addressTextInput"
            Layout.fillWidth: true
            placeholderText: connectionTypeComboBox.currentIndex < 2 ? "127.0.0.1" : Configuration.tunnelProxyUrl
        }

        Label {
            text: qsTr("%1 UUID:").arg(Configuration.systemName)
            visible: connectionTypeComboBox.currentIndex == 2
        }
        TextField {
            id: serverUuidTextInput
            Layout.fillWidth: true
            visible: connectionTypeComboBox.currentIndex == 2
        }
        Label { text: qsTr("Port:") }
        TextField {
            id: portTextInput
            Layout.fillWidth: true
            placeholderText: connectionTypeComboBox.currentIndex === 0
                             ? "2222"
                             : connectionTypeComboBox.currentIndex == 1
                               ? "4444"
                               : Configuration.tunnelProxyPort
            validator: IntValidator{bottom: 1; top: 65535;}
        }

        Label {
            Layout.fillWidth: true
            text: qsTr("SSL:")
        }
        CheckBox {
            id: secureCheckBox
            checked: true
        }
    }
}

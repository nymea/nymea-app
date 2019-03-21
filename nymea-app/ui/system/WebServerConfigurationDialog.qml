import QtQuick 2.9
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.1
import Nymea 1.0

Dialog {
    id: root
    title: qsTr("Server configuration")
    width: parent.width * .8
    x: (parent.width - width) / 2
    y: (parent.height - height) / 2

    property WebServerConfiguration serverConfiguration: null
    standardButtons: Dialog.Ok | Dialog.Cancel

    ColumnLayout {
        anchors { left: parent.left; top: parent.top; right: parent.right }
        RowLayout {
            Label {
                text: qsTr("Interface")
                Layout.fillWidth: true
            }
            ComboBox {
                id: interfaceCombobox
                model: [qsTr("Any"), qsTr("Localhost"), qsTr("Custom")]
                Layout.fillWidth: true
                currentIndex: !root.serverConfiguration
                              ? 0 : root.serverConfiguration.address === "0.0.0.0"
                                ? 0
                                : root.serverConfiguration.address === "127.0.0.1"
                                  ? 1 : 2
                onActivated: {
                    switch (index) {
                    case 0:
                        root.serverConfiguration.address = "0.0.0.0";
                        break;
                    case 1:
                        root.serverConfiguration.address = "127.0.0.1";
                        break;
                    }
                }
            }
        }
        RowLayout {
            visible: interfaceCombobox.currentIndex === 2
            Label {
                text: qsTr("Address:")
                Layout.fillWidth: true
            }
            TextField {
                id: addressTextField
                Layout.fillWidth: true
                inputMethodHints: Qt.ImhPreferNumbers
                inputMask: "000.000.000.000"
                text: root.serverConfiguration ? root.serverConfiguration.address : ""
                onEditingFinished: root.serverConfiguration.address = text
            }
        }

        RowLayout {
            Label {
                text: qsTr("Port:")
                Layout.fillWidth: true
            }
            TextField {
                inputMethodHints: Qt.ImhDigitsOnly
                text: root.serverConfiguration ? root.serverConfiguration.port : 0
                validator: IntValidator { bottom: 0; top: 65535 }
                onEditingFinished: root.serverConfiguration.port = text
            }
        }

        RowLayout {
            Label {
                Layout.fillWidth: true
                text: qsTr("SSL enabled")
            }
            CheckBox {
                checkState: root.serverConfiguration && root.serverConfiguration.sslEnabled ? Qt.Checked : Qt.Unchecked
                onClicked: root.serverConfiguration.sslEnabled = checked
            }
        }
        RowLayout {
            Label {
                Layout.fillWidth: true
                text: qsTr("Login required")
            }
            CheckBox {
                checkState: root.serverConfiguration && root.serverConfiguration.authenticationEnabled ? Qt.Checked : Qt.Unchecked
                onClicked: root.serverConfiguration.authenticationEnabled = checked
            }
        }
        RowLayout {
            Label {
                Layout.fillWidth: true
                text: qsTr("Public folder")
            }
            TextField {
                text: root.serverConfiguration ? root.serverConfiguration.publicFolder : ""
                onEditingFinished: root.serverConfiguration.publicFolder = text
            }
        }
    }
}

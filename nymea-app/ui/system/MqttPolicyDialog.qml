import QtQuick 2.9
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.1
import Nymea 1.0

Dialog {
    id: root
    title: qsTr("Mqtt permission")
    width: parent.width * .8
    x: (parent.width - width) / 2
    y: (parent.height - height) / 2

    property MqttPolicy policy: null
    standardButtons: Dialog.Ok | Dialog.Cancel

    ColumnLayout {
        anchors { left: parent.left; top: parent.top; right: parent.right }
        RowLayout {
            Label {
                text: qsTr("Client ID:")
                Layout.fillWidth: true
            }
            TextField {
                id: clientIdTextField
                Layout.fillWidth: true
                text: root.policy ? root.policy.clientId : ""
                onEditingFinished: root.policy.clientId = text
            }
        }
        RowLayout {
            Label {
                text: qsTr("Username:")
                Layout.fillWidth: true
            }
            TextField {
                id: usernameTextField
                Layout.fillWidth: true
                text: root.policy ? root.policy.username : ""
                onEditingFinished: root.policy.username = text
            }
        }

        RowLayout {
            Label {
                text: qsTr("Password:")
                Layout.fillWidth: true
            }
            TextField {
                Layout.fillWidth: true
                text: root.policy ? root.policy.password : ""
                onEditingFinished: root.policy.password = text
            }
        }

    }
}

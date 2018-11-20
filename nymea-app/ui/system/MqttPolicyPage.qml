import QtQuick 2.9
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.1
import Nymea 1.0
import "../components"

Page {
    id: root
    header: GuhHeader {
        text: qsTr("Mqtt permission")
        onBackPressed: {
            root.rejected();
            pageStack.pop();
        }
        HeaderButton {
            imageSource: "../images/tick.svg"
            enabled: clientIdTextField.isValid
            onClicked: {
                root.accepted();
                pageStack.pop();
            }
        }
    }
    property MqttPolicy policy: null

    signal accepted();
    signal rejected()

    ColumnLayout {
        anchors { left: parent.left; top: parent.top; right: parent.right; bottom: parent.bottom }
        RowLayout {
            Layout.leftMargin: app.margins; Layout.rightMargin: app.margins; Layout.topMargin: app.margins
            spacing: app.margins
            Label {
                text: qsTr("Client ID:")
                Layout.fillWidth: true
            }
            TextField {
                id: clientIdTextField
                Layout.fillWidth: true
                text: root.policy ? root.policy.clientId : ""
                onEditingFinished: root.policy.clientId = text
                placeholderText: qsTr("E.g. Sensor_1")
                property bool isEmpty: displayText.length === 0
                property bool isDuplicate: clientIdTextField.displayText != root.policy.clientId && engine.nymeaConfiguration.mqttPolicies.getPolicy(clientIdTextField.displayText) !== null
                property bool isValid: !isEmpty && !isDuplicate
            }
        }
        Label {
            Layout.leftMargin: app.margins; Layout.rightMargin: app.margins
            text: clientIdTextField.isDuplicate ? qsTr("%1 is already used").arg(clientIdTextField.displayText) : qsTr("Can't be blank")
            font.pixelSize: app.smallFont
            Layout.alignment: Qt.AlignRight
            color: "red"
            visible: !clientIdTextField.isValid
        }

        RowLayout {
            Layout.leftMargin: app.margins; Layout.rightMargin: app.margins
            Label {
                text: qsTr("Username:")
                Layout.fillWidth: true
            }
            TextField {
                id: usernameTextField
                Layout.fillWidth: true
                text: root.policy ? root.policy.username : ""
                onEditingFinished: root.policy.username = text
                placeholderText: qsTr("Optional")
            }
        }

        RowLayout {
            Layout.leftMargin: app.margins; Layout.rightMargin: app.margins
            Label {
                text: qsTr("Password:")
                Layout.fillWidth: true
            }
            TextField {
                Layout.fillWidth: true
                text: root.policy ? root.policy.password : ""
                onEditingFinished: root.policy.password = text
                placeholderText: qsTr("Optional")
            }
        }

        ThinDivider {}

        Label {
            Layout.fillWidth: true
            Layout.leftMargin: app.margins; Layout.rightMargin: app.margins; Layout.topMargin: app.margins
            text: qsTr("Allowed publish topics")
        }
        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            model: root.policy.allowedPublishTopicFilters
            ScrollBar.vertical: ScrollBar {}
            clip: true
            delegate: MeaListItemDelegate {
                width: parent.width
                text: modelData
                canDelete: true
                progressive: false
                onDeleteClicked: {
                    root.policy.allowedPublishTopicFilters.splice(index, 1)
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.leftMargin: app.margins; Layout.rightMargin: app.margins
            property bool add: false
            TextField {
                id: pubField
                Layout.fillWidth: parent.add
                Layout.preferredWidth: parent.add ? undefined : 0
                Behavior on width {
                    NumberAnimation {}
                }
            }
            Button {
                Layout.fillWidth: !parent.add
                text: parent.add ? qsTr("OK") : qsTr("Add")
                enabled: !parent.add || pubField.displayText.length > 0
                onClicked: {
                    if (parent.add) {
                        root.policy.allowedPublishTopicFilters.push(pubField.displayText)
                        pubField.clear();
                    }
                    parent.add = !parent.add;
                }
            }
        }

        ThinDivider {}

        Label {
            Layout.fillWidth: true
            Layout.leftMargin: app.margins; Layout.rightMargin: app.margins; Layout.topMargin: app.margins
            text: qsTr("Allowed subscribe filters")
        }
        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            model: root.policy.allowedSubscribeTopicFilters
            ScrollBar.vertical: ScrollBar {}
            clip: true
            delegate: MeaListItemDelegate {
                width: parent.width
                text: modelData
                canDelete: true
                progressive: false
                onDeleteClicked: {
                    root.policy.allowedSubscribeTopicFilters.splice(index, 1)
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.leftMargin: app.margins; Layout.rightMargin: app.margins; Layout.bottomMargin: app.margins
            property bool add: false
            TextField {
                id: subField
                Layout.fillWidth: parent.add
                Layout.preferredWidth: parent.add ? undefined : 0
            }
            Button {
                Layout.fillWidth: !parent.add;
                Behavior on width { NumberAnimation {} }
                text: parent.add ? qsTr("OK") : qsTr("Add")
                enabled: !parent.add || subField.displayText.length > 0
                onClicked: {
                    if (parent.add) {
                        root.policy.allowedSubscribeTopicFilters.push(subField.displayText)
                        subField.clear();
                    }
                    parent.add = !parent.add;
                }
            }
        }
    }
}

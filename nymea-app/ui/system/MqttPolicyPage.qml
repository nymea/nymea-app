/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
* Copyright 2013 - 2020, nymea GmbH
* Contact: contact@nymea.io
*
* This file is part of nymea.
* This project including source code and documentation is protected by
* copyright law, and remains the property of nymea GmbH. All rights, including
* reproduction, publication, editing and translation, are reserved. The use of
* this project is subject to the terms of a license agreement to be concluded
* with nymea GmbH in accordance with the terms of use of nymea GmbH, available
* under https://nymea.io/license
*
* GNU General Public License Usage
* Alternatively, this project may be redistributed and/or modified under the
* terms of the GNU General Public License as published by the Free Software
* Foundation, GNU version 3. This project is distributed in the hope that it
* will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty
* of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
* Public License for more details.
*
* You should have received a copy of the GNU General Public License along with
* this project. If not, see <https://www.gnu.org/licenses/>.
*
* For any further details and any questions please contact us under
* contact@nymea.io or see our FAQ/Licensing Information on
* https://nymea.io/license/faq
*
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

import QtQuick 2.9
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.1
import Nymea 1.0
import "../components"

SettingsPageBase {
    id: root
    header: NymeaHeader {
        text: qsTr("Mqtt permission")
        onBackPressed: {
            root.rejected();
            pageStack.pop();
        }
        HeaderButton {
            imageSource: "qrc:/icons/tick.svg"
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

    Label {
        Layout.fillWidth: true
        Layout.margins: app.margins
        text: qsTr("Client info")
        color: Style.accentColor
    }

    RowLayout {
        Layout.leftMargin: app.margins
        Layout.rightMargin: app.margins
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
        Layout.leftMargin: app.margins
        Layout.rightMargin: app.margins
        text: clientIdTextField.isDuplicate ? qsTr("%1 is already used").arg(clientIdTextField.displayText) : qsTr("Can't be blank")
        font.pixelSize: app.smallFont
        Layout.alignment: Qt.AlignRight
        color: "red"
        visible: !clientIdTextField.isValid
    }

    RowLayout {
        Layout.leftMargin: app.margins
        Layout.rightMargin: app.margins
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
        Layout.leftMargin: app.margins
        Layout.rightMargin: app.margins
        Label {
            text: qsTr("Password:")
            Layout.fillWidth: true
        }
        RowLayout {
            TextField {
                id: passwordTextField
                Layout.fillWidth: true
                text: root.policy ? root.policy.password : ""
                onEditingFinished: root.policy.password = text
                placeholderText: qsTr("Optional")
                echoMode: hiddenPassword ? TextInput.Password : TextInput.Normal
                property bool hiddenPassword: true
            }
            ColorIcon {
                Layout.preferredHeight: Style.iconSize
                Layout.preferredWidth: height
                name: "qrc:/icons/eye.svg"
                color: passwordTextField.hiddenPassword ? Style.iconColor : Style.accentColor
                MouseArea {
                    anchors.fill: parent
                    onClicked: passwordTextField.hiddenPassword = !passwordTextField.hiddenPassword
                }
            }
        }
    }

    Label {
        Layout.fillWidth: true
        Layout.margins: app.margins
        text: qsTr("Allowed publish topics")
        color: Style.accentColor
    }

    Repeater {
        model: root.policy.allowedPublishTopicFilters
        delegate: NymeaSwipeDelegate {
            Layout.fillWidth: true
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
        Layout.leftMargin: app.margins
        Layout.rightMargin: app.margins
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

    Label {
        Layout.fillWidth: true
        Layout.margins: app.margins
        text: qsTr("Allowed subscribe filters")
        color: Style.accentColor
    }
    Repeater {
        model: root.policy.allowedSubscribeTopicFilters
        delegate: NymeaSwipeDelegate {
            Layout.fillWidth: true
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
        Layout.leftMargin: app.margins; Layout.rightMargin: app.margins
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

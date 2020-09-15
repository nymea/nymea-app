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

import QtQuick 2.5
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.1
import Nymea 1.0
import "../components"
import "../customviews"

DevicePageBase {
    id: root

    readonly property var usersStateType: deviceClass.stateTypes.findByName("users")
    readonly property var usersState: device.states.getState(usersStateType.id)

    readonly property var accessGrantedEventType: deviceClass.eventTypes.findByName("accessGranted")
    readonly property var accessDeniedEventType: deviceClass.eventTypes.findByName("accessDenied")

    ColumnLayout {
        anchors.fill: parent

        Button {
            Layout.fillWidth: true
            Layout.leftMargin: app.margins; Layout.topMargin: app.margins; Layout.rightMargin: app.margins
            text: qsTr("Manage access")
            onClicked: {
                pageStack.push(manageUsersComponent)
            }
        }

        ThinDivider {}

        Label {
            Layout.fillWidth: true
            Layout.margins: app.margins
            text: qsTr("Access log:")
        }

        GenericTypeLogView {
            Layout.fillHeight: true
            Layout.fillWidth: true

            logsModel: LogsModel {
                id: logsModel
                thingId: root.device.id
                engine: _engine
                live: true
                typeIds: [root.accessGrantedEventType.id, root.accessDeniedEventType.id];
            }

            delegate: NymeaListItemDelegate {
                width: parent.width
                iconName: accessGranted ? "../images/tick.svg" : "../images/dialog-error-symbolic.svg"
                iconColor: accessGranted ? "green" : "red"
                text: accessGranted ? qsTr("Access granted for user %1").arg(model.value) : qsTr("Access denied")
                subText: Qt.formatDateTime(model.timestamp)
                progressive: false

                property bool accessGranted: model.typeId === root.accessGrantedEventType.id

                onClicked: {
                    var parts = model.value.trim().split(', ')
                    var popup = detailsPopup.createObject(root, {timestamp: model.timestamp, accessGranted: accessGranted, user: parts[0], finger: parts[1]});
                    popup.open();
                }
            }
        }
    }

    Component {
        id: manageUsersComponent
        Page {
            header: NymeaHeader {
                text: qsTr("Manage users")
                onBackPressed: pageStack.pop()

                HeaderButton {
                    imageSource: "../images/contact-new.svg"
                    onClicked: pageStack.push(addUserComponent)
                }
            }

            ColumnLayout {
                anchors.fill: parent
                Label {
                    Layout.fillWidth: true
                    Layout.margins: app.margins
                    wrapMode: Text.WordWrap
                    text: root.usersState.value.length === 0 ?
                              qsTr("There are no fingerprints registered with this lock")
                            : qsTr("The following users have valid fingerprints for this lock")
                }
                ThinDivider {}
                ListView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    model: root.usersState.value

                    delegate: NymeaListItemDelegate {
                        text: modelData
                        width: parent.width
                        progressive: false
                        iconName: "../images/account.svg"
                        canDelete: true
                        onClicked: {
                            pageStack.push(addUserComponent, {user: modelData})
                        }

                        onDeleteClicked: {
                            var actionType = root.deviceClass.actionTypes.findByName("removeUser")
                            var params = []
                            var titleParam = {}
                            titleParam["paramTypeId"] = actionType.paramTypes.findByName("userId").id
                            titleParam["value"] = modelData
                            params.push(titleParam)
                            engine.deviceManager.executeAction(root.device.id, actionType.id, params)
                        }
                    }

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: app.margins * 2
                        visible: parent.count === 0
                        width: parent.width - app.margins * 2
                        Item {
                            Layout.preferredWidth: 100
                            Layout.preferredHeight: width
                            Layout.alignment: Qt.AlignHCenter
                            ColorIcon {
                                name: "../images/fingerprint.svg"
                                anchors.centerIn: parent
                                height: Math.min(parent.width, parent.height)
                                width: height
                            }
                        }

                        Button {
                            text: qsTr("Add a fingerprint")
                            onClicked: pageStack.push(addUserComponent)
                            Layout.alignment: Qt.AlignHCenter
                        }
                    }
                }
            }
        }
    }

    Component {
        id: addUserComponent
        Page {
            id: addUserPage
            header: NymeaHeader {
                text: qsTr("Add a new fingerprint")
                onBackPressed: pageStack.pop()
            }

            property string user: ""

            property bool done: false
            property bool error: false

            Connections {
                target: engine.deviceManager
                onExecuteActionReply: {
                    print("Execute action reply:", JSON.stringify(params));
                    addUserPage.error = params["deviceError"] !== "DeviceErrorNoError"
                    var masks =[]
                    masks.push({x: 0, y: 0, width: 1, height: 1});
                    addUserPage.done = true
                }
            }

            ColumnLayout {
                anchors.fill: parent
                SwipeView {
                    id: addUserSwipeView
                    Layout.fillWidth: true
                    Layout.topMargin: app.margins
                    Layout.alignment: Qt.AlignTop
                    interactive: false
                    Item {
                        width: addUserSwipeView.width
                        height: addUserSwipeView.height

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: app.margins
                            Label {
                                Layout.fillWidth: true
                                text: qsTr("Username")
                            }

                            TextField {
                                id: userIdTextField
                                Layout.fillWidth: true
                                text: addUserPage.user
                                enabled: addUserPage.user.length === 0
                            }
                            Label {
                                Layout.fillWidth: true
                                text: qsTr("Finger")
                            }
                            ComboBox {
                                id: fingerComboBox
                                Layout.fillWidth: true
                                model: ListModel {
                                    ListElement { modelData: qsTr("Left thumb"); enumValue: "ThumbLeft" }
                                    ListElement { modelData: qsTr("Left index finger"); enumValue: "IndexFingerLeft" }
                                    ListElement { modelData: qsTr("Left middle finger"); enumValue: "MiddleFingerLeft" }
                                    ListElement { modelData: qsTr("Left ring finger"); enumValue: "RingFingerLeft" }
                                    ListElement { modelData: qsTr("Left pinky finger"); enumValue: "PinkyLeft" }
                                    ListElement { modelData: qsTr("Right thumb"); enumValue: "ThumbRight" }
                                    ListElement { modelData: qsTr("Right index finger"); enumValue: "IndexFingerRight" }
                                    ListElement { modelData: qsTr("Right middle finger"); enumValue: "MiddleFingerRight" }
                                    ListElement { modelData: qsTr("Right ring finger"); enumValue: "RingFingerRight" }
                                    ListElement { modelData: qsTr("Right pinky finger"); enumValue: "PinkyRight" }
                                }
                            }

                            Button {
                                text: qsTr("Add user")
                                Layout.fillWidth: true
                                onClicked: {
                                    var actionType = root.deviceClass.actionTypes.findByName("addUser")
                                    var params = []
                                    var titleParam = {}
                                    titleParam["paramTypeId"] = actionType.paramTypes.findByName("userId").id
                                    titleParam["value"] = userIdTextField.displayText
                                    params.push(titleParam)
                                    var fingerParam = {}
                                    fingerParam["paramTypeId"] = actionType.paramTypes.findByName("finger").id
                                    fingerParam["value"] = fingerComboBox.model.get(fingerComboBox.currentIndex).enumValue
                                    params.push(fingerParam)
                                    engine.deviceManager.executeAction(root.device.id, actionType.id, params)
                                    addUserSwipeView.currentIndex++
                                }
                            }
                        }
                    }

                    Item {
                        width: addUserSwipeView.width
                        height: addUserSwipeView.height

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: app.margins
                            spacing: app.margins * 2
                            Label {
                                text: !addUserPage.done ? qsTr("Please scan the fingerprint now")
                                                        : addUserPage.error ? qsTr("Uh oh")
                                                                            : qsTr("All done!")
                                Layout.fillWidth: true
                                font.pixelSize: app.largeFont
                                color: app.accentColor
                                horizontalAlignment: Text.AlignHCenter
                            }

                            Item {
                                Layout.preferredWidth: 100
                                Layout.preferredHeight: 100
                                Layout.alignment: Qt.AlignCenter

                                ColorIcon {
                                    name: "../images/fingerprint.svg"
                                    height: Math.min(parent.width, parent.height)
                                    width: height
                                    anchors.centerIn: parent
                                    color: addUserPage.done ?
                                               (addUserPage.error ? "red" : app.accentColor)
                                             : keyColor
                                }
                            }
                            Label {
                                text: addUserPage.error ? qsTr("Fingerprint could not be read.\nPlease try again.") :
                                                          qsTr("Fingerprint added!")
                                Layout.fillWidth: true
                                wrapMode: Text.WordWrap
                                horizontalAlignment: Text.AlignHCenter
                                visible: addUserPage.done
                            }
                            Button {
                                Layout.fillWidth: true
                                text: qsTr("OK")
                                onClicked: pageStack.pop()
                                visible: addUserPage.done
                            }
                        }
                    }
                }
            }
        }
    }

    Component {
        id: detailsPopup
        MeaDialog {
            id: detailsDialog
            property string timestamp
            property bool accessGranted
            property string user
            property string finger
            title: qsTr("Access request details")
            Label {
                Layout.fillWidth: true
                text: qsTr("Date/Time")
                font.bold: true
            }

            Label {
                Layout.fillWidth: true
                text: Qt.formatDateTime(detailsDialog.timestamp)
            }
            Label {
                Layout.topMargin: app.margins
                Layout.fillWidth: true
                text: detailsDialog.accessGranted ? qsTr("User") : qsTr("Access denied")
                font.bold: true
            }

            Label {
                Layout.fillWidth: true
                text: detailsDialog.user
                wrapMode: Text.WordWrap
                visible: detailsDialog.accessGranted
            }

            Label {
                Layout.topMargin: app.margins
                Layout.fillWidth: true
                text: qsTr("Fingerprint")
                font.bold: true
                visible: detailsDialog.accessGranted
            }

            Label {
                Layout.fillWidth: true
                text: detailsDialog.finger
                wrapMode: Text.WordWrap
                visible: detailsDialog.accessGranted
            }
        }
    }
}

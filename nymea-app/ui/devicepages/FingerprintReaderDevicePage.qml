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

//        Item {
//            Layout.fillWidth: true
//            Layout.preferredHeight: root.inputVisible ? inputColumn.implicitHeight : 0
//            Behavior on Layout.preferredHeight { NumberAnimation { duration: 130; easing.type: Easing.InOutQuad } }

//            ColumnLayout {
//                id: inputColumn
//                anchors { left: parent.left; bottom: parent.bottom; right: parent.right }

//                TextField {
//                    id: titleTextField
//                    Layout.fillWidth: true
//                    Layout.topMargin: app.margins
//                    Layout.leftMargin: app.margins; Layout.rightMargin: app.margins
//                    placeholderText: qsTr("Title")
//                }

//                TextArea {
//                    id: bodyTextField
//                    Layout.fillWidth: true
//                    Layout.leftMargin: app.margins; Layout.rightMargin: app.margins
//                    placeholderText: qsTr("Text")
//                    wrapMode: Text.WordWrap
//                }
//            }
//        }




        Button {
            Layout.fillWidth: true
            Layout.margins: app.margins
            text: qsTr("Manage access")
            onClicked: {
                pageStack.push(manageUsersComponent)
            }
        }

//        ThinDivider {}

        GenericTypeLogView {
            Layout.fillHeight: true
            Layout.fillWidth: true
            text: qsTr("%1 fingerprints recognized on this device in the last %2 days.")

            logsModel: LogsModel {
                deviceId: root.device.id
                engine: _engine
                live: true
                Component.onCompleted: update()
                typeIds: [root.accessGrantedEventType.id, root.accessDeniedEventType.id];

            }

            delegate: MeaListItemDelegate {
                width: parent.width
                iconName: "../images/notification.svg"
                text: model.typeId === root.accessGrantedEventType.id ? qsTr("Access granted for user %1").arg(model.value) : qsTr("Access denied")
                subText: Qt.formatDateTime(model.timestamp)
                progressive: false

                onClicked: {
                    var parts = model.value.trim().split(', ')
                    var popup = detailsPopup.createObject(root, {timestamp: model.timestamp, notificationTitle: parts[1], notificationBody: parts[0]});
                    popup.open();
                }
            }
        }
    }

    Component {
        id: manageUsersComponent
        Page {
            header: GuhHeader {
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

                    delegate: MeaListItemDelegate {
                        text: modelData
                        width: parent.width
                        progressive: false
                        iconName: "../images/account.svg"
                        canDelete: true
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
                }
            }
        }
    }

    Component {
        id: addUserComponent
        Page {
            id: addUserPage
            header: GuhHeader {
                text: qsTr("Add a new fingerprint")
                onBackPressed: pageStack.pop()
            }

            property bool error: false

            Connections {
                target: engine.deviceManager
                onExecuteActionReply: {
                    addUserPage.error = params["deviceError"] !== DeviceManager.DeviceErrorNoError
                    print("Execute action reply:", params);
                    addUserSwipeView.currentIndex++
                }
            }

            ColumnLayout {
                anchors.fill: parent
                SwipeView {
                    id: addUserSwipeView
                    Layout.fillWidth: true
                    Layout.preferredHeight: 200
                    Layout.alignment: Qt.AlignTop
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
                            Label {
                                text: qsTr("Please scan the fingerprint now")
                                Layout.fillWidth: true
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
                                Layout.fillWidth: true
                                font.pixelSize: app.largeFont
                                color: app.accentColor
                                text: addUserPage.error ? qsTr("Uh oh") :
                                                          qsTr("All done!")
                                horizontalAlignment: Text.AlignHCenter
                            }
                            Label {
                                text: addUserPage.error ? qsTr("Fingerprint could not be read.\nPlease try again.") :
                                                          qsTr("Fingerprint added!")
                                Layout.fillWidth: true
                                wrapMode: Text.WordWrap
                                horizontalAlignment: Text.AlignHCenter
                            }
                            Button {
                                Layout.fillWidth: true
                                text: qsTr("OK")
                                onClicked: pageStack.pop()
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
            property string notificationTitle
            property string notificationBody
            title: qsTr("Notification details")
            Label {
                Layout.fillWidth: true
                text: qsTr("Date sent")
                font.bold: true
            }

            Label {
                Layout.fillWidth: true
                text: Qt.formatDateTime(detailsDialog.timestamp)
            }
            Label {
                Layout.topMargin: app.margins
                Layout.fillWidth: true
                text: qsTr("Title")
                font.bold: true
            }

            Label {
                Layout.fillWidth: true
                text: detailsDialog.notificationTitle
                wrapMode: Text.WordWrap
            }
            Label {
                Layout.topMargin: app.margins
                Layout.fillWidth: true
                text: qsTr("Text")
                font.bold: true
            }

            Label {
                Layout.fillWidth: true
                text: detailsDialog.notificationBody
                wrapMode: Text.WordWrap
            }
        }
    }
}

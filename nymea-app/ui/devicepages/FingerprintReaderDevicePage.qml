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
                iconName: model.typeId === root.accessGrantedEventType.id ? "../images/tick.svg" : "../images/dialog-error-symbolic.svg"
                iconColor: model.typeId === root.accessGrantedEventType.id ? "green" : "red"
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

                    ColumnLayout {
                        anchors.centerIn: parent
                        width: 200
                        spacing: app.margins * 2
                        visible: parent.count === 0
                        Item {
                            Layout.fillWidth: true
                            Layout.preferredHeight: width
                            FingerprintVisual {
                                id: fingerprintVisual
                                anchors.centerIn: parent
                                scale: parent.height / implicitHeight
                            }
                        }

                        Button {
                            text: qsTr("Add a fingerprint")
                            onClicked: pageStack.push(addUserComponent)
                            Layout.fillWidth: true
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
                    addUserPage.error = params["deviceError"] !== "DeviceErrorNoError"
                    print("Execute action reply:", params["deviceError"]);
                    addUserSwipeView.currentIndex++
                }
            }

            ColumnLayout {
                anchors.fill: parent
                SwipeView {
                    id: addUserSwipeView
                    Layout.fillWidth: true
                    Layout.topMargin: app.margins * 2
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
                                text: qsTr("Please scan the fingerprint now")
                                Layout.fillWidth: true
                                font.pixelSize: app.largeFont
                                color: app.accentColor
                                horizontalAlignment: Text.AlignHCenter
                            }

                            Item {
                                Layout.preferredWidth: 200
                                Layout.preferredHeight: 200
                                Layout.alignment: Qt.AlignCenter

                                FingerprintVisual {
                                    id: fingerprintVisual
                                    scale: parent.height / implicitHeight

                                    anchors.centerIn: parent
                                    Timer {
                                        interval: 500
                                        property real position: 0
                                        running: addUserSwipeView.currentIndex == 1
                                        repeat: true
                                        onTriggered: {
                                            var masks = [];
                                            masks.push({x: 0, y: 0, width: 1, height: position})
                                            position += 0.1
                                            if (position < 1.1) {
                                                fingerprintVisual.masks = masks
                                            } else {
                                                position = 0
                                                fingerprintVisual.masks = []
                                            }
                                        }
                                    }
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

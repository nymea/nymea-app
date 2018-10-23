import QtQuick 2.5
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.1
import Nymea 1.0
import "../components"
import "../customviews"

DevicePageBase {
    id: root

    property bool inputVisible: false

    ColumnLayout {
        anchors.fill: parent

        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: root.inputVisible ? inputColumn.implicitHeight : 0
            Behavior on Layout.preferredHeight { NumberAnimation { duration: 130; easing.type: Easing.InOutQuad } }

            ColumnLayout {
                id: inputColumn
                anchors { left: parent.left; bottom: parent.bottom; right: parent.right }

                TextField {
                    id: titleTextField
                    Layout.fillWidth: true
                    Layout.topMargin: app.margins
                    Layout.leftMargin: app.margins; Layout.rightMargin: app.margins
                    placeholderText: qsTr("Title")
                }

                TextArea {
                    id: bodyTextField
                    Layout.fillWidth: true
                    Layout.leftMargin: app.margins; Layout.rightMargin: app.margins
                    placeholderText: qsTr("Text")
                    wrapMode: Text.WordWrap
                }
            }
        }




        Button {
            Layout.fillWidth: true
            Layout.margins: app.margins
            text: !root.inputVisible ?
                      qsTr("Send a notification")
                    : titleTextField.displayText.length > 0 ?
                          qsTr("Send now")
                        : qsTr("Cancel")
            onClicked: {
                if (root.inputVisible && titleTextField.displayText.length > 0) {
                    var actionType = root.deviceClass.actionTypes.findByName("notify")
                    var params = []
                    var titleParam = {}
                    titleParam["paramTypeId"] = actionType.paramTypes.findByName("title").id
                    titleParam["value"] = titleTextField.displayText
                    params.push(titleParam)
                    var bodyParam = {}
                    bodyParam["paramTypeId"] = actionType.paramTypes.findByName("body").id
                    bodyParam["value"] = bodyTextField.text
                    params.push(bodyParam)
                    engine.deviceManager.executeAction(root.device.id, actionType.id, params)
                }
                root.inputVisible = !root.inputVisible
            }
        }

        ThinDivider {}

        Label {
            Layout.fillWidth: true
            Layout.margins: app.margins
            wrapMode: Text.WordWrap
            text: qsTr("Sent notifications:")
        }


        GenericTypeLogView {
            Layout.fillHeight: true
            Layout.fillWidth: true

            logsModel: engine.jsonRpcClient.ensureServerVersion("1.10") ? logsModelNg : logsModel
            LogsModelNg {
                id: logsModelNg
                deviceId: root.device.id
                engine: _engine
                typeIds: [root.deviceClass.actionTypes.findByName("notify").id];
            }

            LogsModel {
                id: logsModel
                deviceId: root.device.id
                live: true
                engine: _engine
                Component.onCompleted: update()
                typeIds: [root.deviceClass.actionTypes.findByName("notify").id];
            }

            delegate: MeaListItemDelegate {
                width: parent.width
                iconName: "../images/notification.svg"
                text: model.value.trim()
                subText: Qt.formatDateTime(model.timestamp)
                progressive: false

                onClicked: {
                    print("a", model.value.trim())
                    var parts = model.value.trim().split(', ')
                    print("b", parts)
                    var popup = detailsPopup.createObject(root, {timestamp: model.timestamp, notificationTitle: parts[1], notificationBody: parts[0]});
                    popup.open();
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

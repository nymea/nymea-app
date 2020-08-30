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

            logsModel: LogsModel {
                id: logsModel
                thingId: root.device.id
                engine: _engine
                live: true
                typeIds: [root.deviceClass.actionTypes.findByName("notify").id];
            }

            delegate: NymeaListItemDelegate {
                width: parent.width
                iconName: app.interfaceToIcon("notifications")
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

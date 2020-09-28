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

    QtObject {
        id: d
        property int pendingAction: -1
    }

    Connections {
        target: engine.thingManager
        onExecuteActionReply: {
            if (commandId == d.pendingAction) {
                d.pendingAction = -1
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent

        Label {
            Layout.fillWidth: true
            Layout.margins: app.margins
            wrapMode: Text.WordWrap
            text: qsTr("Sent notifications:")
            visible: logsModel.count > 0 && !logsModel.busy
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
                    var parts = model.value.trim().split(', ')
                    var popup = detailsPopup.createObject(root, {timestamp: model.timestamp, notificationTitle: parts[0], notificationBody: parts[1]});
                    popup.open();
                }
            }

            EmptyViewPlaceholder {
                anchors.centerIn: parent
                width: parent.width - app.margins * 2
                title: qsTr("No messages sent yet.")
                text: qsTr("Sent messages will appear here.")
                imageSource: "../images/messaging-app-symbolic.svg"
                buttonVisible: false
                visible: logsModel.count == 0 && !logsModel.busy
            }
        }

        ThinDivider {}

        RowLayout {
            Layout.fillWidth: true
            Layout.margins: app.margins
            spacing: app.margins

            ColumnLayout {
                id: inputColumn
                anchors { left: parent.left; bottom: parent.bottom; right: parent.right }

                TextField {
                    id: titleTextField
                    Layout.fillWidth: true
                    placeholderText: qsTr("Title")
                }

                TextArea {
                    id: bodyTextField
                    Layout.fillWidth: true
                    placeholderText: qsTr("Text")
                    wrapMode: Text.WordWrap
                }
            }

            Item {
                Layout.preferredWidth: app.iconSize
                Layout.preferredHeight: inputColumn.height
                ColorIcon {
                    anchors.centerIn: parent
                    height: app.iconSize
                    width: app.iconSize
                    name: "../images/send.svg"
                    color: titleTextField.displayText.length > 0 ? app.accentColor : keyColor
                    visible: d.pendingAction == -1
                }

                BusyIndicator {
                    anchors.centerIn: parent
                    visible: d.pendingAction != -1
                    running: visible
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        print("clicked!")
                        if (titleTextField.displayText.length > 0) {
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
                            d.pendingAction = engine.deviceManager.executeAction(root.device.id, actionType.id, params)
                            titleTextField.clear();
                            bodyTextField.clear();
                        }
                    }
                }
            }
        }
    }

    BusyIndicator {
        anchors.centerIn: parent
        visible: logsModel.busy
        running: visible
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

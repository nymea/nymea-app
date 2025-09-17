// SPDX-License-Identifier: GPL-3.0-or-later

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
* Copyright (C) 2013 - 2024, nymea GmbH
* Copyright (C) 2024 - 2025, chargebyte austria GmbH
*
* This file is part of nymea-app.
*
* nymea-app is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* nymea-app is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with nymea-app. If not, see <https://www.gnu.org/licenses/>.
*
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Nymea

import "../components"
import "../customviews"

ThingPageBase {
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

    function sendMessage(title, text) {
        print("sending message", title, text)
        var actionType = root.thing.thingClass.actionTypes.findByName("notify")
        var params = []
        var titleParam = {}
        titleParam["paramTypeId"] = actionType.paramTypes.findByName("title").id
        titleParam["value"] = title
        params.push(titleParam)
        var bodyParam = {}
        bodyParam["paramTypeId"] = actionType.paramTypes.findByName("body").id
        bodyParam["value"] = text
        params.push(bodyParam)
        d.pendingAction = engine.thingManager.executeAction(root.thing.id, actionType.id, params)
        titleTextField.clear();
        bodyTextField.clear();
    }

    ColumnLayout {
        id: content
        anchors.fill: parent

        RowLayout {
            id: inputPane
            Layout.fillWidth: true
            Layout.margins: app.margins
            spacing: app.margins

            ColumnLayout {
                id: inputColumn

                TextField {
                    id: titleTextField
                    Layout.fillWidth: true
                    placeholderText: qsTr("Title")
                }

                ScrollView {
                    Layout.preferredWidth: inputPane.width - Style.iconSize - inputPane.spacing
                    Layout.maximumHeight: content.height - y - app.margins
                    contentWidth: width

                    TextArea {
                        id: bodyTextField
                        placeholderText: qsTr("Text")
                        wrapMode: TextArea.WrapAtWordBoundaryOrAnywhere
                    }
                }
            }

            Item {
                id: sendButton
                Layout.preferredWidth: Style.iconSize
                Layout.preferredHeight: inputColumn.height
                ColorIcon {
                    anchors { horizontalCenter: parent.horizontalCenter; bottom: parent.bottom; margins: app.margins }
                    height: Style.iconSize
                    width: Style.iconSize
                    name: "qrc:/icons/send.svg"
                    color: titleTextField.displayText.length > 0 ? Style.accentColor : Style.iconColor
                    visible: d.pendingAction == -1
                }

                BusyIndicator {
                    anchors { horizontalCenter: parent.horizontalCenter; bottom: parent.bottom; margins: app.margins }
                    visible: d.pendingAction != -1
                    running: visible
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        print("clicked!")
                        bodyTextField.focus = false
                        if (titleTextField.displayText.length > 0) {
                            root.sendMessage(titleTextField.displayText, bodyTextField.text)
                            titleTextField.clear();
                            bodyTextField.clear();
                        }
                    }
                }
            }
        }


        Loader {
            Layout.fillWidth: true
            Layout.fillHeight: true
            sourceComponent: {
                if (engine.jsonRpcClient.ensureServerVersion("8.0")) {
                    return logViewComponent
                } else {
                    return logViewComponentPre80
                }
            }
        }
    }

    Component {
        id: logViewComponentPre80
        ListView {
            id: logView
            Layout.fillHeight: true
            Layout.fillWidth: true
            clip: true

            BusyIndicator {
                anchors.centerIn: parent
                visible: logsModel.busy
                running: visible
            }

            model: LogsModel {
                id: logsModel
                thingId: root.thing.id
                engine: _engine
                live: true
                typeIds: [root.thing.thingClass.actionTypes.findByName("notify").id];
            }

            delegate: BigTile {
                id: itemDelegate
                showHeader: false
                width: logView.width - app.margins
                anchors.horizontalCenter: parent.horizontalCenter

                // Note: This will go wrong if the title contains ", ". Known shortcoming of the log db
                readonly property string title: model.value.trim().replace(/, ?.*/, "")
                readonly property string text: model.value.trim().replace(/.*, ?/, "")

                contentItem: RowLayout {
                    ColumnLayout {
                        Label {
                            Layout.fillWidth: true
                            text: itemDelegate.title
                            elide: Text.ElideRight
                        }
                        GridLayout {
                            Layout.fillWidth: true
                            columns: textLabel.implicitWidth + dateLayout.implicitWidth < width ? 2 : 1

                            Label {
                                id: textLabel
                                Layout.fillWidth: true
                                text: itemDelegate.text
                                font.pixelSize: app.smallFont
                                wrapMode: Text.WordWrap
                            }

                            RowLayout {
                                id: dateLayout
                                Layout.fillWidth: true
                                spacing: app.margins / 2
                                Label {
                                    Layout.fillWidth: true
                                    horizontalAlignment: Text.AlignRight
                                    text: Qt.formatDateTime(model.timestamp)
                                    font.pixelSize: app.extraSmallFont
                                }
                                ColorIcon {
                                    Layout.preferredWidth: Style.smallIconSize
                                    Layout.preferredHeight: Style.smallIconSize
                                    name: "qrc:/icons/dialog-warning-symbolic.svg"
                                    color: "red"
                                    visible: model.errorCode !== ""
                                }
                            }
                        }
                    }
                }

                onClicked: {
                    var popup = detailsPopup.createObject(root,
                                                          {
                                                              timestamp: model.timestamp,
                                                              notificationTitle: itemDelegate.title,
                                                              notificationBody: itemDelegate.tet,
                                                              errorCode: model.errorCode
                                                          });
                    popup.open();
                }
            }

            EmptyViewPlaceholder {
                anchors.centerIn: parent
                width: parent.width - app.margins * 2
                title: qsTr("No messages sent yet.")
                text: qsTr("Sent messages will appear here.")
                imageSource: "qrc:/icons/messaging-app-symbolic.svg"
                buttonVisible: false
                visible: logsModel.count == 0 && !logsModel.busy
            }
        }
    }

    Component {
        id: logViewComponent
        ListView {
            id: logView
            Layout.fillHeight: true
            Layout.fillWidth: true
            clip: true

            BusyIndicator {
                anchors.centerIn: parent
                visible: logsModel.busy
                running: visible
            }

            model: NewLogsModel {
                id: logsModel
                engine: _engine
//                live: true
                source: "action-" + root.thing.id + "-notify"
                sortOrder: Qt.DescendingOrder
            }

            delegate: BigTile {
                id: itemDelegate
                showHeader: false
                width: logView.width - app.margins
                anchors.horizontalCenter: parent.horizontalCenter

                property var params: JSON.parse(model.values.params)

                contentItem: RowLayout {
                    ColumnLayout {
                        Label {
                            Layout.fillWidth: true
                            text: itemDelegate.params.title
                            elide: Text.ElideRight
                        }
                        GridLayout {
                            Layout.fillWidth: true
                            columns: textLabel.implicitWidth + dateLayout.implicitWidth < width ? 2 : 1

                            Label {
                                id: textLabel
                                Layout.fillWidth: true
                                text: itemDelegate.params.body
                                font.pixelSize: app.smallFont
                                wrapMode: Text.WordWrap
                            }

                            RowLayout {
                                id: dateLayout
                                Layout.fillWidth: true
                                spacing: app.margins / 2
                                Label {
                                    Layout.fillWidth: true
                                    horizontalAlignment: Text.AlignRight
                                    text: Qt.formatDateTime(model.timestamp)
                                    font.pixelSize: app.extraSmallFont
                                }
                                ColorIcon {
                                    Layout.preferredWidth: Style.smallIconSize
                                    Layout.preferredHeight: Style.smallIconSize
                                    name: "qrc:/icons/dialog-warning-symbolic.svg"
                                    color: "red"
                                    visible: model.values.status !== "ThingErrorNoError"
                                }
                            }
                        }
                    }
                }

                onClicked: {
                    var popup = detailsPopup.createObject(root,
                                                          {
                                                              timestamp: model.timestamp,
                                                              notificationTitle: itemDelegate.params.title,
                                                              notificationBody: itemDelegate.params.body,
                                                              errorCode: model.status
                                                          });
                    popup.open();
                }
            }

            EmptyViewPlaceholder {
                anchors.centerIn: parent
                width: parent.width - app.margins * 2
                title: qsTr("No messages sent yet.")
                text: qsTr("Sent messages will appear here.")
                imageSource: "qrc:/icons/messaging-app-symbolic.svg"
                buttonVisible: false
                visible: logsModel.count == 0 && !logsModel.busy
            }
        }
    }

    Component {
        id: detailsPopup

        NymeaDialog {
            id: detailsDialog
            standardButtons: Dialog.NoButton
            property string timestamp
            property string notificationTitle
            property string notificationBody
            property string errorCode
            title: qsTr("Notification details")
            headerIcon: "qrc:/icons/messaging-app-symbolic.svg"
            RowLayout {
                ColumnLayout {

                    Label {
                        Layout.fillWidth: true
                        text: detailsDialog.errorCode == "" || detailsDialog.errorCode == "ThingErrorNoError" ? qsTr("Date sent") : qsTr("Sending failed")
                        font.bold: true
                    }
                    Label {
                        Layout.fillWidth: true
                        text: Qt.formatDateTime(detailsDialog.timestamp)
                    }
                }
                ColorIcon {
                    Layout.preferredWidth: Style.largeIconSize
                    Layout.preferredHeight: Style.largeIconSize
                    name: "qrc:/icons/dialog-warning-symbolic.svg"
                    color: "red"
                    visible: detailsDialog.errorCode !== ""
                }
            }

            Label {
                Layout.topMargin: Style.margins
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

            RowLayout {
                Item {
                    Layout.fillWidth: true
                }
                Button {
                    text: qsTr("Resend")
                    onClicked: root.sendMessage(detailsDialog.notificationTitle, detailsDialog.notificationBody)
                }
                Button {
                    text: qsTr("Close")
                    onClicked: detailsDialog.close()
                }
            }
        }
    }
}

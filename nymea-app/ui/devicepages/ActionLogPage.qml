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

import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2
import QtQuick.Layouts 1.1
import Nymea 1.0
import "../components"
import "../customviews"

Page {
    id: root

    property Thing thing: null
    property ActionType actionType: null

    readonly property bool isLogged: thing.loggedActionTypeIds.indexOf(actionType.id) >= 0

    header: NymeaHeader {
        text: qsTr("History for %1").arg(root.actionType.displayName)
        onBackPressed: pageStack.pop()

        HeaderButton {
            imageSource: "delete"
            visible: root.isLogged
            onClicked: {
                var popup = deleteLogsComponent.createObject(root)
                popup.open()
            }

            Component {
                id: deleteLogsComponent
                NymeaDialog {
                    title: qsTr("Remove logs?")
                    text: qsTr("Do you want to remove the log for this action and disable logging?")
                    standardButtons: Dialog.No | Dialog.Yes
                    onAccepted: engine.thingManager.setActionLogging(root.thing.id, root.actionType.id, false)
                }
            }
        }
    }

    NewLogsModel {
        id: logsModel
        engine: _engine
        source: "action-" + root.thing.id + "-" + root.actionType.name
        sortOrder: Qt.DescendingOrder
    }


    ListView {
        id: listView
        visible: root.isLogged
        model: logsModel
        clip: true
        anchors.fill: parent
        ScrollBar.vertical: ScrollBar {}

        delegate: NymeaItemDelegate {
            id: delegate
            width: listView.width
            height: contentColumn.implicitHeight + Style.margins
            leftPadding: 0
            rightPadding: 0
            topPadding: 0
            bottomPadding: 0
            property NewLogEntry entry: logsModel.get(index)

            contentItem: RowLayout {
                id: contentColumn
                anchors { left: parent.left; right: parent.right; margins: app.margins / 2 }
                ColorIcon {
                    Layout.preferredWidth: Style.iconSize
                    Layout.preferredHeight: width
                    Layout.alignment: Qt.AlignVCenter
                    color: delegate.entry.values.status === "ThingErrorNoError"
                             ? Style.iconColor
                             : Style.red
                    name: delegate.entry.values.triggeredBy === "TriggeredByUser"
                          ? "account"
                          : "magic"
                }
                ColumnLayout {
                    RowLayout {
                        Label {
                            Layout.fillWidth: true
                            text: (delegate.entry.values.triggeredBy === "TriggeredByUser" ? qsTr("User action") : qsTr("Automation"))
                                  + " - "
                                  + (delegate.entry.values.status === "ThingErrorNoError" ? qsTr("success") : qsTr("Failure: %1").arg(delegate.entry.values.status))
                            elide: Text.ElideRight
                        }
                        Label {
                            text: Qt.formatDateTime(model.timestamp,"dd.MM.yy - hh:mm:ss")
                            elide: Text.ElideRight
                            font: Style.smallFont
                        }
                    }

                    Label {
                        Layout.fillWidth: true
                        text: {
                            var ret = []
                            var values = JSON.parse(entry.values.params)
                            for (var i = 0; i < root.actionType.paramTypes.count; i++) {
                                var paramType = root.actionType.paramTypes.get(i)
                                ret.push(paramType.displayName + ": " + Types.toUiValue(values[paramType.name], paramType.unit) + " " + Types.toUiUnit(paramType.unit))
                            }
                            return ret.join("<br>")
                        }
                        textFormat: Text.RichText
                        elide: Text.ElideRight
                        font: Style.smallFont
                        visible: text.length > 0
                    }
                }
            }
        }
    }

    EmptyViewPlaceholder {
        anchors.centerIn: parent
        width: parent.width - app.margins * 2
        title: qsTr("No data")
        text: qsTr("This action has not been executed yet.")
        imageSource: "qrc:/icons/logs.svg"
        buttonVisible: false
        visible: root.isLogged && logsModel.count == 0
    }

    EmptyViewPlaceholder {
        anchors.centerIn: parent
        width: parent.width - app.margins * 2
        title: qsTr("Logging not enabled")
        text: qsTr("This action is not being logged.")
        imageSource: "qrc:/icons/logs.svg"
        buttonText: qsTr("Enable logging")
        visible: !root.isLogged
        onButtonClicked: {
            engine.thingManager.setActionLogging(root.thing.id, root.actionType.id, true)
        }
    }
}


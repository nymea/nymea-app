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

import QtQuick 2.8
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import Nymea 1.0
import "../components"

Page {
    id: root
    header: NymeaHeader {
        text: qsTr("Log viewer")
        onBackPressed: pageStack.pop()

        HeaderButton {
            imageSource: "qrc:/icons/down.svg"
            color: root.autoScroll ? Style.accentColor : Style.iconColor
            onClicked: {
                listView.positionViewAtEnd();
                root.autoScroll = !root.autoScroll
            }
        }
    }

    property bool autoScroll: true

    LogsModel {
        id: logsModel
        //engine: _engine
        live: true
    }

    NewLogsModel {
        id: newLogsModel
        engine: _engine
//        sources: ["core", "rules", "scripts"]
        source: "core"
    }

    BusyIndicator {
        anchors.centerIn: listView
        visible: logsModel.busy
    }

    ListView {
        id: listView
        model: newLogsModel
        anchors.fill: parent
        clip: true
        headerPositioning: ListView.OverlayHeader

        onDraggingChanged: {
            if (dragging) {
                root.autoScroll = false;
            }
        }

        ScrollBar.vertical: ScrollBar {}

        BusyIndicator {
            anchors.centerIn: parent
            visible: listView.model.busy
        }

        delegate: NymeaItemDelegate {
            id: delegate
            width: listView.width
            leftPadding: 0
            rightPadding: 0
            topPadding: 0
            bottomPadding: 0
            property NewLogEntry entry: newLogsModel.get(index)
            property string event: entry.values.event
            property string shutdownReason: {
                switch (entry.values.shutdownReason) {
                case "ShutdownReasonTerm":
                    return qsTr("Terminated by system")
                case "ShutdownReasonQuit":
                    return qsTr("Application quit")
                case "ShutdownReasonFailure":
                    return qsTr("Application error")
                default:
                    return qsTr("Unknown reason")
                }
            }

            contentItem: RowLayout {
                id: contentColumn
                anchors { left: parent.left; right: parent.right; margins: app.margins / 2 }
                ColorIcon {
                    Layout.preferredWidth: Style.iconSize
                    Layout.preferredHeight: width
                    Layout.alignment: Qt.AlignVCenter
                    color: delegate.event == "started"
                           ? Style.accentColor
                           : delegate.entry.values.shutdownReason === "ShutdownReasonFailure"
                             ? Style.red
                             : Style.iconColor
                    name: {
                        switch (delegate.event) {
                        case "started":
                            return "system-restart"
                        case "stopped":
                            switch (delegate.entry.values.shutdownReason) {
                            case "ShutdownReasonQuit":
                                return "system-log-out"
                            case "ShutdownReasonTerm":
                                return "system-shutdown"
                            case "ShutdownReasonFailure":
                                return "dialog-error-symbolic"
                            }
                        }
                    }
                }
                ColumnLayout {
                    RowLayout {
                        Label {
                            Layout.fillWidth: true
                            text: {
                                switch (delegate.event) {
                                case "started":
                                    return qsTr("Started")
                                case "stopped":
                                    return qsTr("Stopped")
                                default:
                                    console.warn("LogViewer: Unhand event", delegate.event)
                                    return qsTr(delegate.event)
                                }
                            }
                            elide: Text.ElideRight
                        }
                        Label {
                            text: Qt.formatDateTime(model.timestamp,"dd.MM.yy - hh:mm:ss")
                            elide: Text.ElideRight
                            font: Style.smallFont
                        }
                    }
                    Label {
                        text: delegate.shutdownReason
                        visible: delegate.event == "stopped"
                        elide: Text.ElideRight
                        font: Style.smallFont
                    }
                }
            }
        }
    }
}

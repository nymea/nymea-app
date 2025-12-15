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
import "../../components"
import Nymea

Item {
    id: pane
    implicitHeight: shown ? 40 + 10 * app.smallFont : collapsedHeight

    readonly property int collapsedHeight: 25

    readonly property bool shown: (shownOverride === "auto" && autoWouldShow)
                                  || shownOverride == "shown"
    readonly property alias autoWouldShow: d.autoWouldShow
    property string shownOverride: "auto" // "shown", "hidden"

    default property alias panels: contentContainer.data

    QtObject {
        id: d
        property bool autoWouldShow: false
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0
        RowLayout {
            id: panelHeader
            Layout.fillWidth: true
            Layout.rightMargin: app.margins
            Layout.leftMargin: app.margins
            Layout.maximumHeight: 24
            Layout.minimumHeight: 24

            TabBar {
                id: panelTabs
                Layout.fillHeight: true

                Repeater {
                    model: contentContainer.data

                    TabButton {
                        implicitHeight: panelHeader.height
                        background: Rectangle {
                            implicitWidth: 200
                            implicitHeight: panelHeader.height
                            color: Style.backgroundColor
                            Label {
                                anchors.centerIn: parent
                                text: contentContainer.data[index].title
                                font.pixelSize: app.smallFont
                            }
                        }
                        Binding {
                            target: contentContainer.data[index]
                            property: "visible"
                            value: panelTabs.currentIndex === index
                        }
                        Connections {
                            target: contentContainer.data[index]
                            onRaise: {
                                panelTabs.currentIndex = index
                                d.autoWouldShow = true;
                            }
                        }
                    }
                }
            }
            Item {
                Layout.fillHeight: true
                Layout.fillWidth: true
            }

            ColorIcon {
                name: "qrc:/icons/edit-clear.svg"
                enabled: contentContainer.data[panelTabs.currentIndex].clearEnabled
                color: enabled ? Style.accentColor : Style.iconColor
                Layout.preferredHeight: Style.iconSize  / 2
                Layout.preferredWidth: height
                MouseArea {
                    anchors.fill: parent
                    anchors.margins: -5
                    onClicked: contentContainer.data[panelTabs.currentIndex].clear()
                }
            }

            ColorIcon {
                name: pane.shown ? "qrc:/icons/down.svg" : "qrc:/icons/up.svg"
                Layout.preferredHeight: Style.iconSize  / 2
                Layout.preferredWidth: height
                color: Style.accentColor
                MouseArea {
                    anchors.fill: parent
                    anchors.margins: -5
                    onClicked: {
                        if (pane.shown) {
                            if (pane.autoWouldShow) {
                                pane.shownOverride = "hidden"
                            } else {
                                pane.shownOverride = "auto"
                            }
                        } else {
                            if (pane.autoWouldShow) {
                                pane.shownOverride = "auto"
                            } else {
                                pane.shownOverride = "shown"
                            }
                        }
                    }
                }
            }
        }

        ThinDivider {}

        Item {
            id: contentContainer
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true

        }
    }
}

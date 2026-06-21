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

import "qrc:/ui/components"

Page {
    id: root

    // One row of the icon legend.
    component LegendRow: RowLayout {
        id: legendRow
        Layout.fillWidth: true
        spacing: Style.margins

        property alias iconName: icon.name
        property alias iconColor: icon.color
        property string title
        property string description

        ColorIcon {
            id: icon
            Layout.preferredHeight: Style.iconSize
            Layout.preferredWidth: Style.iconSize
            Layout.alignment: Qt.AlignTop
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 0
            Label {
                Layout.fillWidth: true
                font: Style.smallFont
                text: legendRow.title
                wrapMode: Text.WordWrap
            }
            Label {
                Layout.fillWidth: true
                font: Style.extraSmallFont
                opacity: 0.7
                text: legendRow.description
                wrapMode: Text.WordWrap
            }
        }
    }

    header: NymeaHeader {
        text: qsTr("Topology help")
        onBackPressed: pageStack.pop()
    }

    Flickable {
        anchors.fill: parent
        contentHeight: content.implicitHeight
        clip: true

        ColumnLayout {
            id: content
            width: parent.width
            spacing: Style.margins

            ColumnLayout {
                Layout.fillWidth: true
                Layout.margins: Style.margins
                spacing: Style.margins

                Label {
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    text: qsTr("The topology mirrors your electrical installation: fuses and the chargers connected below them. The dynamic load manager keeps every node within its limit by distributing the available current to the chargers.")
                }

                Label {
                    Layout.fillWidth: true
                    font: Style.smallFont
                    color: Style.accentColor
                    text: qsTr("Nodes")
                }

                LegendRow {
                    iconName: "qrc:/icons/energy.svg"
                    iconColor: Style.iconColor
                    title: qsTr("Fuse")
                    description: qsTr("A fuse with a current limit. Chargers and further fuses connect below it.")
                }

                LegendRow {
                    iconName: "qrc:/icons/ev-charger.svg"
                    iconColor: Style.accentColor
                    title: qsTr("Charger")
                    description: qsTr("A wallbox. Its bars show the current per phase against the maximum charging current.")
                }

                Label {
                    Layout.fillWidth: true
                    font: Style.smallFont
                    color: Style.accentColor
                    text: qsTr("Status icons")
                }

                LegendRow {
                    iconName: "qrc:/icons/smartmeter.svg"
                    iconColor: Style.accentColor
                    title: qsTr("Measured")
                    description: qsTr("The node has its own meter and shows real measurements. Without it the values are summed up from the nodes below and unmeasured loads are not included.")
                }

                LegendRow {
                    iconName: "qrc:/icons/dialog-warning-symbolic.svg"
                    iconColor: Style.orange
                    title: qsTr("Warning")
                    description: qsTr("The node needs attention, for example it is operating close to its limit.")
                }

                LegendRow {
                    iconName: "qrc:/icons/connections/network-wired-offline.svg"
                    iconColor: Style.red
                    title: qsTr("Disconnected")
                    description: qsTr("The charger is currently not reachable. The tile glows red to signal the error.")
                }

                Label {
                    Layout.fillWidth: true
                    font: Style.smallFont
                    color: Style.accentColor
                    text: qsTr("Bars and flow")
                }

                Label {
                    Layout.fillWidth: true
                    font: Style.extraSmallFont
                    opacity: 0.7
                    wrapMode: Text.WordWrap
                    text: qsTr("Each node shows one progress bar per phase (L1, L2, L3) so you can see how the load is balanced and how close it is to the limit. The connecting lines visualise the live power flow; a thicker line means more current.")
                }
            }
        }
    }
}

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
import QtQuick.Layouts
import QtQuick.Controls

import Nymea

import "qrc:/ui/components"

// Simple topology node: a rounded rectangle with the name above and the limit
// centered. Fuse nodes with an assigned meter additionally show the live power.
Item {
    id: root

    property string nodeType: "fuse"
    property string displayName: ""
    property real limit: -1
    property real nominalVoltage: 230
    property string nodeId: ""
    // The node's resolved load { l1, l2, l3 } in Amps, or null when unknown.
    property var measuredLoad: null

    signal clicked()

    readonly property bool isCharger: nodeType === "charger"

    readonly property bool hasMeasured: measuredLoad !== null && measuredLoad !== undefined
    readonly property real measuredMax: hasMeasured
        ? Math.max(measuredLoad.l1 || 0, measuredLoad.l2 || 0, measuredLoad.l3 || 0) : 0
    readonly property real measuredPowerKw: hasMeasured
        ? ((measuredLoad.l1 || 0) + (measuredLoad.l2 || 0) + (measuredLoad.l3 || 0)) * nominalVoltage / 1000 : 0

    Label {
        id: nameLabel
        anchors.bottom: card.top
        anchors.bottomMargin: Style.smallMargins
        anchors.horizontalCenter: card.horizontalCenter
        width: card.width
        horizontalAlignment: Text.AlignHCenter
        elide: Text.ElideRight
        font: Style.smallFont
        text: root.displayName
    }

    Rectangle {
        id: card
        anchors.fill: parent
        radius: Style.cornerRadius
        color: Style.tileBackgroundColor
        border.width: 1
        border.color: root.isCharger ? Style.accentColor : Style.iconColor

        ColumnLayout {
            anchors.centerIn: parent
            width: parent.width - Style.smallMargins * 2
            spacing: 0

            ColorIcon {
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredHeight: Style.iconSize
                Layout.preferredWidth: Style.iconSize
                visible: root.isCharger
                name: "qrc:/icons/ev-charger.svg"
                color: Style.accentColor
            }

            Label {
                Layout.alignment: Qt.AlignHCenter
                visible: !root.isCharger
                font: Style.bigFont
                text: root.limit >= 0
                      ? (root.hasMeasured
                         ? qsTr("%1 kW / %2 A").arg(root.measuredPowerKw.toFixed(1)).arg(root.limit)
                         : qsTr("%1 A").arg(root.limit))
                      : "—"
            }

            Label {
                Layout.alignment: Qt.AlignHCenter
                visible: root.isCharger && root.hasMeasured
                font: Style.smallFont
                text: qsTr("%1 kW").arg(root.measuredPowerKw.toFixed(1))
            }
        }
    }

    TapHandler {
        onTapped: root.clicked()
    }
}

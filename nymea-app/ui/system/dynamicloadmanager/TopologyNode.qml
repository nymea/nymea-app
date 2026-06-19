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
import Nymea

import "qrc:/ui/components"

// Simple topology node: a rounded rectangle with the name above and the limit
// centered. Fuse nodes with an assigned meter additionally show the live power.
Item {
    id: root

    property string nodeType: "fuse"
    property string displayName: ""
    property real limit: -1
    property string meterThingId: ""

    signal clicked()

    readonly property bool isCharger: nodeType === "charger"

    // Resolve the assigned meter thing and watch its currentPower state live.
    readonly property Thing meterThing: meterThingId !== ""
        ? _engine.thingManager.things.getThing(meterThingId) : null
    // Typed as var to avoid the name clash with QtQuick's State type.
    readonly property var currentPowerState: meterThing ? meterThing.stateByName("currentPower") : null
    readonly property bool hasPower: currentPowerState !== null

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
                      ? (root.hasPower
                         ? qsTr("%1 A · %2 kW").arg(root.limit).arg((root.currentPowerState.value / 1000).toFixed(1))
                         : qsTr("%1 A").arg(root.limit))
                      : "—"
            }
        }
    }

    TapHandler {
        onTapped: root.clicked()
    }
}

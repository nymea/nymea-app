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

// Read-only overview of a topology node's configuration, opened by tapping a
// node in the main view. Offers a shortcut into the node's history page.
NymeaDialog {
    id: root

    // The DynamicLoadManagerManager owning the node (passed on to the history page).
    property var manager: null
    // The topology layout entry of the tapped node.
    property var node: ({})

    readonly property bool isCharger: node.nodeType === "charger"

    title: node.displayName ? node.displayName : qsTr("Node")
    standardButtons: Dialog.NoButton

    function phaseLabel(value) {
        switch (value) {
        case "gridL1": return qsTr("Grid L1")
        case "gridL2": return qsTr("Grid L2")
        case "gridL3": return qsTr("Grid L3")
        }
        return value
    }
    function mappedPhase(chargerPhase, fallback) {
        return (node.phaseMapping && node.phaseMapping[chargerPhase] !== undefined)
                ? node.phaseMapping[chargerPhase] : fallback
    }
    function limitValue(phase) {
        return (node.fixedLimit && node.fixedLimit[phase] !== undefined) ? node.fixedLimit[phase] : -1
    }
    readonly property bool hasPerPhaseLimit: {
        var l1 = limitValue("l1"), l2 = limitValue("l2"), l3 = limitValue("l3")
        return !(l1 === l2 && l2 === l3)
    }

    readonly property Thing chargerThing: isCharger && node.thingId
        ? engine.thingManager.things.getThing(node.thingId) : null
    readonly property Thing meterThing: !isCharger && node.meterThingId
        ? engine.thingManager.things.getThing(node.meterThingId) : null

    GridLayout {
        Layout.fillWidth: true
        columns: 2
        columnSpacing: Style.bigMargins
        rowSpacing: Style.smallMargins

        Label { text: qsTr("Type") }
        Label {
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignRight
            color: Style.accentColor
            text: root.isCharger ? qsTr("Charger") : qsTr("Fuse")
        }

        Label { text: qsTr("Name") }
        Label {
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignRight
            elide: Text.ElideRight
            text: root.node.displayName ? root.node.displayName : "-"
        }

        // Fuse: fixed limit, either a single value or per-phase.
        Label {
            visible: !root.isCharger && !root.hasPerPhaseLimit
            text: qsTr("Fixed limit")
        }
        Label {
            visible: !root.isCharger && !root.hasPerPhaseLimit
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignRight
            text: root.limitValue("l1") >= 0 ? qsTr("%1 A").arg(root.limitValue("l1")) : "-"
        }

        Label {
            visible: !root.isCharger && root.hasPerPhaseLimit
            text: qsTr("Fixed limit")
        }
        Label {
            visible: !root.isCharger && root.hasPerPhaseLimit
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignRight
            text: qsTr("%1 / %2 / %3 A")
                .arg(root.limitValue("l1")).arg(root.limitValue("l2")).arg(root.limitValue("l3"))
        }

        // Fuse: optional meter assignment.
        Label {
            visible: !root.isCharger
            text: qsTr("Meter")
        }
        Label {
            visible: !root.isCharger
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignRight
            elide: Text.ElideRight
            text: root.meterThing ? root.meterThing.name : qsTr("None")
        }

        // Charger: assigned charger thing.
        Label {
            visible: root.isCharger
            text: qsTr("EV charger")
        }
        Label {
            visible: root.isCharger
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignRight
            elide: Text.ElideRight
            text: root.chargerThing ? root.chargerThing.name : qsTr("Unassigned")
        }

        // Charger: phase mapping (charger phase -> grid phase).
        Label {
            visible: root.isCharger
            text: qsTr("Phase mapping")
        }
        ColumnLayout {
            visible: root.isCharger
            Layout.fillWidth: true
            spacing: 0
            Label {
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignRight
                font: Style.smallFont
                text: qsTr("Charger L1 → %1").arg(root.phaseLabel(root.mappedPhase("chargerL1", "gridL1")))
            }
            Label {
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignRight
                font: Style.smallFont
                text: qsTr("Charger L2 → %1").arg(root.phaseLabel(root.mappedPhase("chargerL2", "gridL2")))
            }
            Label {
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignRight
                font: Style.smallFont
                text: qsTr("Charger L3 → %1").arg(root.phaseLabel(root.mappedPhase("chargerL3", "gridL3")))
            }
        }
    }

    ThinDivider { Layout.fillWidth: true }

    Button {
        Layout.fillWidth: true
        text: qsTr("Show history")
        onClicked: {
            pageStack.push(Qt.resolvedUrl("NodeHistoryPage.qml"), { "manager": root.manager, "node": root.node })
            root.close()
        }
    }
    Button {
        Layout.fillWidth: true
        flat: true
        text: qsTr("Close")
        onClicked: root.close()
    }
}

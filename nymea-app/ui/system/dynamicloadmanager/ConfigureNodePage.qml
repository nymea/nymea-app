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

SettingsPageBase {
    id: root

    // The DynamicLoadManagerManager to issue the updateNode call on.
    property var manager: null
    // The topology layout entry of the node to configure.
    property var node: ({})

    readonly property bool isCharger: node.nodeType === "charger"

    title: qsTr("Configure node")

    readonly property var phaseOptions: ["gridL1", "gridL2", "gridL3"]
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
    function limitValue(phase, fallback) {
        return (node.fixedLimit && node.fixedLimit[phase] !== undefined)
                ? node.fixedLimit[phase] : fallback
    }
    // True if the configured limits differ between phases, so the page opens
    // in per-phase mode rather than the single-value default.
    readonly property bool hasPerPhaseLimit: {
        if (!node.fixedLimit)
            return false
        var l1 = limitValue("l1", 0), l2 = limitValue("l2", 0), l3 = limitValue("l3", 0)
        return !(l1 === l2 && l2 === l3)
    }

    function selectedChargerId() {
        return chargerCombo.currentIndex >= 0 && chargerProxy.count > 0
                ? chargerProxy.get(chargerCombo.currentIndex).id : ""
    }
    function selectedMeterId() {
        return meterCombo.currentIndex >= 0 && meterProxy.count > 0
                ? meterProxy.get(meterCombo.currentIndex).id : ""
    }

    readonly property bool inputValid: nameField.text.trim().length > 0
                                       && (!isCharger || selectedChargerId() !== "")

    // Live status for this node, re-evaluated on every status update.
    readonly property var nodeStatus: {
        var nodes = manager && manager.status && manager.status.nodes ? manager.status.nodes : null
        return nodes && nodes[node.id] ? nodes[node.id] : null
    }
    function tripletText(triplet) {
        if (!triplet)
            return "-"
        return qsTr("%1 / %2 / %3 A")
            .arg(triplet.l1 !== undefined ? triplet.l1 : "-")
            .arg(triplet.l2 !== undefined ? triplet.l2 : "-")
            .arg(triplet.l3 !== undefined ? triplet.l3 : "-")
    }

    RowLayout {
        Layout.fillWidth: true
        Label { text: qsTr("Type"); Layout.fillWidth: true }
        Label {
            color: Style.accentColor
            text: root.isCharger ? qsTr("Charger") : qsTr("Fuse")
        }
    }

    RowLayout {
        Layout.fillWidth: true
        Label { text: qsTr("ID") }
        Label {
            Layout.fillWidth: true
            font: Style.smallFont
            elide: Text.ElideRight
            horizontalAlignment: Text.AlignRight
            text: root.node.id ? root.node.id : "-"
        }
    }

    ThinDivider { Layout.fillWidth: true }

    Label {
        text: qsTr("Status")
        font: Style.smallFont
        color: Style.accentColor
    }
    RowLayout {
        Layout.fillWidth: true
        Label { text: qsTr("Allocation"); Layout.fillWidth: true }
        Label { text: root.tripletText(root.nodeStatus ? root.nodeStatus.allocation : null) }
    }
    RowLayout {
        Layout.fillWidth: true
        Label { text: qsTr("Measured load"); Layout.fillWidth: true }
        Label { text: root.tripletText(root.nodeStatus ? root.nodeStatus.measuredLoad : null) }
    }
    RowLayout {
        Layout.fillWidth: true
        visible: !root.isCharger
        Label { text: qsTr("Sum of children"); Layout.fillWidth: true }
        Label { text: root.tripletText(root.nodeStatus ? root.nodeStatus.sumOfChildren : null) }
    }

    ThinDivider { Layout.fillWidth: true }

    Label { text: qsTr("Name") }
    NymeaTextField {
        id: nameField
        Layout.fillWidth: true
        placeholderText: qsTr("Name")
        text: root.node.displayName ? root.node.displayName : ""
    }

    // Fuse: a single fixed limit applied to all phases by default.
    Label {
        visible: !root.isCharger
        text: qsTr("Fixed limit")
    }
    RowLayout {
        Layout.fillWidth: true
        visible: !root.isCharger && !perPhaseCheckBox.checked

        Label { text: qsTr("Limit"); Layout.fillWidth: true }
        NymeaSpinBox {
            id: limitSingle
            from: 0; to: 630
            value: root.limitValue("l1", 32)
        }
        Label { text: qsTr("A") }
    }

    // Fuse: optional per-phase limits.
    CheckBox {
        id: perPhaseCheckBox
        Layout.fillWidth: true
        visible: !root.isCharger
        text: qsTr("Custom per-phase limits")
        checked: root.hasPerPhaseLimit
    }
    RowLayout {
        Layout.fillWidth: true
        Layout.leftMargin: Style.margins
        visible: !root.isCharger && perPhaseCheckBox.checked

        Label { text: qsTr("L1"); Layout.fillWidth: true }
        NymeaSpinBox {
            id: limitL1
            from: 0; to: 630
            value: root.limitValue("l1", 32)
        }
        Label { text: qsTr("A") }
    }
    RowLayout {
        Layout.fillWidth: true
        Layout.leftMargin: Style.margins
        visible: !root.isCharger && perPhaseCheckBox.checked

        Label { text: qsTr("L2"); Layout.fillWidth: true }
        NymeaSpinBox {
            id: limitL2
            from: 0; to: 630
            value: root.limitValue("l2", 32)
        }
        Label { text: qsTr("A") }
    }
    RowLayout {
        Layout.fillWidth: true
        Layout.leftMargin: Style.margins
        visible: !root.isCharger && perPhaseCheckBox.checked

        Label { text: qsTr("L3"); Layout.fillWidth: true }
        NymeaSpinBox {
            id: limitL3
            from: 0; to: 630
            value: root.limitValue("l3", 32)
        }
        Label { text: qsTr("A") }
    }

    // Fuse: optional meter assignment.
    CheckBox {
        id: assignMeterCheckBox
        Layout.fillWidth: true
        visible: !root.isCharger
        text: qsTr("Assign meter")
        checked: root.node.meterThingId !== undefined && root.node.meterThingId !== ""
    }
    ComboBox {
        id: meterCombo
        Layout.fillWidth: true
        visible: !root.isCharger && assignMeterCheckBox.checked
        textRole: "name"
        model: ThingsProxy {
            id: meterProxy
            engine: _engine
            shownInterfaces: ["energymeter"]
        }
        function selectCurrent() {
            var thing = meterProxy.getThing(root.node.meterThingId)
            if (thing)
                currentIndex = meterProxy.indexOf(thing)
        }
        Component.onCompleted: selectCurrent()
        Connections {
            target: meterProxy
            function onCountChanged() { meterCombo.selectCurrent() }
        }
    }

    // Charger: assigned charger thing.
    Label {
        visible: root.isCharger
        text: qsTr("EV charger")
    }
    ComboBox {
        id: chargerCombo
        Layout.fillWidth: true
        visible: root.isCharger
        textRole: "name"
        model: ThingsProxy {
            id: chargerProxy
            engine: _engine
            shownInterfaces: ["evcharger"]
        }
        function selectCurrent() {
            var thing = chargerProxy.getThing(root.node.thingId)
            if (thing)
                currentIndex = chargerProxy.indexOf(thing)
        }
        Component.onCompleted: selectCurrent()
        Connections {
            target: chargerProxy
            function onCountChanged() { chargerCombo.selectCurrent() }
        }
    }

    // Charger: phase mapping (charger phase -> grid phase).
    Label {
        visible: root.isCharger
        text: qsTr("Phase mapping")
    }
    GridLayout {
        Layout.fillWidth: true
        visible: root.isCharger
        columns: 2

        Label { text: qsTr("Charger L1") }
        ComboBox {
            id: mapL1
            Layout.fillWidth: true
            model: root.phaseOptions
            displayText: root.phaseLabel(currentValue)
            delegate: ItemDelegate {
                width: mapL1.width
                text: root.phaseLabel(modelData)
            }
            currentIndex: root.phaseOptions.indexOf(root.mappedPhase("chargerL1", "gridL1"))
        }

        Label { text: qsTr("Charger L2") }
        ComboBox {
            id: mapL2
            Layout.fillWidth: true
            model: root.phaseOptions
            displayText: root.phaseLabel(currentValue)
            delegate: ItemDelegate {
                width: mapL2.width
                text: root.phaseLabel(modelData)
            }
            currentIndex: root.phaseOptions.indexOf(root.mappedPhase("chargerL2", "gridL2"))
        }

        Label { text: qsTr("Charger L3") }
        ComboBox {
            id: mapL3
            Layout.fillWidth: true
            model: root.phaseOptions
            displayText: root.phaseLabel(currentValue)
            delegate: ItemDelegate {
                width: mapL3.width
                text: root.phaseLabel(modelData)
            }
            currentIndex: root.phaseOptions.indexOf(root.mappedPhase("chargerL3", "gridL3"))
        }
    }

    ThinDivider { Layout.fillWidth: true }

    Button {
        Layout.fillWidth: true
        text: qsTr("Save")
        enabled: root.inputValid
        onClicked: {
            var patch = { "displayName": nameField.text.trim() }
            if (root.isCharger) {
                patch["thingId"] = root.selectedChargerId()
                patch["phaseMapping"] = {
                    "chargerL1": mapL1.currentValue,
                    "chargerL2": mapL2.currentValue,
                    "chargerL3": mapL3.currentValue
                }
            } else {
                if (perPhaseCheckBox.checked) {
                    patch["fixedLimit"] = {
                        "l1": parseInt(limitL1.value),
                        "l2": parseInt(limitL2.value),
                        "l3": parseInt(limitL3.value)
                    }
                } else {
                    var limit = parseInt(limitSingle.value)
                    patch["fixedLimit"] = { "l1": limit, "l2": limit, "l3": limit }
                }
                patch["meterThingId"] = assignMeterCheckBox.checked ? root.selectedMeterId() : ""
            }

            root.manager.updateNode(root.node.id, patch)
            pageStack.pop()
        }
    }
}

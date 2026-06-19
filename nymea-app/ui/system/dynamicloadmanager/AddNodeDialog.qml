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

NymeaDialog {
    id: root

    // The DynamicLoadManagerManager to issue the AddNode call on.
    property var manager: null
    // Parent fuse node id; empty string adds the root fuse.
    property string parentNodeId: ""
    // Chargers require a parent fuse, so the root node can only be a fuse.
    readonly property bool allowCharger: parentNodeId !== ""

    property string selectedType: "fuse"
    readonly property bool isCharger: selectedType === "charger"

    title: parentNodeId === "" ? qsTr("Add root fuse") : qsTr("Add node")
    headerIcon: "qrc:/icons/add.svg"
    standardButtons: Dialog.NoButton

    function selectedChargerId() {
        return chargerCombo.currentIndex >= 0 && chargerProxy.count > 0
                ? chargerProxy.get(chargerCombo.currentIndex).id : ""
    }

    readonly property bool inputValid: nameField.text.trim().length > 0
                                       && (!isCharger || selectedChargerId() !== "")

    RowLayout {
        Layout.fillWidth: true
        visible: root.allowCharger

        Label { text: qsTr("Type"); Layout.fillWidth: true }
        RadioButton {
            text: qsTr("Fuse")
            checked: root.selectedType === "fuse"
            onClicked: root.selectedType = "fuse"
        }
        RadioButton {
            text: qsTr("Charger")
            checked: root.selectedType === "charger"
            onClicked: root.selectedType = "charger"
        }
    }

    NymeaTextField {
        id: nameField
        Layout.fillWidth: true
        placeholderText: qsTr("Name")
    }

    RowLayout {
        Layout.fillWidth: true
        visible: !root.isCharger

        Label { text: qsTr("Fuse limit"); Layout.fillWidth: true }
        NymeaSpinBox {
            id: limitSpinBox
            from: 6
            to: 250
            value: 32
        }
        Label { text: qsTr("A") }
    }

    CheckBox {
        id: assignMeterCheckBox
        Layout.fillWidth: true
        visible: !root.isCharger
        text: qsTr("Assign meter")
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
    }

    ColumnLayout {
        Layout.fillWidth: true
        visible: root.isCharger

        Label { text: qsTr("EV charger") }
        ComboBox {
            id: chargerCombo
            Layout.fillWidth: true
            textRole: "name"
            model: ThingsProxy {
                id: chargerProxy
                engine: _engine
                shownInterfaces: ["evcharger"]
            }
        }
        Label {
            Layout.fillWidth: true
            visible: chargerProxy.count === 0
            wrapMode: Text.WordWrap
            color: Style.red
            font: Style.smallFont
            text: qsTr("No EV chargers are set up. Add a charger thing first.")
        }
    }

    Button {
        Layout.fillWidth: true
        text: qsTr("Add")
        enabled: root.inputValid
        onClicked: {
            var node = {
                "displayName": nameField.text.trim()
            }
            if (root.isCharger) {
                node["type"] = "charger"
                node["thingId"] = root.selectedChargerId()
                node["phaseMapping"] = {
                    "chargerL1": "gridL1",
                    "chargerL2": "gridL2",
                    "chargerL3": "gridL3"
                }
            } else {
                var limit = parseInt(limitSpinBox.value)
                node["type"] = "fuse"
                node["fixedLimit"] = { "l1": limit, "l2": limit, "l3": limit }
                node["children"] = []
                if (assignMeterCheckBox.checked && meterCombo.currentIndex >= 0 && meterProxy.count > 0)
                    node["meterThingId"] = meterProxy.get(meterCombo.currentIndex).id
            }

            root.manager.addNode(node, root.parentNodeId)
            root.close()
        }
    }

    Button {
        Layout.fillWidth: true
        flat: true
        text: qsTr("Cancel")
        onClicked: root.close()
    }
}

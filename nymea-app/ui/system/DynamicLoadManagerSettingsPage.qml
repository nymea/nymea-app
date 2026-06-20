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
import NymeaApp.Utils

import Nymea.DynamicLoadManager

import "qrc:/ui/components"

SettingsPageBase {
    id: root

    readonly property var configuration: dynamicLoadManager.configuration
    readonly property var rootFuse: configuration && configuration.root ? configuration.root : null

    function errorText(error) {
        switch (error) {
        case DynamicLoadManagerManager.DynamicLoadManagerErrorRevisionConflict:
            return qsTr("The configuration was changed by someone else in the meantime. Please reload and try again.")
        case DynamicLoadManagerManager.DynamicLoadManagerErrorInvalidParameter:
            return qsTr("The request contained an invalid parameter.")
        case DynamicLoadManagerManager.DynamicLoadManagerErrorValidationFailed:
            return qsTr("The configuration could not be validated.")
        case DynamicLoadManagerManager.DynamicLoadManagerErrorPersistenceFailed:
            return qsTr("The configuration could not be saved.")
        case DynamicLoadManagerManager.DynamicLoadManagerErrorNodeNotFound:
            return qsTr("The referenced node could not be found.")
        case DynamicLoadManagerManager.DynamicLoadManagerErrorInvalidOperation:
            return qsTr("The requested operation is not valid in the current state.")
        case DynamicLoadManagerManager.DynamicLoadManagerErrorNotImplemented:
            return qsTr("The requested operation is not implemented.")
        default:
            return qsTr("An unexpected error happened. (Error code: %1)").arg(error)
        }
    }

    function showError(error, issues) {
        if (error === DynamicLoadManagerManager.DynamicLoadManagerErrorNoError)
            return

        var text = root.errorText(error)
        if (issues && issues.length > 0) {
            var lines = []
            for (var i = 0; i < issues.length; i++) {
                var issue = issues[i]
                lines.push(issue.message !== undefined ? issue.message : JSON.stringify(issue))
            }
            text += "\n\n" + lines.join("\n")
        }

        var popup = errorDialog.createObject(app, {text: text})
        popup.open()
    }

    function limitText(limit) {
        if (!limit)
            return "-"
        return qsTr("L1 %1 A / L2 %2 A / L3 %3 A")
            .arg(limit.l1 !== undefined ? limit.l1 : "-")
            .arg(limit.l2 !== undefined ? limit.l2 : "-")
            .arg(limit.l3 !== undefined ? limit.l3 : "-")
    }

    function phaseTriplet(l1, l2, l3) {
        return qsTr("%1/%2/%3 A").arg(l1).arg(l2).arg(l3)
    }

    function loadPowerText(l1, l2, l3) {
        var voltage = root.configuration && root.configuration.nominalVoltage !== undefined ? root.configuration.nominalVoltage : 230
        return qsTr("%1 kW").arg(((l1 + l2 + l3) * voltage / 1000).toFixed(1))
    }

    header: NymeaHeader {
        text: qsTr("Dynamic load management")
        onBackPressed: pageStack.pop()
    }

    DynamicLoadManagerManager {
        id: dynamicLoadManager
        engine: _engine
    }

    Component {
        id: errorDialog
        ErrorDialog { }
    }

    Connections {
        target: dynamicLoadManager
        function onSetEnabledReply(commandId, error, issues) { root.showError(error, issues) }
        function onSetConfigurationReply(commandId, error, issues) { root.showError(error, issues) }
        function onAddNodeReply(commandId, error, issues) { root.showError(error, issues) }
        function onUpdateNodeReply(commandId, error, issues) { root.showError(error, issues) }
        function onMoveNodeReply(commandId, error, issues) { root.showError(error, issues) }
        function onRemoveNodeReply(commandId, error, issues) { root.showError(error, issues) }
        function onSetFuseLimitOverrideReply(commandId, error, issues) { root.showError(error, issues) }
        function onClearFuseLimitOverrideReply(commandId, error, issues) { root.showError(error, issues) }
        function onResetFaultsReply(commandId, error, issues) { root.showError(error, issues) }
        function onTriggerRecalculationReply(commandId, error, issues) { root.showError(error, issues) }
    }

    SwitchDelegate {
        text: qsTr("Dynamic load management enabled")
        checked: dynamicLoadManager.enabled
        onCheckedChanged: dynamicLoadManager.enabled = checked
        Layout.fillWidth: true
    }

    SettingsPageSectionHeader {
        text: qsTr("Configuration")
    }

    NymeaItemDelegate {
        Layout.fillWidth: true
        text: qsTr("Nominal voltage")
        subText: root.configuration && root.configuration.nominalVoltage !== undefined
                 ? qsTr("%1 V").arg(root.configuration.nominalVoltage) : "-"
        progressive: false
    }

    NymeaItemDelegate {
        Layout.fillWidth: true
        text: qsTr("Control interval")
        subText: root.configuration && root.configuration.intervalMs !== undefined
                 ? qsTr("%1 ms").arg(root.configuration.intervalMs) : "-"
        progressive: false
    }

    NymeaItemDelegate {
        Layout.fillWidth: true
        text: qsTr("Root fuse limit")
        subText: root.rootFuse ? root.limitText(root.rootFuse.fixedLimit) : "-"
        progressive: false
    }

    NymeaItemDelegate {
        Layout.fillWidth: true
        iconName: "qrc:/icons/energy.svg"
        text: qsTr("Edit topology")
        subText: qsTr("Add and remove fuses and chargers")
        onClicked: pageStack.push(Qt.resolvedUrl("dynamicloadmanager/DynamicLoadManagerTopologyPage.qml"))
    }

    SettingsPageSectionHeader {
        text: qsTr("Nodes")
    }

    Label {
        Layout.fillWidth: true
        Layout.margins: Style.margins
        wrapMode: Text.WordWrap
        visible: dynamicLoadManager.nodes.count === 0
        text: qsTr("No node status available.")
    }

    Repeater {
        model: dynamicLoadManager.nodes
        delegate: NymeaItemDelegate {
            Layout.fillWidth: true
            text: model.displayName
            subText: qsTr("Alloc %1 · Load %2")
                     .arg(root.phaseTriplet(model.allocationL1, model.allocationL2, model.allocationL3))
                     .arg(root.loadPowerText(model.measuredLoadL1, model.measuredLoadL2, model.measuredLoadL3))
            progressive: false
            iconName: model.faulted ? "qrc:/icons/dialog-warning-symbolic.svg" : "qrc:/icons/energy.svg"
            additionalItem: Label {
                anchors.verticalCenter: parent.verticalCenter
                visible: model.faulted
                color: "red"
                text: qsTr("Fault")
            }
        }
    }

    SettingsPageSectionHeader {
        text: qsTr("Actions")
    }

    Button {
        Layout.fillWidth: true
        Layout.margins: Style.margins
        text: qsTr("Trigger recalculation")
        onClicked: dynamicLoadManager.triggerRecalculation()
    }
}

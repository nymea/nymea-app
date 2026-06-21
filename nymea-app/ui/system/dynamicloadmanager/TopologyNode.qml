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

// Topology node rendered as a BigTile: the node name and status icons live in
// the header, the live load (with a progress bar per phase) in the body.
BigTile {
    id: root

    property string nodeType: "fuse"
    property string displayName: ""
    property real limit: -1
    property real nominalVoltage: 230
    property string nodeId: ""
    // Id of the assigned charger thing (charger nodes only).
    property string thingId: ""
    // Id of the assigned meter thing, if the node is measured directly.
    property string meterThingId: ""
    // The node's resolved load { l1, l2, l3 } in Amps, or null when unknown.
    property var measuredLoad: null

    // Optional status flags surfaced as header icons.
    property bool warning: false

    readonly property bool isCharger: nodeType === "charger"

    // True when the node has an actual measured current power: a wallbox that
    // reports currentPower, or a fuse with a meter assigned. Otherwise the values
    // are summed up from children (where unmeasured loads would be invisible).
    readonly property bool metered: isCharger ? currentPowerState !== null : meterThingId !== ""

    // Resolved charger thing and the states we render for wallbox nodes.
    readonly property Thing chargerThing: isCharger && thingId !== "" && !engine.thingManager.fetchingData
        ? engine.thingManager.things.getThing(thingId) : null
    readonly property State maxChargingCurrentState: chargerThing ? chargerThing.stateByName("maxChargingCurrent") : null
    readonly property StateType maxChargingCurrentStateType: chargerThing ? chargerThing.thingClass.stateTypes.findByName("maxChargingCurrent") : null
    readonly property State currentPowerState: chargerThing ? chargerThing.stateByName("currentPower") : null
    readonly property State connectedState: chargerThing ? chargerThing.stateByName("connected") : null
    readonly property bool disconnected: connectedState !== null && connectedState.value === false

    // Error state makes the tile glow red (e.g. a disconnected charger).
    error: root.disconnected

    // Charger setpoint ("amper position") and its range maximum.
    readonly property real chargingCurrent: maxChargingCurrentState ? maxChargingCurrentState.value : 0
    readonly property real chargingCurrentMax: maxChargingCurrentStateType && maxChargingCurrentStateType.maxValue !== undefined
        ? maxChargingCurrentStateType.maxValue : phaseMax

    readonly property bool hasMeasured: measuredLoad !== null && measuredLoad !== undefined
    readonly property real measuredMax: hasMeasured
        ? Math.max(measuredLoad.l1 || 0, measuredLoad.l2 || 0, measuredLoad.l3 || 0) : 0
    readonly property real measuredPowerKw: hasMeasured
        ? ((measuredLoad.l1 || 0) + (measuredLoad.l2 || 0) + (measuredLoad.l3 || 0)) * nominalVoltage / 1000 : 0
    // Per-phase load in Amps, used both for the summary and the progress bars.
    readonly property var phaseLoads: hasMeasured
        ? [ measuredLoad.l1 || 0, measuredLoad.l2 || 0, measuredLoad.l3 || 0 ] : [0, 0, 0]
    readonly property real phaseMax: limit >= 0 ? limit : Math.max(measuredMax, 1)
    // Full-scale value for the per-phase bars: the charger's max charging current
    // for wallboxes, the fuse limit otherwise.
    readonly property real barMax: isCharger ? chargingCurrentMax : phaseMax

    header: RowLayout {
        width: parent.width
        spacing: Style.smallMargins

        ColorIcon {
            Layout.preferredHeight: Style.smallIconSize
            Layout.preferredWidth: Style.smallIconSize
            name: root.isCharger ? "qrc:/icons/ev-charger.svg" : "qrc:/icons/energy.svg"
            color: root.isCharger ? Style.accentColor : Style.iconColor
        }

        Label {
            Layout.fillWidth: true
            text: root.displayName
            elide: Text.ElideRight
            font: Style.smallFont
        }

        // Meter icon: shown only when the node has an actual measured current
        // power (summed-up nodes, where unmeasured loads may be missing, omit it).
        ColorIcon {
            Layout.preferredHeight: Style.smallIconSize
            Layout.preferredWidth: Style.smallIconSize
            visible: root.metered
            name: "qrc:/icons/smartmeter.svg"
            color: Style.accentColor
        }

        ColorIcon {
            Layout.preferredHeight: Style.smallIconSize
            Layout.preferredWidth: Style.smallIconSize
            visible: root.warning
            name: "qrc:/icons/dialog-warning-symbolic.svg"
            color: Style.orange
        }

        ColorIcon {
            Layout.preferredHeight: Style.smallIconSize
            Layout.preferredWidth: Style.smallIconSize
            visible: root.disconnected
            name: "qrc:/icons/connections/network-wired-offline.svg"
            color: Style.red
        }
    }

    contentItem: ColumnLayout {
        spacing: Style.smallMargins / 2

        RowLayout {
            Layout.fillWidth: true

            Label {
                Layout.fillWidth: true
                font: Style.smallFont
                text: root.isCharger
                      ? (root.maxChargingCurrentState
                         ? qsTr("%1 / %2 A").arg(root.chargingCurrent.toFixed(1)).arg(root.chargingCurrentMax.toFixed(0))
                         : (root.hasMeasured ? qsTr("%1 A").arg(root.measuredMax.toFixed(1)) : "—"))
                      : (root.limit >= 0
                         ? (root.hasMeasured
                            ? qsTr("%1 / %2 A").arg(root.measuredMax.toFixed(1)).arg(root.limit)
                            : qsTr("%1 A").arg(root.limit))
                         : "—")
            }

            Label {
                visible: root.hasMeasured
                font: Style.extraSmallFont
                color: Style.tileForegroundColor
                opacity: 0.6
                text: qsTr("%1 kW").arg(root.measuredPowerKw.toFixed(1))
            }
        }

        // One bar per phase from the measured load. For chargers this shows
        // whether it is 1- or 3-phase charging and how close each phase is to the
        // max charging current; for fuses it is the load against the fuse limit.
        Repeater {
            model: 3

            RowLayout {
                Layout.fillWidth: true
                spacing: Style.smallMargins
                visible: root.hasMeasured

                Label {
                    Layout.preferredWidth: implicitWidth
                    font: Style.extraSmallFont
                    text: qsTr("L%1").arg(index + 1)
                }

                ProgressBar {
                    Layout.fillWidth: true
                    from: 0
                    to: root.barMax
                    value: root.phaseLoads[index]
                }

                Label {
                    Layout.preferredWidth: implicitWidth
                    horizontalAlignment: Text.AlignRight
                    font: Style.extraSmallFont
                    text: qsTr("%1 A").arg(root.phaseLoads[index].toFixed(1))
                }
            }
        }
    }
}

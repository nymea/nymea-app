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

import "../components"
import "../utils"

ThingPageBase {
    id: root

    readonly property State powerState: thing.stateByName("power")
    readonly property State maxChargingCurrentState: thing.stateByName("maxChargingCurrent")
    readonly property StateType maxChargingCurrentStateType: thing.thingClass.stateTypes.findByName("maxChargingCurrent")
    readonly property State currentPowerState: thing.stateByName("currentPower")
    readonly property State pluggedInState: thing.stateByName("pluggedIn")

    ActionQueue {
        id: actionQueue
        thing: root.thing
        stateName: "power"
    }

    GridLayout {
        anchors.fill: parent
        columns: app.landscape ? 2 : 1

        CircleBackground {
            id: background
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.leftMargin: Style.hugeMargins
            Layout.rightMargin: Style.hugeMargins
            Layout.topMargin: Style.hugeMargins
    //        iconSource: "ev-charger"
            onColor: app.interfaceToColor("evcharger")
    //        on: (actionQueue.pendingValue || powerState.value) === true
            onClicked: {
                PlatformHelper.vibrate(PlatformHelper.HapticsFeedbackSelection)
                actionQueue.sendValue(!root.powerState.value)
            }

            Column {
                anchors.centerIn: parent
                width: background.contentItem.width * .6
                spacing: Style.margins

                Label {
                    font: Style.largeFont
                    text: "%1 %2".arg(root.maxChargingCurrentState.value.toFixed(1)).arg(Types.toUiUnit(root.maxChargingCurrentStateType.unit))
                    width: parent.width
                    horizontalAlignment: Text.AlignHCenter
                }

                Label {
                    text: qsTr("Maximum charging current")
                    font: Style.smallFont
                    width: parent.width
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                }
            }

            StateDial {
                anchors.centerIn: parent
                height: background.contentItem.height
                width: background.contentItem.width
                visible: root.maxChargingCurrentState

                thing: root.thing
                stateName: "maxChargingCurrent"
                color: app.interfaceToColor("evcharger")
                on: (actionQueue.pendingValue || powerState.value) === true
            }
        }

        ColumnLayout {
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.margins: Style.hugeMargins
            spacing: Style.bigMargins
            Label {
                Layout.fillWidth: true
                property double currentPower: root.currentPowerState.value / (root.currentPowerState.value > 1000 ? 1000 : 1)
                property string unit: root.currentPowerState.value > 1000 ? "kW" : "W"
                font: Style.smallFont
                text: root.pluggedInState.value === false
                      ? qsTr("The car is not plugged in.")
                      : root.powerState.value === true
                        ?  qsTr("Currently charging at %1.").arg('<span style="font-size:' + Style.bigFont.pixelSize + 'px">' + (currentPower.toFixed(1)) + '</span>' + ' ' + unit)
                        : ""

                textFormat: Text.RichText
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
            }

            ProgressButton {
                Layout.alignment: Qt.AlignCenter
                imageSource: "system-shutdown"
                mode: "normal"
                size: Style.bigIconSize
                busy: root.currentPowerState.value > 0
                color: (actionQueue.pendingValue || powerState.value) === true ? app.interfaceToColor("evcharger") : Style.iconColor
                onClicked: {
                    PlatformHelper.vibrate(PlatformHelper.HapticsFeedbackSelection)
                    actionQueue.sendValue(!root.powerState.value)
                }
            }
        }

    }
}

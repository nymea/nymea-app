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

NymeaSwipeDelegate {
    id: root
    width: parent.width
    iconName: thing && thing.thingClass ? app.interfacesToIcon(thing.thingClass.interfaces) : ""
    text: thing ? thing.name : ""
    progressive: true
    secondaryIconName: thing.setupStatus == Thing.ThingSetupStatusComplete && batteryCritical ? "qrc:/icons/battery/battery-010.svg" : ""
    tertiaryIconName: {
        if (thing.setupStatus == Thing.ThingSetupStatusFailed) {
            return "qrc:/icons/dialog-warning-symbolic.svg";
        }
        if (thing.setupStatus == Thing.ThingSetupStatusInProgress) {
            return "qrc:/icons/settings.svg"
        }
        if (connectedState && connectedState.value === false) {
            if (!isWireless) {
                return "qrc:/icons/connections/network-wired-offline.svg"
            }
            return "qrc:/icons/connections/nm-signal-00.svg"
        }
        return ""
    }

    tertiaryIconColor: {
        if (thing.setupStatus == Thing.ThingSetupStatusFailed) {
            return Style.red
        }
        if (thing.setupStatus == Thing.ThingSetupStatusInProgress) {
            return Style.iconColor
        }
        if (connectedState && connectedState.value === false) {
            return Style.red
        }
        return Style.iconColor
    }

    property Thing thing: null
    property alias device: root.thing

    readonly property bool hasBatteryInterface: thing && thing.thingClass.interfaces.indexOf("battery") >= 0
    readonly property StateType batteryCriticalStateType: hasBatteryInterface ? thing.thingClass.stateTypes.findByName("batteryCritical") : null
    readonly property State batteryCriticalState: batteryCriticalStateType ? thing.states.getState(batteryCriticalStateType.id) : null
    readonly property bool batteryCritical: batteryCriticalState && batteryCriticalState.value === true

    readonly property bool hasConnectableInterface: thing && thing.thingClass.interfaces.indexOf("connectable") >= 0
    readonly property StateType connectedStateType: hasConnectableInterface ? thing.thingClass.stateTypes.findByName("connected") : null
    readonly property State connectedState: connectedStateType ? thing.states.getState(connectedStateType.id) : null
    readonly property bool disconnected: connectedState && connectedState.value === false ? true : false

    readonly property bool isWireless: root.thing.thingClass.interfaces.indexOf("wirelessconnectable") >= 0
    readonly property State signalStrengthState: root.thing.stateByName("signalStrength")
}

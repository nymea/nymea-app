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
import Nymea
import NymeaApp.Utils

ColorIcon {
    id: root

    property Thing thing: null

    readonly property bool isConnected: connectedState === null || connectedState.value === true
    readonly property bool isWireless: thing.thingClass.interfaces.indexOf("wirelessconnectable") >= 0
    readonly property bool hasSignalStrength: signalStrengthState !== null

    readonly property State connectedState: thing.stateByName("connected")
    readonly property State signalStrengthState: thing.stateByName("signalStrength")

    name: {
        if (!isWireless) {
            return connectedState && connectedState.value === true ? "qrc:/icons/connections/network-wired.svg" : "qrc:/icons/connections/network-wired-offline.svg"
        }
        if (connectedState && connectedState.value === false) {
            return "qrc:/icons/connections/nm-signal-00.svg"
        }

        if (!signalStrengthState) {
            return "qrc:/icons/connections/nm-signal-100.svg"
        }

        return "qrc:/icons/connections/nm-signal-" + NymeaUtils.pad(Math.round(signalStrengthState.value * 4 / 100) * 25, 2) + ".svg"
    }

    color: connectedState && connectedState.value === false
           ? Style.red
           : signalStrengthState && signalStrengthState.value < 20
             ? Style.orange : Style.iconColor
}

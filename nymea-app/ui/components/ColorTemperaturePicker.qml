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
import Qt5Compat.GraphicalEffects
import Nymea

import "../utils"

Item {
    id: root
    implicitWidth: orientation == Qt.Horizontal ? 300 : Style.hugeIconSize
    implicitHeight: orientation == Qt.Horizontal ? Style.hugeIconSize : 300

    property Thing thing: null

    property int orientation: Qt.Vertical

    readonly property StateType colorTemperatureStateType: root.thing.thingClass.stateTypes.findByName("colorTemperature")
    readonly property State powerState: root.thing.stateByName("power")

    property int value: thing.stateByName("colorTemperature").value

    ActionQueue {
        id: actionQueue
        thing: root.thing
        stateType: root.colorTemperatureStateType
    }

    Rectangle {
        id: background
        width: Math.min(400, Math.min(parent.width, parent.height))
        anchors.centerIn: parent
        height: width
        radius: width / 2
        visible: false
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#dfffff" }
            GradientStop { position: 0.5; color: "#ffffea" }
            GradientStop { position: 1.0; color: "#ffd649" }
        }

        Rectangle {
            id: dragHandle
            property double valuePercentage: ((actionQueue.pendingValue || root.value) - root.colorTemperatureStateType.minValue) / (root.colorTemperatureStateType.maxValue - root.colorTemperatureStateType.minValue)
            width: 20
            height: 20
            radius: height / 2
            color: Style.backgroundColor
            border.color: Style.foregroundColor
            border.width: 2
            x: (background.width - width) / 2
            y: (background.height - height) * valuePercentage
        }
    }

    Desaturate {
        anchors.fill: background
        source: background
        desaturation: root.powerState.value === true ? 0 : 1
        Behavior on desaturation { NumberAnimation { duration: Style.animationDuration } }
    }


    MouseArea {
        anchors.fill: background
        onPositionChanged: {
            var minCt = root.colorTemperatureStateType.minValue;
            var maxCt = root.colorTemperatureStateType.maxValue
            var ct;
//            if (root.orientation == Qt.Horizontal) {
//                ct = Math.min(maxCt, Math.max(minCt, (mouseX * (maxCt - minCt) / (width - dragHandle.width)) + minCt))
//            } else {
            // ct : y = max : height
            ct = mouseY * (maxCt - minCt) / (height) + minCt
            ct = Math.min(maxCt, ct)
            ct = Math.max(minCt, ct)
//                ct = Math.min(maxCt, Math.max(minCt, ((height - mouseY) * (maxCt - minCt) / (height - dragHandle.height)) + minCt))
//            }
            actionQueue.sendValue(ct);
        }
    }
}


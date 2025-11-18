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

import QtQuick 2.5
import QtQuick.Controls 2.2
import Nymea 1.0
import QtQuick.Layouts 1.2
import "../utils"

Item {
    id: root

    property Thing thing: null
    property string stateName: ""
    property StateType stateType: thing ? thing.thingClass.stateTypes.findByName(stateName) : null

    property color color: Style.accentColor
    property bool on: true
    property int precision: 1

    readonly property State progressState: thing ? thing.states.getState(stateType.id) : null
    readonly property State powerState: thing ? thing.stateByName("power") : null

    property int startAngle: 135
    property int maxAngle: 270
    readonly property int steps: canvas.roundToPrecision(root.progressState.maxValue - root.progressState.minValue) / root.precision + 1
    readonly property double stepSize: (root.progressState.maxValue - root.progressState.minValue) / steps
    readonly property double anglePerStep: maxAngle / steps


    ActionQueue {
        id: actionQueue
        thing: root.thing
        stateType: root.stateType
        onPendingValueChanged: canvas.requestPaint()
    }

    ActionQueue {
        id: powerActionQueue
        thing: root.thing
        stateName: "power"
    }

    Connections {
        target: root.progressState
        onValueChanged: {
            canvas.requestPaint()
        }
    }


    Canvas {
        id: canvas
        anchors.centerIn: root
        width: Math.min(root.width, root.height)
        height: width

        property color effectColor: root.on ? root.color : Style.iconColor
        Behavior on effectColor { ColorAnimation { duration: Style.animationDuration } }
        onEffectColorChanged: requestPaint()

        function roundToPrecision(value) {
            var tmp = Math.round(value / root.precision) * root.precision;
            return tmp;
        }

        onPaint: {
            var ctx = getContext("2d");
            ctx.reset();

            var center = { x: canvas.width / 2, y: canvas.height / 2 };

            // Step lines
            var currentValue = actionQueue.pendingValue || root.progressState.value
            var currentStep;
            if (root.progressState) {
                currentStep = roundToPrecision(currentValue - root.progressState.minValue) / root.precision
            }

//            print("* current step", currentStep, root.steps, currentValue)

            for(var step = 0; step < steps; step += root.precision) {
                var angle = step * anglePerStep + startAngle;
                var innerRadius = canvas.width * 0.4
                var outerRadius = canvas.width * 0.5

                if (step <= currentStep) {
                    ctx.strokeStyle = canvas.effectColor
                    innerRadius = canvas.width * 0.38
                    ctx.lineWidth = 4;
                } else {
                    ctx.strokeStyle = Style.tileOverlayColor;
                    ctx.lineWidth = 1;
                }

                ctx.beginPath();
                // rotate
                //convert to radians
                var rad = angle * Math.PI/180;
                var c = Math.cos(rad);
                var s = Math.sin(rad);
                var innerPointX = center.x + (innerRadius * c);
                var innerPointY = center.y + (innerRadius * s);
                var outerPointX = center.x + (outerRadius * c);
                var outerPointY = center.x + (outerRadius * s);

                ctx.moveTo(innerPointX, innerPointY);
                ctx.lineTo(outerPointX, outerPointY);
                ctx.stroke();
                ctx.closePath();
            }
        }
    }


    MouseArea {
        anchors.fill: canvas

        property bool dragging: false
        property double lastAngle
        property double angleDiff: 0

        onPressed: {
            angleDiff = 0
            lastAngle = calculateAngle(mouseX, mouseY)
        }

        onReleased: {
            if (!dragging && root.powerState) {
                PlatformHelper.vibrate(PlatformHelper.HapticsFeedbackSelection)
                powerActionQueue.sendValue(!root.powerState.value)
            }
            dragging = false
        }

        onPositionChanged: {
            var angle = calculateAngle(mouseX, mouseY)
            var tmpDiff = angle - lastAngle
            if (tmpDiff > 300) {
                tmpDiff -= 360
            }
            if (tmpDiff < -300) {
                tmpDiff += 360
            }

            lastAngle = angle;

            angleDiff += tmpDiff
            if (Math.abs(angleDiff) > 1) {
                dragging = true
            }

            var valueDiff = angleDiff / root.anglePerStep * root.stepSize
            valueDiff = canvas.roundToPrecision(valueDiff)
            if (Math.abs(valueDiff) > 0) {
                var currentValue = actionQueue.pendingValue || root.progressState.value
                var newValue = currentValue + valueDiff
                newValue = Math.min(root.progressState.maxValue, Math.max(root.progressState.minValue, newValue))
                print("newValue", newValue)
                if (currentValue !== newValue) {
                    actionQueue.sendValue(newValue)
                }
                var steps = Math.round(valueDiff / root.stepSize)
                angleDiff -= steps * root.anglePerStep
            }
        }

        function calculateAngle(mouseX, mouseY) {
            // transform coords to center of dial
            mouseX -= canvas.width / 2
            mouseY -= canvas.height / 2

            var rad = Math.atan(mouseY / mouseX);
            var angle = rad * 180 / Math.PI

            angle += 90;

            if (mouseX < 0 && mouseY >= 0) angle = 180 + angle;
            if (mouseX < 0 && mouseY < 0) angle = 180 + angle;

            return angle;
        }
    }
}

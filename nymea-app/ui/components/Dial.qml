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

import "../utils"

Item {
    id: root

    property double minValue: 0
    property double maxValue: 100
    property double precision: 1
    property double value: 50
    property double activeValue: minValue
    readonly property alias pendingValue: d.pendingValue

    property color color: Style.accentColor
    property bool on: true

    property int startAngle: 135
    property int maxAngle: 270
    readonly property int steps: canvas.roundToPrecision(maxValue - minValue) / root.precision + 1
    readonly property double stepSize: (maxValue - minValue) / (steps - 1)
    readonly property double anglePerStep: maxAngle / (steps - 1)

    signal pressed()
    signal released()
    signal clicked()
    signal moved(double value)

    QtObject {
        id: d
        property double pendingValue: root.value
        onPendingValueChanged: canvas.requestPaint()

        property bool pending: false
    }
    onValueChanged: {
        if (d.pending && value == d.pendingValue) {
            d.pending = false
        }
    }

    Binding {
        target: d
        property: "pendingValue"
        value: root.value
        when: !d.pending
    }

    Canvas {
        id: canvas
        anchors.centerIn: root        
        width: Math.min(400, Math.min(root.width, root.height))
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
            var currentValue = d.pendingValue
            var currentStep = roundToPrecision(currentValue - minValue) / root.precision
            var activeStep = roundToPrecision(root.activeValue - minValue) / root.precision

            for(var step = 0; step < steps; step += root.precision) {
                var angle = step * anglePerStep + startAngle;
                var innerRadius = canvas.width * 0.4
                var outerRadius = canvas.width * 0.5

                if (step == currentStep) {
                    ctx.strokeStyle = canvas.effectColor
                    innerRadius = canvas.width * 0.38
                    ctx.lineWidth = 4;
                } else if (step < currentStep && step >= activeStep) {
                    ctx.strokeStyle = canvas.effectColor
                    ctx.lineWidth = 2;
                } else if (step > currentStep && step <= activeStep) {
                    ctx.strokeStyle = canvas.effectColor
                    ctx.lineWidth = 2;
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
        preventStealing: dragging

        property bool dragging: false
        property double lastAngle
        property double angleDiff: 0

        onPressed: {
            angleDiff = 0
            lastAngle = calculateAngle(mouseX, mouseY)
            root.pressed()
        }

        onReleased: {
            root.released()
            if (!dragging) {
                PlatformHelper.vibrate(PlatformHelper.HapticsFeedbackSelection)
                root.clicked()
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
                var currentValue = d.pendingValue
                var newValue = currentValue + valueDiff
                newValue = Math.min(root.maxValue, Math.max(root.minValue, newValue))
                if (currentValue !== newValue) {
                    d.pendingValue = newValue;
                    d.pending = true;
                    root.moved(newValue)
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

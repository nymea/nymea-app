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
import QtQuick.Shapes
import Nymea

Item {
    id: root

    property bool routeVisible: false
    property bool flowVisible: false
    property bool animationsEnabled: false
    property bool reverse: false
    property point startPoint: Qt.point(0, 0)
    property point endPoint: Qt.point(0, 0)
    property color flowColor: Style.accentColor
    property color backgroundColor: Qt.rgba(flowColor.r, flowColor.g, flowColor.b, 0.12)
    property int colorAnimationDuration: Style.animationDuration
    property real lineWidth: 2
    property real backgroundLineWidth: 6
    property bool roundedDashCaps: true
    property real dashMargin: 1
    // Curve strength relative to the available item width.
    // Positive values bend to one side of the path, negative values to the other.
    property real bendRatio: 0
    property int dashLength: 2
    property int dashGap: 1
    property int animationDuration: 1200
    property int directionChangePauseDuration: 120
    property real dashOffset: 0

    readonly property real dashPeriod: Math.max(1, dashLength + dashGap)
    readonly property real dashPixelsPerSecond: dashPeriod / Math.max(1, animationDuration) * 1000
    readonly property bool effectiveFlowVisible: flowVisible && !d.directionChangePaused
    readonly property point effectiveStartPoint: d.displayedReverse ? endPoint : startPoint
    readonly property point effectiveEndPoint: d.displayedReverse ? startPoint : endPoint
    readonly property real effectiveBendRatio: d.displayedReverse ? -bendRatio : bendRatio
    readonly property real dx: effectiveEndPoint.x - effectiveStartPoint.x
    readonly property real dy: effectiveEndPoint.y - effectiveStartPoint.y
    readonly property real length: Math.max(1, Math.sqrt(dx * dx + dy * dy))
    readonly property real normalX: -dy / length
    readonly property real normalY: dx / length
    readonly property real bend: width * effectiveBendRatio
    readonly property real controlX: (effectiveStartPoint.x + effectiveEndPoint.x) / 2 + normalX * bend
    readonly property real controlY: (effectiveStartPoint.y + effectiveEndPoint.y) / 2 + normalY * bend

    visible: routeVisible || effectiveFlowVisible
    opacity: 0.9

    Behavior on flowColor {
        ColorAnimation {
            duration: root.colorAnimationDuration
        }
    }

    Behavior on backgroundColor {
        ColorAnimation {
            duration: root.colorAnimationDuration
        }
    }

    QtObject {
        id: d
        property bool displayedReverse: root.reverse
        property bool directionChangePaused: false
        property bool hadVisibleFlow: root.flowVisible
        property double lastAnimationTimestamp: 0
    }

    onReverseChanged: {
        if (animationsEnabled && (flowVisible || d.hadVisibleFlow)) {
            d.directionChangePaused = true
            directionChangeTimer.restart()
        } else {
            d.displayedReverse = reverse
        }
    }

    onFlowVisibleChanged: {
        d.hadVisibleFlow = flowVisible
    }

    Timer {
        id: directionChangeTimer
        interval: root.directionChangePauseDuration
        repeat: false
        onTriggered: {
            d.displayedReverse = root.reverse
            root.dashOffset = 0
            d.directionChangePaused = false
            d.lastAnimationTimestamp = 0
        }
    }

    Timer {
        id: dashTimer
        interval: 16
        repeat: true
        running: root.effectiveFlowVisible && root.animationsEnabled

        onRunningChanged: {
            d.lastAnimationTimestamp = 0
        }

        onTriggered: {
            var now = Date.now()
            if (d.lastAnimationTimestamp === 0) {
                d.lastAnimationTimestamp = now
                return
            }

            var elapsed = now - d.lastAnimationTimestamp
            d.lastAnimationTimestamp = now
            root.dashOffset = (root.dashOffset + elapsed * root.dashPixelsPerSecond / 1000) % root.dashPeriod
        }
    }

    Shape {
        anchors.fill: parent
        visible: root.routeVisible

        ShapePath {
            fillColor: "transparent"
            strokeColor: root.backgroundColor
            strokeWidth: root.backgroundLineWidth
            capStyle: ShapePath.FlatCap
            joinStyle: ShapePath.RoundJoin
            startX: root.effectiveStartPoint.x
            startY: root.effectiveStartPoint.y

            PathCubic {
                control1X: root.controlX
                control1Y: root.controlY
                control2X: root.controlX
                control2Y: root.controlY
                x: root.effectiveEndPoint.x
                y: root.effectiveEndPoint.y
            }
        }
    }

    Shape {
        anchors.fill: parent
        visible: root.effectiveFlowVisible

        ShapePath {
            readonly property real effectiveStrokeWidth: Math.max(1, root.lineWidth - root.dashMargin * 2)

            fillColor: "transparent"
            strokeColor: root.flowColor
            strokeWidth: effectiveStrokeWidth
            strokeStyle: ShapePath.DashLine
            capStyle: root.roundedDashCaps ? ShapePath.RoundCap : ShapePath.FlatCap
            joinStyle: ShapePath.RoundJoin
            // Qt Shapes define dash lengths as multiples of the stroke width.
            dashPattern: [
                root.dashLength / effectiveStrokeWidth,
                root.dashGap / effectiveStrokeWidth
            ]
            dashOffset: -root.dashOffset / effectiveStrokeWidth
            startX: root.effectiveStartPoint.x
            startY: root.effectiveStartPoint.y

            PathCubic {
                control1X: root.controlX
                control1Y: root.controlY
                control2X: root.controlX
                control2Y: root.controlY
                x: root.effectiveEndPoint.x
                y: root.effectiveEndPoint.y
            }
        }
    }
}

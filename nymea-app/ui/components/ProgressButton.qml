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

import QtQuick 2.9
import QtQuick.Layouts 1.3
import Nymea 1.0

Item {
    id: root
    implicitHeight: size + Style.smallMargins * 2
    implicitWidth: size + Style.smallMargins * 2

    // FIXME: enums not available in < 5.10
    property string mode: "transparent" // "normal" "highlight" "destructive" "transparent"

    property string imageSource
    property string longpressImageSource: imageSource
    property bool repeat: false
    property alias color: icon.color
    property alias backgroundColor: background.color

    property bool longpressEnabled: false
    property bool busy: false

    property int size: Style.iconSize

    signal clicked();
    signal longpressed();

    MouseArea {
        id: buttonDelegate
        anchors.fill: parent
        hoverEnabled: true

        property bool longpressed: false

        onPressed: {
            canvas.inverted = false
            buttonDelegate.longpressed = false
        }
        onReleased: {
            if (!containsMouse) {
                buttonDelegate.longpressed = false;
                return;
            }

            if (buttonDelegate.longpressed) {
                if (!repeat) {
                    root.longpressed();
                }
            } else {
                root.clicked();
            }
            buttonDelegate.longpressed = false
        }
    }

    NumberAnimation {
        target: canvas
        properties: "progress"
        from: 0.0
        to: 1.0
        running: root.longpressEnabled && buttonDelegate.pressed
        duration: 750
        onRunningChanged: {
            if (!running && canvas.progress == 1) {
                buttonDelegate.longpressed = true;
                if (root.repeat) {
                    root.longpressed();
                    start();
                    canvas.inverted = !canvas.inverted
                }
            }
        }
    }

    NumberAnimation {
        target: busyCanvas
        property: "rotation"
        from: 360
        to: 0
        duration: 2000
        loops: Animation.Infinite
        running: root.busy
    }

    Rectangle {
        id: background
        anchors.fill: parent
        radius: width / 2
        color: {
            switch (root.mode) {
            case "highlight":
                return Style.accentColor;
            case "destructive":
                return Style.red;
            case "normal":
                return Style.tileOverlayColor;
            default:
                return "transparent"
            }
        }

        Rectangle {
            anchors.fill: parent
            radius: width / 2
            color: Style.foregroundColor
            opacity: buttonDelegate.pressed || buttonDelegate.containsMouse ? .08 : 0
            Behavior on opacity {
                NumberAnimation { duration: 200 }
            }
        }
    }

    Canvas {
        id: canvas
        anchors.fill: parent

        property real progress: 0
        property bool inverted: false

        readonly property int penWidth: 2

        onProgressChanged: requestPaint()
        Connections {
            target: buttonDelegate
            onPressedChanged: {
                if (!buttonDelegate.pressed) {
                    canvas.progress = 0;
                    canvas.requestPaint()
                }
            }
        }

        onPaint: {
            var ctx = getContext("2d");
            ctx.clearRect(0, 0, canvas.width, canvas.height);

            // Draw longpress progress
            if (canvas.progress > 0) {
                ctx.save();
                ctx.fillStyle = Qt.rgba(1, 0, 0, 1);
                ctx.lineWidth = canvas.penWidth
                ctx.strokeStyle = Style.accentColor

                var start = -Math.PI / 2;
                var stop = -Math.PI / 2;
                if (inverted) {
                    start += canvas.progress * 2 * Math.PI
                } else {
                    stop += canvas.progress * 2 * Math.PI
                }

                ctx.beginPath();
                ctx.arc(canvas.width / 2, canvas.height / 2, ((canvas.width - canvas.penWidth) / 2), start, stop);
                ctx.stroke();
                ctx.closePath();
                ctx.restore();
            }
        }
    }

    Canvas {
        id: busyCanvas
        visible: root.busy
        anchors.fill: parent
        anchors.margins: -4
        onPaint: {
            var ctx = getContext("2d");
            ctx.save();
            ctx.lineWidth = 2;
            ctx.strokeStyle = root.backgroundColor;
            var radius = (width - ctx.lineWidth) / 2
            var circumference = 2 * Math.PI * radius
            var dashRatio = circumference / 6 / ctx.lineWidth
            ctx.setLineDash([dashRatio, dashRatio])
            ctx.beginPath();
            ctx.arc(width / 2, height / 2, (width - 2) / 2, 0, 2 * Math.PI);
            ctx.stroke();
            ctx.closePath();
        }
    }

    ColorIcon {
        id: icon
        anchors.fill: parent
        anchors.margins: Style.smallMargins
        name: buttonDelegate.longpressed ? root.longpressImageSource : root.imageSource
        color: {
            switch (root.mode) {
            case "highlight":
                return Style.white;
            case "destructive":
                return Style.white;
            case "normal":
                return Style.iconColor;
            default:
                return Style.iconColor
            }
        }
    }
}


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
import Nymea 1.0

Item {
    id: root

    property color color: actionState
    property bool pressed: mouseArea.pressed
    property bool hovered: mouseArea.containsMouse

    property bool active: true

    property Component touchDelegate: Rectangle {
        height: 15
        width: height
        radius: height / 2
        color: Style.accentColor


        Rectangle {
            color: root.hovered || root.pressed ? "#11000000" : "transparent"
            anchors.centerIn: parent
            height: 30
            width: height
            radius: width / 2
            Behavior on color { ColorAnimation { duration: 200 } }
        }
    }

    function calculateXy(color) {
        if (!color.hasOwnProperty("r")) {
            // Qt 4.8's color doesn't have r,g,b properties
            var colorString = color.toString();
            color = new Object;
            color.r = 1.0 * parseInt("0x" + colorString.substring(1,3), 16) / 256;
            color.g = 1.0 * parseInt("0x" + colorString.substring(3,5), 16) / 256;
            color.b = 1.0 * parseInt("0x" + colorString.substring(5,7), 16) / 256;
        }

        var point = new Object;
        var brightness = Math.min(color.r, color.g, color.b);
        point.y = Math.round(root.height * brightness);
        var newColor = new Object;
        newColor.r = color.r - brightness;
        newColor.g = color.g - brightness;
        newColor.b = color.b - brightness;

        var sectionWidth = root.width / 6;

        var sections = [true, true, true];
        if (newColor.r > 0) {
            sections[1] = false;
        }
        if (newColor.g > 0) {
            sections[2] = false;
        }
        if (newColor.b > 0) {
            sections[0] = false;
        }
        if (sections[0]) {
            if (newColor.r > newColor.g) {
                point.x = sectionWidth * newColor.g;
            } else if (newColor.r == newColor.g) {
                point.x = sectionWidth
            } else {
                point.x = sectionWidth * 2 - newColor.r * sectionWidth;
            }
        } else if (sections[1]) {
            if (newColor.g > newColor.b) {
                point.x = sectionWidth * 2 + sectionWidth * newColor.b;
            } else if (newColor.g == newColor.b) {
                point.x = sectionWidth * 3;
            } else {
                point.x = sectionWidth * 4 - newColor.g * sectionWidth
            }
        } else {
            if (newColor.b > newColor.r) {
                point.x = sectionWidth * 4 + sectionWidth * newColor.r
            } else if (newColor.b == newColor.r) {
                point.x = sectionWidth * 5;
            } else {
                point.x = sectionWidth * 6 - newColor.b * sectionWidth;
            }
        }
        return point;
    }

    function calculateColor(x, y) {
        x = Math.min(Math.max(0, x), width - 1);
        y = Math.min(Math.max(0, y), height - 1);
        var color = root.color;
        var sectionWidth = root.width / 6;
        var section = Math.floor(x / sectionWidth)
        var sectionX = Math.floor(x % (sectionWidth - 0.00001)) // the - 0.00001 is to prevent a mismatch when rounding
        // sectionVal : 1.0 = sectionX : sectionWidth
        var sectionVal = (1.0 * sectionX / sectionWidth)

        // brightnessVal : 1.0 = mouseY : height
        var brightness = 1.0 * y / height

        switch (section) {
        case 0:
            // GradientStop { position: 0.0; color: "#ff0000" }
            color = Qt.rgba(1, sectionVal + brightness, brightness, 1)
            break;
        case 1:
            // GradientStop { position: 0.17; color: "#ffff00" }
            color = Qt.rgba(1 - sectionVal + brightness, 1, brightness, 1)
            break;
        case 2:
            // GradientStop { position: 0.33; color: "#00ff00" }
            color = Qt.rgba(brightness, 1, sectionVal + brightness, 1)
            break;
        case 3:
            // GradientStop { position: 0.5; color: "#00ffff" }
            color = Qt.rgba(brightness, 1 - sectionVal + brightness, 1, 1)
            break;
        case 4:
            // GradientStop { position: 0.66; color: "#0000ff" }
            color = Qt.rgba(sectionVal + brightness, brightness, 1, 1)
            break;
        case 5:
            // GradientStop { position: 0.83; color: "#ff00ff" }
            color = Qt.rgba(1, brightness, 1 - sectionVal + brightness, 1)
            break;
        }
        //        print("got color", color.r, color.g, color.b)
        return color
    }

    Rectangle {
        height: parent.width
        width: parent.height
        anchors.centerIn: parent
        rotation: -90

        gradient: Gradient {
            GradientStop { position: 0.0; color: "#ff0000" }
            GradientStop { position: 0.17; color: "#ffff00" }
            GradientStop { position: 0.33; color: "#00ff00" }
            GradientStop { position: 0.5; color: "#00ffff" }
            GradientStop { position: 0.66; color: "#0000ff" }
            GradientStop { position: 0.83; color: "#ff00ff" }
            GradientStop { position: 1.0; color: "#ff0000" }
        }
    }

    Rectangle {
        anchors.fill: parent
        border.color: Style.foregroundColor
        border.width: 1
        gradient: Gradient {
            GradientStop { position: 0.0; color: "transparent" }
            GradientStop { position: 1.0; color: "white" }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        preventStealing: true
        hoverEnabled: true

        drag.minimumX: 0
        drag.maximumX: width - dndItem.width
        drag.minimumY: 0
        drag.maximumY: height - dndItem.height

        property variant draggedItem
        property variant draggedLight

        onPressed: {
            mouseArea.drag.target = dndItem;
            dndItem.x = Math.min(width - dndItem.width, Math.max(0, mouseX - dndItem.width / 2))
            dndItem.y = Math.min(height - dndItem.height, Math.max(0, mouseY - dndItem.height / 2))
            mouseArea.draggedItem = touchDelegateLoader;
        }
        onPositionChanged: {
            if (mouseArea.draggedItem) {
                root.color = root.calculateColor(mouseX, mouseY);
                if (mouseArea.draggedLight) {
                    mouseArea.draggedLight.color = root.calculateColor(mouseX, mouseY);
                }
            }
        }

        onReleased: {
            if (mouseArea.draggedItem) {
                root.color = root.calculateColor(mouseX, mouseY);
                if (mouseArea.draggedLight) {
                    mouseArea.draggedLight.color = root.calculateColor(mouseX, mouseY);
                }
            }
            mouseArea.draggedItem = undefined;
            mouseArea.draggedLight = undefined;
            mouseArea.drag.target = undefined;

        }

    }

    Loader {
        id: touchDelegateLoader
        property variant point: calculateXy(root.color);
        x: item ? Math.max(0, Math.min(point.x - width * .5, parent.width - item.width)) : 0
        y: item ? Math.max(0, Math.min(point.y - height * .5, parent.height - item.height)) : 0
        sourceComponent: root.touchDelegate
        visible: mouseArea.draggedItem !== touchDelegateLoader && root.active
        //        Behavior on x {
        //            enabled: !mouseArea.pressed
        //            NumberAnimation {}
        //        }
    }

    Loader {
        id: dndItem
        sourceComponent: root.touchDelegate
        visible: mouseArea.draggedItem !== undefined && root.active
    }
}

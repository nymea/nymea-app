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

import QtQuick 2.8
import QtQuick.Controls 2.1

Item {
    id: root
    implicitHeight: slider.implicitHeight
    implicitWidth: slider.implicitWidth

    property alias orientation: slider.orientation

    property real value: 0
    property alias from: slider.from
    property alias to: slider.to
    property alias stepSize: slider.stepSize
    property alias snapMode: slider.snapMode

    readonly property real rawValue: slider.value

    signal moved(real value);

    Slider {
        id: slider
        anchors.left: parent.left; anchors.right: parent.right
        anchors.top: parent.top; anchors.bottom: parent.bottom
        from: 0
        to: 100
        property var lastSentTime: new Date()
        onValueChanged: {
            var currentTime = new Date();
            if (pressed && currentTime - lastSentTime > 200) {
                root.moved(slider.value)
                lastSentTime = currentTime
            }
        }
        onPressedChanged: {
            if (!pressed) {
                root.moved(slider.value)
            }
        }
    }

    Binding {
        target: slider
        property: "value"
        value: root.value
        when: !slider.pressed
    }
}


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

import QtQuick 2.0
import Nymea 1.0

Item {
    id: root
    property color color: Style.iconColor
    implicitWidth: Style.iconSize
    implicitHeight: Style.iconSize

    property int dotSize: width / 6

    property bool running: true

    Grid {
        id: grid
        columns: 3
        anchors.fill: parent
        spacing: (width - columns * root.dotSize) / (columns - 1)

        Repeater {
            id: dotRepeater
            model: Math.pow(grid.columns, 2)
            delegate: Rectangle {
                id: dot
                width: root.dotSize
                height: width
                color: root.color
                property int duration: 400
                property int row: Math.floor(index / grid.columns)
                property int pause: row * 200

                SequentialAnimation {
                    running: root.running && root.visible
                    loops: Animation.Infinite
                    PauseAnimation { duration: dot.pause }
                    NumberAnimation {
                        target: dot
                        property: "opacity"
                        from: 0.2; to: 1;
                        duration: dot.duration
                    }
                    NumberAnimation {
                        target: dot
                        property: "opacity"
                        from: 1; to: 0.2;
                        duration: dot.duration
                    }
                }
            }
        }
    }
}

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

import QtQuick 2.3
import Nymea 1.0

Item {
    id: root

    property int ct: minCt
    property int minCt: 153
    property int maxCt: 500
    property Component touchDelegate
    property bool active: true
    property bool pressed: mouseArea.pressed

    Rectangle {
        height: parent.width
        width: parent.height
        anchors.centerIn: parent
        rotation: -90
        border.width: 1
        border.color: Style.foregroundColor

        gradient: Gradient {
            GradientStop { position: 0.0; color: "#efffff" }
            GradientStop { position: 0.5; color: "#ffffea" }
            GradientStop { position: 1.0; color: "#ffd649" }
        }
    }

    Loader {
        id: touchDelegateLoader
        // 0 : width = minCt : maxCt
        // x = (width * (ct - minCt) / (maxCt-minCt))
        property int position: (root.width * (root.ct - root.minCt) / (root.maxCt - root.minCt));
        x: item ? Math.max(0, Math.min(position - width * .5, parent.width - item.width)) : 0
        sourceComponent: root.touchDelegate
        visible: !mouseArea.pressed && root.active
        Behavior on x {
            enabled: !mouseArea.pressed
            NumberAnimation {}
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        preventStealing: true

        drag.minimumX: 0
        drag.maximumX: width - dndItem.width
        drag.minimumY: 0
        drag.maximumY: height - dndItem.height

        onPressed: {
            dndItem.x = Math.min(width - dndItem.width, Math.max(0, mouseX - dndItem.width / 2))
            dndItem.y = 0;
            mouseArea.drag.target = dndItem;
        }

        onPositionChanged: {
            root.ct = Math.min(root.maxCt, Math.max(root.minCt, (mouseX * (root.maxCt - root.minCt) / width) + root.minCt))
            print("ct is now", root.ct)
        }

        onReleased: {
            root.ct = Math.min(root.maxCt, Math.max(root.minCt, (mouseX * (root.maxCt - root.minCt) / width) + root.minCt))
            mouseArea.drag.target = undefined;
        }

    }

    Loader {
        id: dndItem
        sourceComponent: root.touchDelegate
        visible: mouseArea.pressed && root.active
    }
}

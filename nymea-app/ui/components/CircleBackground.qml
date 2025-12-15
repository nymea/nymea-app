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
import Qt5Compat.GraphicalEffects
import Nymea

import "../utils"

Item {
    id: root
    implicitHeight: 400
    implicitWidth: 400

    property alias iconSource: icon.name
    property color onColor: Style.accentColor
    property bool on: false
    property alias showOnGradient: opacityMask.visible

    readonly property Item contentItem: background

    signal clicked()


    Rectangle {
        id: background
        anchors.centerIn: parent
        height: Math.min(400, Math.min(parent.height, parent.width))
        width: height
        radius: width / 2
        color: Style.tileBackgroundColor
    }
    Rectangle {
        id: mask
        anchors.fill: background
        radius: height / 2
        visible: false
        color: "red"
    }

    MouseArea {
        anchors.fill: background
        onClicked: root.clicked()
    }

    ColorIcon {
        id: icon
        anchors.centerIn: background
        size: Math.min(Style.hugeIconSize, background.width * 0.4)
        color: root.on ? root.onColor : Style.iconColor
        Behavior on color { ColorAnimation { duration: Style.animationDuration } }
    }

    RadialGradient {
        id: gradient
        anchors.fill: background
        visible: false
        gradient: Gradient{
            GradientStop { position: .45; color: "transparent" }
            GradientStop { position: .5; color: root.onColor }
        }
    }

    OpacityMask {
        id: opacityMask
        opacity: root.on ? 1 : 0
        anchors.fill: gradient
        source: gradient
        maskSource: mask
        Behavior on opacity { NumberAnimation { duration: Style.animationDuration } }
    }

}

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

Item {
    id: root

    property alias backgroundItem: blurEffectSource.sourceItem
    property alias backgroundRect: blurEffectSource.sourceRect

    Behavior on x { enabled: d.animationsEnabled; NumberAnimation { duration: Style.animationDuration } }
    Behavior on y { enabled: d.animationsEnabled; NumberAnimation { duration: Style.animationDuration } }
    Behavior on width { enabled: d.animationsEnabled; NumberAnimation { duration: Style.animationDuration } }
    Behavior on height { enabled: d.animationsEnabled; NumberAnimation { duration: Style.animationDuration } }

    readonly property alias animationsEnabled: d.animationsEnabled

    Timer {
        running: visible
        repeat: false
        interval: 1
        onTriggered: {
            d.animationsEnabled = true
        }
    }
    onVisibleChanged: {
        if (!visible) {
            d.animationsEnabled = false
        }
    }

    QtObject {
        id: d
        property bool animationsEnabled: false
    }

    Rectangle {
        id: blurSource
        anchors.fill: parent
        color: Style.backgroundColor
        visible: false
        radius: Style.smallCornerRadius

        ShaderEffectSource {
            id: blurEffectSource
            anchors.fill: parent
        }
    }

    FastBlur {
        anchors.fill: parent
        source: blurSource
        radius: 32
        visible: root.visible
    }

    Rectangle {
        anchors.fill: parent
        color: Style.tooltipBackgroundColor
        opacity: .5
        radius: Style.smallCornerRadius
    }

}

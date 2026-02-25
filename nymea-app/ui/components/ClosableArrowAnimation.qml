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
import Nymea

Item {
    id: arrows
    width: Style.iconSize * 2
    height: parent.height * .6
    clip: true
    visible: state !== ""

    state: "" // "opening", "closing" or ""

    readonly property bool up: arrows.state === "opening"

    // NumberAnimation doesn't reload to/from while it's running. If we switch from closing to opening or vice versa
    // we need to somehow stop and start the animation
    property bool animationHack: true
    onAnimationHackChanged: {
        if (!animationHack) hackTimer.start();
    }
    Timer { id: hackTimer; interval: 1; onTriggered: arrows.animationHack = true }
    onStateChanged: arrows.animationHack = false

    NumberAnimation {
        target: arrowColumn
        property: "y"
        duration: 500
        easing.type: Easing.Linear
        from: arrows.up ? Style.iconSize : -Style.iconSize
        to: arrows.up ? -Style.iconSize : Style.iconSize
        loops: Animation.Infinite
        running: arrows.animationHack && (arrows.state === "opening" || arrows.state === "closing")
    }

    Column {
        id: arrowColumn
        width: parent.width

        Repeater {
            model: arrows.height / Style.iconSize + 1
            ColorIcon {
                name: arrows.up ? "qrc:/icons/up.svg" : "qrc:/icons/down.svg"
                width: parent.width
                height: width
                color: Style.accentColor
            }
        }
    }
}

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
import QtQuick.Controls.Material
import QtQuick.Layouts
import Nymea

Item {
    id: root
    property Thing thing: null

    readonly property StateType artworkStateType: thing ? thing.thingClass.stateTypes.findByName("artwork") : null
    readonly property State artworkState: artworkStateType ? thing.states.getState(artworkStateType.id) : null

    readonly property StateType playerTypeStateType: thing ? thing.thingClass.stateTypes.findByName("playerType") : null
    readonly property State playerTypeState: playerTypeStateType ? thing.states.getState(playerTypeStateType.id) : null

    readonly property int paintedWidth: fallbackImage.visible ? fallbackImage.width : artworkImage.paintedWidth
    readonly property int paintedHeight: fallbackImage.visible ? fallbackImage.height : artworkImage.paintedHeight

    Rectangle {
        id: fallbackImage
        anchors { left: parent.left; top: parent.top }
        height: visible ? Math.min(parent.height, parent.width) : artworkImage.paintedHeight - 1
        width: visible ? Math.min(parent.height, parent.width) : artworkImage.paintedWidth - 1
        visible: artworkImage.status !== Image.Ready || artworkImage.source === ""
        color: "black"

        ColorIcon {
            anchors.centerIn: parent
            width: Math.min(parent.height, parent.width) - app.margins * 2
            height: Math.min(parent.height, parent.width) - app.margins * 2
            name: root.playerTypeState.value === "video" ? "qrc:/icons/stock_video.svg" : "qrc:/icons/stock_music.svg"
            color: "white"
        }
    }

    Image {
        id: artworkImage
        anchors.fill: parent
        fillMode: Image.PreserveAspectFit
        source: root.artworkState.value
        visible: source !== ""
        horizontalAlignment: Image.AlignLeft
        verticalAlignment: Image.AlignTop
    }
}

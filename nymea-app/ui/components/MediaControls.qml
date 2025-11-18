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
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.1
import Nymea 1.0

RowLayout {
    id: root
    implicitHeight: Style.iconSize * (showExtendedControls ? 2 : 1) + app.margins
    spacing: 0

    property Thing thing: null

    property color iconColor: Style.iconColor

    property bool showExtendedControls: false

    readonly property State playbackState: thing.stateByName("playbackStatus")
    readonly property State shuffleState: thing.stateByName("shuffle")
    readonly property State repeatState: thing.stateByName("repeat")


    function executeAction(actionName, params) {
        if (params === undefined) {
            params = []
        }
        var actionTypeId = thing.thingClass.actionTypes.findByName(actionName).id;
        engine.thingManager.executeAction(thing.id, actionTypeId, params)
    }

    ProgressButton {
        imageSource: "qrc:/icons/media-playlist-shuffle.svg"
        longpressEnabled: false
        enabled: root.shuffleState !== null
        opacity: enabled ? 1 : .5
        visible: root.showExtendedControls
        color: root.shuffleState.value === false ? root.iconColor : Style.accentColor
        onClicked: {
            var params = []
            var param = {}
            param["paramTypeId"] = root.shuffleState.stateTypeId
            param["value"] = !root.shuffleState.value
            params.push(param)
            root.executeAction("shuffle", params)
        }
    }

    Item { Layout.fillWidth: true }
    ProgressButton {
        size: Style.iconSize * (root.showExtendedControls ? 1.5 : 1)
        imageSource: "qrc:/icons/media-skip-backward.svg"
        longpressImageSource: "qrc:/icons/media-seek-backward.svg"
        longpressEnabled: root.thing.thingClass.actionTypes.findByName("fastRewind") !== null
        enabled: root.playbackState && root.playbackState.value !== "Stopped"
        opacity: enabled ? 1 : .5
        color: root.iconColor

        repeat: true
        onClicked: {
            root.executeAction("skipBack")
        }
        onLongpressed: {
            root.executeAction("fastRewind")
        }
    }
    Item { Layout.fillWidth: true }
    ProgressButton {
        size: Style.iconSize * (root.showExtendedControls ? 2 : 1)
        imageSource: root.playbackState && root.playbackState.value === "Playing" ? "qrc:/icons/media-playback-pause.svg" : "qrc:/icons/media-playback-start.svg"
        longpressImageSource: "qrc:/icons/media-playback-stop.svg"
        longpressEnabled: root.playbackState && root.playbackState.value !== "Stopped"
        color: root.iconColor

        onClicked: {
            if (root.playbackState.value === "Playing") {
                root.executeAction("pause")
            } else {
                root.executeAction("play")
            }
        }

        onLongpressed: {
            root.executeAction("stop")
        }
    }
    Item { Layout.fillWidth: true }
    ProgressButton {
        size: Style.iconSize * (root.showExtendedControls ? 1.5 : 1)
        imageSource: "qrc:/icons/media-skip-forward.svg"
        longpressImageSource: "qrc:/icons/media-seek-forward.svg"
        longpressEnabled: root.thing.thingClass.actionTypes.findByName("fastForward") !== null
        enabled: root.playbackState && root.playbackState.value !== "Stopped"
        opacity: enabled ? 1 : .5
        repeat: true
        color: root.iconColor
        onClicked: {
            root.executeAction("skipNext")
        }
        onLongpressed: {
            root.executeAction("fastForward")
        }
    }
    Item { Layout.fillWidth: true }

    ProgressButton {
        size: Style.iconSize
        imageSource: root.repeatState.value === "One" ? "qrc:/icons/media-playlist-repeat-one.svg" : "qrc:/icons/media-playlist-repeat.svg"
        color: root.repeatState.value === "None" ? root.iconColor : Style.accentColor
        longpressEnabled: false
        enabled: root.repeatState !== null
        opacity: enabled ? 1 : .5
        visible: root.showExtendedControls
        property var allowedValues: ["None", "All", "One"]
        onClicked: {
            var params = []
            var param = {}
            param["paramTypeId"] = root.repeatState.stateTypeId;
            param["value"] = allowedValues[(allowedValues.indexOf(root.repeatState.value) + 1) % 3]
            params.push(param)
            root.executeAction("repeat", params)
        }
    }
}

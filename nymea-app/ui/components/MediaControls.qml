/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
* Copyright 2013 - 2020, nymea GmbH
* Contact: contact@nymea.io
*
* This file is part of nymea.
* This project including source code and documentation is protected by
* copyright law, and remains the property of nymea GmbH. All rights, including
* reproduction, publication, editing and translation, are reserved. The use of
* this project is subject to the terms of a license agreement to be concluded
* with nymea GmbH in accordance with the terms of use of nymea GmbH, available
* under https://nymea.io/license
*
* GNU General Public License Usage
* Alternatively, this project may be redistributed and/or modified under the
* terms of the GNU General Public License as published by the Free Software
* Foundation, GNU version 3. This project is distributed in the hope that it
* will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty
* of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
* Public License for more details.
*
* You should have received a copy of the GNU General Public License along with
* this project. If not, see <https://www.gnu.org/licenses/>.
*
* For any further details and any questions please contact us under
* contact@nymea.io or see our FAQ/Licensing Information on
* https://nymea.io/license/faq
*
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

import QtQuick 2.5
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.1
import Nymea 1.0

RowLayout {
    id: root
    implicitHeight: app.iconSize * (showExtendedControls ? 2 : 1) + app.margins

    property Thing thing: null

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
        Layout.preferredHeight: app.iconSize
        Layout.preferredWidth: height
        imageSource: "../images/media-playlist-shuffle.svg"
        longpressEnabled: false
        enabled: root.shuffleState !== null
        opacity: enabled ? 1 : .5
        visible: root.showExtendedControls
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
        Layout.preferredHeight: app.iconSize * (root.showExtendedControls ? 1.5 : 1)
        Layout.preferredWidth: height
        imageSource: "../images/media-skip-backward.svg"
        longpressImageSource: "../images/media-seek-backward.svg"
        longpressEnabled: root.thing.thingClass.actionTypes.findByName("fastRewind") !== null
        enabled: root.playbackState && root.playbackState.value !== "Stopped"
        opacity: enabled ? 1 : .5

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
        Layout.preferredHeight: app.iconSize * (root.showExtendedControls ? 2 : 1)
        Layout.preferredWidth: height
        imageSource: root.playbackState && root.playbackState.value === "Playing" ? "../images/media-playback-pause.svg" : "../images/media-playback-start.svg"
        longpressImageSource: "../images/media-playback-stop.svg"
        longpressEnabled: root.playbackState && root.playbackState.value !== "Stopped"

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
        Layout.preferredHeight: app.iconSize * (root.showExtendedControls ? 1.5 : 1)
        Layout.preferredWidth: height
        imageSource: "../images/media-skip-forward.svg"
        longpressImageSource: "../images/media-seek-forward.svg"
        longpressEnabled: root.thing.thingClass.actionTypes.findByName("fastForward") !== null
        enabled: root.playbackState && root.playbackState.value !== "Stopped"
        opacity: enabled ? 1 : .5
        repeat: true
        onClicked: {
            root.executeAction("skipNext")
        }
        onLongpressed: {
            root.executeAction("fastForward")
        }
    }
    Item { Layout.fillWidth: true }

    ProgressButton {
        Layout.preferredHeight: app.iconSize
        Layout.preferredWidth: height
        imageSource: root.repeatState.value === "One" ? "../images/media-playlist-repeat-one.svg" : "../images/media-playlist-repeat.svg"
        color: root.repeatState.value === "None" ? Style.iconColor : Style.accentColor
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

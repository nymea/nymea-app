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
    implicitHeight: iconSize + app.margins

    property Device device: null
    property int iconSize: app.iconSize * 1.5

    readonly property StateType playbackStateType: device ? device.deviceClass.stateTypes.findByName("playbackStatus") : null
    readonly property State playbackState: playbackStateType ? device.states.getState(playbackStateType.id) : null

    function executeAction(actionName, params) {
        var actionTypeId = device.deviceClass.actionTypes.findByName(actionName).id;
        engine.deviceManager.executeAction(device.id, actionTypeId, params)
    }

    Item { Layout.fillWidth: true }
    ProgressButton {
        Layout.preferredHeight: root.iconSize * .6
        Layout.preferredWidth: height
        imageSource: "../images/media-skip-backward.svg"
        longpressImageSource: "../images/media-seek-backward.svg"
        enabled: root.playbackState.value !== "Stopped"
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
        Layout.preferredHeight: root,iconSize
        Layout.preferredWidth: height
        imageSource: root.playbackState && root.playbackState.value === "Playing" ? "../images/media-playback-pause.svg" : "../images/media-playback-start.svg"
        longpressImageSource: "../images/media-playback-stop.svg"
        longpressEnabled: root.playbackState.value !== "Stopped"

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
        Layout.preferredHeight: root.iconSize * .6
        Layout.preferredWidth: height
        imageSource: "../images/media-skip-forward.svg"
        longpressImageSource: "../images/media-seek-forward.svg"
        enabled: root.playbackState.value !== "Stopped"
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
}

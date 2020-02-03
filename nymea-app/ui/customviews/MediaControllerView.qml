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
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.1
import Nymea 1.0
import "../components"

CustomViewBase {
    id: root
    height: column.implicitHeight + app.margins * 2

    function executeAction(actionName) {
        var actionTypeId = deviceClass.actionTypes.findByName(actionName).id;
        print("executing", device, device.id, actionTypeId, actionName, deviceClass.actionTypes)
        engine.deviceManager.executeAction(device.id, actionTypeId)
    }

    property var playbackState: device.states.getState(deviceClass.stateTypes.findByName("playbackStatus").id)
    property var playbackStateValue: playbackState.value
    onPlaybackStateValueChanged: populateControls()
    Component.onCompleted: populateControls()

    function populateControls() {
        print("generating controls")
        controlsModel.clear();
        controlsModel.append({image: "../images/media-skip-backward.svg", action: "skipBack"})
        controlsModel.append({image: "../images/media-seek-backward.svg", action: "rewind"})
        controlsModel.append({image: "../images/media-playback-stop.svg", action: "stop"})
        if (playbackState.value === "Paused" || playbackState.value === "Stopped") {
            controlsModel.append({image: "../images/media-playback-start.svg", action: "play"})
        }
        if (playbackState.value === "Playing") {
            controlsModel.append({image: "../images/media-playback-pause.svg", action: "pause"})
        }

        controlsModel.append({image: "../images/media-seek-forward.svg", action: "fastForward"})
        controlsModel.append({image: "../images/media-skip-forward.svg", action: "skipNext"})
    }

    ColumnLayout {
        id: column
        anchors { left: parent.left; right: parent.right }

        Row {
            id: controlsRow
            Layout.fillWidth: true

            property int iconSize: Math.max(app.iconSize * 2, column.width / controlsModel.count)

            Repeater {
                model: ListModel {
                    id: controlsModel
                }
                delegate: AbstractButton {

                    height: app.iconSize * 2
                    width: controlsRow.iconSize
                    ColorIcon {
                        height: parent.height
                        width: height
                        name: model.image
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                    onClicked: {
                        executeAction(model.action)
                    }
                }
            }
        }
    }
}

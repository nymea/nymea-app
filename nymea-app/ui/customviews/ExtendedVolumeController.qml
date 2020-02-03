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
    height: row.implicitHeight + app.margins * 2

    RowLayout {
        id: row
        anchors { left: parent.left; top: parent.top; right: parent.right; margins: app.margins }

        AbstractButton {
            width: app.iconSize * 2
            height: width

            property var muteState: root.device.states.getState(deviceClass.stateTypes.findByName("mute").id)
            property bool isMuted: muteState.value === true

            ColorIcon {
                anchors.fill: parent
                name: "../images/audio-speakers-muted-symbolic.svg"
                color: parent.isMuted ? app.accentColor : keyColor
            }

            onClicked: {
                var paramList = []
                var muteParam = {}
                muteParam["paramTypeId"] = deviceClass.stateTypes.findByName("mute").id
                muteParam["value"] = !isMuted
                paramList.push(muteParam)
                engine.deviceManager.executeAction(root.device.id, deviceClass.actionTypes.findByName("mute").id, paramList)
            }
        }

        ThrottledSlider {
            Layout.fillWidth: true
            value: root.device.stateValue(deviceClass.stateTypes.findByName("volume").id)
            from: 0
            to: 100
            onMoved: {
                var paramList = []
                var muteParam = {}
                muteParam["paramTypeId"] = deviceClass.stateTypes.findByName("volume").id
                muteParam["value"] = value
                paramList.push(muteParam)
                engine.deviceManager.executeAction(root.device.id, deviceClass.actionTypes.findByName("volume").id, paramList)
            }
        }
    }
}

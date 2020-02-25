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

import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2
import QtQuick.Layouts 1.3
import Nymea 1.0

RowLayout {
    id: root
    implicitWidth: childrenRect.width

    property Device device: null
    readonly property var deviceClass: device ? engine.deviceManager.deviceClasses.getDeviceClass(device.deviceClassId) : null
    readonly property var openState: device ? device.states.getState(deviceClass.stateTypes.findByName("state").id) : null
    readonly property bool canStop: device && device.deviceClass.actionTypes.findByName("stop")

    property bool invert: false

    signal activated(string button);

    ItemDelegate {
        Layout.preferredWidth: app.iconSize * 2
        Layout.preferredHeight: width

        ColorIcon {
            anchors.fill: parent
            anchors.margins: app.margins
            name: root.invert ? "../images/down.svg" : "../images/up.svg"
            color: root.openState && root.openState.value === "opening" ? Material.accent : keyColor
        }
        onClicked: {
            engine.deviceManager.executeAction(root.device.id, root.deviceClass.actionTypes.findByName("open").id)
            root.activated("open")
        }
    }


   ItemDelegate {
        Layout.preferredWidth: app.iconSize * 2
        Layout.preferredHeight: width
        visible: root.canStop
//        color: Material.foreground
//        radius: height / 2

        ColorIcon {
            anchors.fill: parent
            anchors.margins: app.margins
            name: "../images/media-playback-stop.svg"
        }
        onClicked: {
            engine.deviceManager.executeAction(root.device.id, root.deviceClass.actionTypes.findByName("stop").id)
            root.activated("stop")
        }
    }

    ItemDelegate {
        Layout.preferredWidth: app.iconSize * 2
        Layout.preferredHeight: width

        ColorIcon {
            anchors.fill: parent
            anchors.margins: app.margins
            name: root.invert ? "../images/up.svg" : "../images/down.svg"
            color: root.openState && root.openState.value === "closing" ? Material.accent : keyColor
        }
        onClicked: {
            engine.deviceManager.executeAction(root.device.id, root.deviceClass.actionTypes.findByName("close").id)
            root.activated("close")
        }
    }
}

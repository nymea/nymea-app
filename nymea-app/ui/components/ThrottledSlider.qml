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

import QtQuick
import QtQuick.Controls

Item {
    id: root
    implicitHeight: slider.implicitHeight
    implicitWidth: slider.implicitWidth

    property alias orientation: slider.orientation

    property real value: 0
    property alias from: slider.from
    property alias to: slider.to
    property alias stepSize: slider.stepSize
    property alias snapMode: slider.snapMode

    readonly property real rawValue: slider.value

    signal moved(real value);

    Slider {
        id: slider
        anchors.left: parent.left; anchors.right: parent.right
        anchors.top: parent.top; anchors.bottom: parent.bottom
        from: 0
        to: 100
        property var lastSentTime: new Date()
        onValueChanged: {
            var currentTime = new Date();
            if (pressed && currentTime - lastSentTime > 200) {
                root.moved(slider.value)
                lastSentTime = currentTime
            }
        }
        onPressedChanged: {
            if (!pressed) {
                root.moved(slider.value)
            }
        }
    }

    Binding {
        target: slider
        property: "value"
        value: root.value
        when: !slider.pressed
    }
}


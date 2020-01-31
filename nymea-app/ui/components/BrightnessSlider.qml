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

import QtQuick 2.3

Item {
    id: root

    property int brightness: min
    property int min: 0
    property int max: 100
    property Component touchDelegate: Rectangle { height: root.height; width: 5; color: app.foregroundColor }

    property bool active: true
    property bool pressed: mouseArea.pressed

    signal moved(real brightness);

    Rectangle {
        height: parent.width
        width: parent.height
        anchors.centerIn: parent
        rotation: -90
        border.width: 1
        border.color: app.foregroundColor

        gradient: Gradient {
            GradientStop { position: 0.0; color: Qt.rgba(0, 0, 0, .5) }
            GradientStop { position: 1.0; color: Qt.rgba(1, 1, 1, .5) }
        }
    }

    Loader {
        id: touchDelegateLoader
        // 0 : width = min : max
        // x = (width * (brightness - min) / (max-min))
        property int position: (root.width * (root.brightness - root.min) / (root.max - root.min));
        x: item ? Math.max(0, Math.min(position - width * .5, parent.width - item.width)) : 0
        sourceComponent: root.touchDelegate
        visible: !mouseArea.pressed && root.active
        Behavior on x {
            enabled: !mouseArea.pressed
            NumberAnimation {}
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        preventStealing: true

        drag.minimumX: 0
        drag.maximumX: width - dndItem.width
        drag.minimumY: 0
        drag.maximumY: height - dndItem.height

        property var lastSentTime: new Date()

        onPressed: {
            dndItem.x = Math.min(width - dndItem.width, Math.max(0, mouseX - dndItem.width / 2))
            dndItem.y = 0;
            mouseArea.drag.target = dndItem;
        }

        onPositionChanged: {
            root.brightness = Math.min(root.max, Math.max(root.min, (mouseX * (root.max - root.min) / width) + root.min))

            var currentTime = new Date();
            if (pressed && currentTime - lastSentTime > 200) {
                root.moved(root.brightness)
                lastSentTime = currentTime
            }
        }

        onReleased: {
            root.brightness = Math.min(root.max, Math.max(root.min, (mouseX * (root.max - root.min) / width) + root.min))
            root.moved(root.brightness)
            mouseArea.drag.target = undefined;
        }

    }

    Loader {
        id: dndItem
        sourceComponent: root.touchDelegate
        visible: mouseArea.pressed && root.active
    }

}

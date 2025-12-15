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
import QtQuick.Layouts
import Nymea

ColumnLayout {
    id: root
    spacing: app.margins

    property int hour: 0
    property int minute: 0

    function selectHours() {
        d.mode = "hours"
    }
    function selectMinutes() {
        d.mode = "minutes"
    }
    Component.onCompleted: {
        initTimer.start();
    }
    Timer {
        id: initTimer
        interval: 1
        onTriggered: selectHours();
    }

    Row {
        Layout.alignment: Qt.AlignHCenter
        Label {
            text: app.pad(root.hour, 2)
            font.pixelSize: app.largeFont * 2
            opacity: d.mode == "hours" ? 1 : .6
            Behavior on opacity { NumberAnimation {duration: 250 } }
            MouseArea {
                anchors.fill: parent
                onClicked: selectHours()
            }
        }
        Label {
            text: ":"
            font.pixelSize: app.largeFont * 2
        }
        Label {
            text: app.pad(root.minute, 2)
            font.pixelSize: app.largeFont * 2
            opacity: d.mode == "minutes" ? 1 : .6
            Behavior on opacity { NumberAnimation {duration: 250 } }
            MouseArea {
                anchors.fill: parent
                onClicked: selectMinutes()
            }
        }
    }

    Item {
        id: d
        Layout.fillHeight: true
        Layout.fillWidth: true
        Layout.preferredHeight: width

        property string mode: "none"

        Item {
            id: dial
            height: Math.min(parent.height, parent.width)
            width: height
            anchors.centerIn: parent

            Repeater {
                id: hours12

                model: 12
                delegate: Item {
                    id: delegate
                    visible: d.mode == "hours"
                    anchors.centerIn: parent
                    height: parent.height
                    rotation: (360 / 12) * (index + 1)
                    width: 30

                    property alias field: fieldItem
                    Item {
                        id: fieldItem
                        anchors { left: parent.left; top: parent.top; right: parent.right }
                        height: width

                        Label {
                            anchors.centerIn: parent
                            text: index + 1
                            rotation: -delegate.rotation
                        }
                    }
                }
            }

            Repeater {
                id: hours24

                property int selectedIndex: root.hour - 12

                model: 12
                delegate: Item {
                    id: delegate
                    visible: d.mode == "hours"
                    anchors.centerIn: parent
                    height: parent.height - 80
                    rotation: (360 / 12) * (index + 12)
                    width: 30

                    property alias field: fieldItem
                    Item {
                        id: fieldItem
                        anchors { left: parent.left; top: parent.top; right: parent.right }
                        height: width

                        Label {
                            anchors.centerIn: parent
                            text: index + 12 == 12 ? "00" : index + 12
                            rotation: -delegate.rotation
                            opacity: .8
                        }
                    }
                }
            }

            Repeater {
                id: minutes

                property int selectedIndex: 0
                readonly property int selectedMinute: selectedIndex

                model: 60
                delegate: Item {
                    id: delegate
                    visible: d.mode == "minutes"
                    anchors.centerIn: parent
                    height: parent.height
                    rotation: (360 / 60) * (index)
                    width: 30

                    property alias field: fieldItem
                    Item {
                        id: fieldItem
                        anchors { left: parent.left; top: parent.top; right: parent.right }
                        height: width

                        Label {
                            anchors.centerIn: parent
                            text: index
                            rotation: -delegate.rotation
                            visible: index % 5 == 0
                        }
                    }
                }
            }

            Item {
                id: newDot
                height: (parent.height + 10) - (d.mode == "hours" && (root.hour == 0 || root.hour > 12) ? 80 : 0)
                width: 40
                anchors.centerIn: parent
                z: -1
                rotation: {
                    if (d.mode == "hours") {
                        if (root.hour > 0 && root.hour < 13) {
                            return root.hour * 360 / 12
                        }
                        return (root.hour - 12 % 12) * 360 / 12
                    }
                    return root.minute * 360 / 60
                }
                Behavior on height { NumberAnimation { duration: 100 } }
                Behavior on rotation { RotationAnimation { duration: 100; direction: RotationAnimation.Shortest } }

                Rectangle {
                    anchors { left: parent.left; top: parent.top; right: parent.right }
                    height: width
                    color: Style.accentColor
                    radius: width / 2
                }
                Rectangle {
                    anchors.top: parent.top
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 5
                    height: parent.height / 2
                    color: Style.accentColor
                    radius: width / 2
                }
            }

            MouseArea {
                anchors.fill: parent

                onPressed: {
                    update();
                }
                onPositionChanged: update();
                onReleased: {
                    if (d.mode == "hours") {
                        selectMinutes();
                    }
                }

                function update() {
                    var angle = calculateAngle(mouseX, mouseY);

                    var items = d.mode == "hours" ? 12 : 60

                    // angle : 360 = num : 12
                    var selected = Math.round(angle * items / 360) % items;

                    if (d.mode == "hours") {
                        if (calculateDistanceToCenter(mouseX, mouseY) < (width / 2) - 40) {
                            selected = selected + 12
                        }
                        // swap 12 and 00
                        if (selected === 12) {
                            selected = 0
                        } else if (selected === 0) {
                            selected = 12
                        }
                        if (root.hour !== selected) {
                            root.hour = selected
                            PlatformHelper.vibrate(PlatformHelper.HapticsFeedbackSelection)
                        }
                    } else {
                        if (root.minute !== selected) {
                            root.minute = selected
                            PlatformHelper.vibrate(PlatformHelper.HapticsFeedbackSelection)
                        }
                    }

                }

                function calculateAngle(mouseX, mouseY) {
                    // transform coords to center of dial
                    mouseX -= width / 2
                    mouseY -= height / 2

                    var rad = Math.atan(mouseY / mouseX);
                    var angle = rad * 180 / Math.PI

                    angle += 90;

                    if (mouseX < 0 && mouseY >= 0) angle = 180 + angle;
                    if (mouseX < 0 && mouseY < 0) angle = 180 + angle;

                    return angle;
                }

                function calculateDistanceToCenter(mouseX, mouseY) {
                    var a = mouseY - (height / 2)
                    var b = mouseX - (width / 2)
                    var c = Math.sqrt(Math.pow(a, 2) + Math.pow(b, 2))
                    return c;
                }
            }
        }
    }
}

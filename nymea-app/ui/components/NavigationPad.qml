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
import Nymea
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts

Item {
    id: root

    property Thing thing: null

    readonly property bool isExtended: thing && thing.thingClass.interfaces.indexOf("extendednavigationpad") >= 0

    readonly property ActionType navigateActionType: thing ? thing.thingClass.actionTypes.findByName("navigate") : null

    Pane {
        id: pane
        Material.elevation: 2
        width: Math.min(root.width, root.height)
        height: Math.min(root.width, root.height)
        anchors.centerIn: parent

        padding: 0

        contentItem: Item {

            Pane {
                anchors.centerIn: parent
                Material.elevation: 2
                rotation: 45
                width: Math.sqrt(Math.pow(parent.width / 2, 2) + Math.pow(parent.height / 2, 2))
                height: width
            }

            KeypadButton {
                id: backButton
                anchors { left: parent.left; top: parent.top; margins: parent.width * .1 }
                height: Style.iconSize
                width: Style.iconSize
                imageSource: "qrc:/icons/back.svg"
                Item { id: backButtonArea; anchors.centerIn: parent; width: pane.width / 4; height: width; rotation: 45; }
            }
            KeypadButton {
                id: menuButton
                anchors { right: parent.right; top: parent.top; margins: parent.width * .1 }
                height: Style.iconSize
                width: Style.iconSize
                visible: root.thing.thingClass.interfaces.indexOf("extendednavigationpad") >= 0
                imageSource: "qrc:/icons/navigation-menu.svg"
                Item { id: menuButtonArea; anchors.centerIn: parent; width: pane.width / 4; height: width; rotation: 45 }
            }
            KeypadButton {
                id: homeButton
                anchors { left: parent.left; bottom: parent.bottom; margins: parent.width * .1 }
                height: Style.iconSize
                width: Style.iconSize
                imageSource: "qrc:/icons/home.svg"
                visible: root.thing.thingClass.interfaces.indexOf("extendednavigationpad") >= 0
                Item { id: homeButtonArea; anchors.centerIn: parent; width: pane.width / 4; height: width; rotation: 45 }
            }
            KeypadButton {
                id: infoButton
                anchors { right: parent.right; bottom: parent.bottom; margins: parent.width * .1 }
                height: Style.iconSize
                width: Style.iconSize
                imageSource: "qrc:/icons/info.svg"
                visible: root.thing.thingClass.interfaces.indexOf("extendednavigationpad") >= 0
                Item { id: infoButtonArea; anchors.centerIn: parent; width: pane.width / 4; height: width; rotation: 45 }
            }
            Rectangle {
                id: enterButton
                anchors.centerIn: parent
                height: Style.iconSize
                width: Style.iconSize
                radius: width / 2
                border.color: t.running ? Style.accentColor : "#808080"
                Behavior on border.color { ColorAnimation { duration: 200 } }
                Timer { id: t; interval: 400 }
                border.width: 3
                color: "transparent"
                function activate() { t.start() }
            }

            Item { id: enterButtonArea; anchors.centerIn: parent; width: pane.width / 4; height: width; rotation: 0 }
            Item { id: leftButtonArea; anchors { left: parent.left; verticalCenter: parent.verticalCenter; } width: pane.width / 4; height: width; rotation: 0 }
            Item { id: rightButtonArea; anchors { right: parent.right; verticalCenter: parent.verticalCenter; } width: pane.width / 4; height: width;  rotation: 0 }
            Item { id: upButtonArea; anchors { top: parent.top; horizontalCenter: parent.horizontalCenter; } width: pane.width / 4; height: width; rotation: 0 }
            Item { id: downButtonArea; anchors { bottom: parent.bottom; horizontalCenter: parent.horizontalCenter; } width: pane.width / 4; height: width; rotation: 0 }

            Repeater {
                id: directionsRepeater
                model: 4

                Column {
                    height: parent.height * .8
                    width: Style.iconSize
                    anchors.centerIn: parent
                    rotation: index * 90

                    function activate() {
                        if (!delayTimer.running) {
                            delayTimer.idx = 2;
                            delayTimer.start();
                        } else {
                            delayTimer.onceMore = true;
                        }
                    }
                    Timer {
                        id: delayTimer;
                        triggeredOnStart: true
                        interval: 150
                        repeat: true
                        property int idx: 2
                        property bool onceMore: false
                        onTriggered: {
                            print("activating", idx)
                            childRepeater.itemAt(idx--).activate()
                            if (idx < 0) {
                                if (onceMore) {
                                    idx = 2;
                                    onceMore = false;
                                } else {
                                    delayTimer.stop();
                                }
                            }
                        }
                    }


                    Repeater {
                        id: childRepeater
                        model: 3
                        KeypadButton {
                            height: Style.iconSize
                            width: height
                            imageSource: "qrc:/icons/up.svg"
                        }
                    }
                }
            }
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            preventStealing: true

            property int startX
            property int startY

            property string lockedDirection: "none"
            readonly property int steps: 20
            readonly property int stepSize: height / steps

            property int horizontalSteps: 0
            property int verticalSteps: 0

            onPressed: {
                startX = mouseX
                startY = mouseY
            }

            onPositionChanged: {
                var horizontalDiff = mouseX - startX
                var verticalDiff = mouseY - startY

                if (lockedDirection == "none") {
                    if (Math.abs(horizontalDiff) > stepSize) {
                        lockedDirection = "horizontal"
                        trigger(horizontalDiff > 0 ? "right" : "left")
                        directionsRepeater.itemAt(horizontalDiff > 0 ? 1 : 2).activate()
                    } else if (Math.abs(verticalDiff) > stepSize) {
                        lockedDirection = "vertical"
                        trigger(verticalDiff > 0 ? "down" : "up")
                        directionsRepeater.itemAt(verticalDiff > 0 ? 2 : 0).activate()
                    }
                }

                horizontalSteps = horizontalDiff / stepSize
                verticalSteps = verticalDiff / stepSize
            }

            onReleased: {
                if (lockedDirection === "none") {
                    if (checkButton(backButtonArea)) {
                        trigger("back");
                        backButton.activate();
                    } else if (checkButton(leftButtonArea)) {
                        trigger("left");
                        directionsRepeater.itemAt(3).activate()
                    } else if (checkButton(rightButtonArea)) {
                        trigger("right");
                        directionsRepeater.itemAt(1).activate()
                    } else if (checkButton(upButtonArea)) {
                        trigger("up");
                        directionsRepeater.itemAt(0).activate()
                    } else if (checkButton(downButtonArea)) {
                        trigger("down");
                        directionsRepeater.itemAt(2).activate()
                    } else if (checkButton(enterButtonArea)) {
                        trigger("enter");
                        enterButton.activate();
                    } else if (checkButton(menuButtonArea)) {
                        trigger("menu");
                        menuButton.activate();
                    } else if (checkButton(homeButtonArea)) {
                        trigger("home");
                        homeButton.activate();
                    } else if (checkButton(infoButtonArea)) {
                        trigger("info");
                        infoButton.activate();
                    }
                }

                lockedDirection = "none"
            }

            function checkButton(button) {
                var coords = mouseArea.mapToItem(button, mouseX, mouseY)
                if (coords.x > 0 && coords.x < button.width && coords.y > 0 && coords.y < button.height) {
                    return true;
                }
                return false;
            }

            function trigger(direction) {
                var params = []
                var param = {}
                param["paramTypeId"] = root.navigateActionType.paramTypes.findByName("to").id;
                param["value"] = direction;
                params.push(param);
                engine.thingManager.executeAction(root.thing.id, root.navigateActionType.id, params)
                PlatformHelper.vibrate(PlatformHelper.HapticsFeedbackSelection)
            }

            Timer {
                id: repeatTimer
                running: mouseArea.lockedDirection !== "none"
                interval: 1000
                repeat: true
                onRunningChanged: interval = 1000
                onTriggered: {
                    if (mouseArea.lockedDirection === "horizontal") {
                        mouseArea.trigger(mouseArea.horizontalSteps > 0 ? "right" : "left")
                        directionsRepeater.itemAt(mouseArea.horizontalSteps > 0 ? 1 : 3).activate()
                    } else if (mouseArea.lockedDirection === "vertical") {
                        mouseArea.trigger(mouseArea.verticalSteps > 0 ? "down" : "up")
                        directionsRepeater.itemAt(mouseArea.verticalSteps > 0 ? 2 : 0).activate()
                    }
                    interval = Math.max(50, 1000 - Math.abs(mouseArea.lockedDirection === "horizontal" ? mouseArea.horizontalSteps : mouseArea.verticalSteps) * 100)
                }
            }
        }
    }
}

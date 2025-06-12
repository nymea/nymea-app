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
import QtQuick.Controls.Material 2.2
import QtQuick.Layouts 1.1
import QtGraphicalEffects 1.0
import Nymea 1.0
import "../components"
import "../customviews"
import "../utils"

ThingPageBase {
    id: root

    readonly property bool landscape: width > height * 1.5
    readonly property bool isExtended: thing.thingClass.interfaces.indexOf("extendedclosable") >= 0
    readonly property bool isVenetian: thing.thingClass.interfaces.indexOf("venetianblind") >= 0

    readonly property StateType angleStateType: isVenetian ? thing.thingClass.stateTypes.findByName("angle") : null

    readonly property State movingState: thing.stateByName("moving")
    readonly property State percentageState: thing.stateByName("percentage")
    readonly property State angleState: isVenetian ? thing.states.getState(angleStateType.id) : null


    readonly property bool moving: movingState ? movingState.value === true : false

//    onMovingChanged: if (!moving) angleMovable.visible = false

    GridLayout {
        anchors.fill: parent
//        columns: root.isVenetian ?
//                     root.landscape ? 3 : 2
//                   : root.landscape ? 2 : 1
        columns: root.landscape ? 2 : 1

        CircleBackground {
            id: background
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.margins: Style.hugeMargins

            Item {
                id: blind
                anchors.fill: parent

                Rectangle {
                    anchors.centerIn: parent
                    height: parent.height
                    width: 2
                    color: Style.accentColor
                    visible: root.angleState
                }

                Canvas {
                    id: canvas
                    anchors.centerIn: parent
                    anchors.horizontalCenterOffset: root.angleState ? -parent.width / 4 - Style.smallMargins: 0
                    width: background.contentItem.width / (root.angleState ? 2 : 1)
                    height: background.contentItem.height

                    property real progress: root.percentageState ?
                                                percentageDragArea.pressed ? percentageDragArea.draggedProgress : root.percentageState.value  / 100
                                              : .5

                    anchors.verticalCenterOffset: -height * (1 - progress)

                    onPaint: {
                        var ctx = getContext("2d");
                        ctx.reset();

                        ctx.fillStyle = Style.tileForegroundColor
                        var segments = 10;
                        var segmentHeight = height / segments
                        var barHeight = segmentHeight - Style.smallMargins
                        for (var i = 0; i < segments; i++) {
                            ctx.fillRect(0, i * segmentHeight + (segmentHeight - barHeight) / 2, width, barHeight)
                        }
                    }
                }

                ActionQueue {
                    id: percentageActionQueue
                    thing: root.thing
                    stateName: "percentage"
                }

                MouseArea {
                    id: percentageDragArea
                    anchors.centerIn: parent
                    anchors.horizontalCenterOffset: root.angleState ? -parent.width / 4 - Style.smallMargins: 0
                    width: background.contentItem.width / (root.angleState ? 2 : 1)
                    height: background.contentItem.height
                    property real draggedProgress: Math.max(0, Math.min(1, mouseY / height))
                    onReleased: percentageActionQueue.sendValue(mouseY / height * 100)
                }

                Canvas {
                    id: angleCanvas
                    anchors.centerIn: parent
                    visible: root.angleState
                    anchors.horizontalCenterOffset: parent.width / 4
                    width: background.contentItem.width / (root.angleState ? 2 : 1)
                    height: background.contentItem.height

                    property real angle: root.angleState ?
                                                angleDragArea.pressed ? angleDragArea.draggedAngle : root.angleState.value
                                              : 0
                    onAngleChanged: requestPaint()

                    property real pendingAngle: angle

                    onPaint: {
                        var ctx = getContext("2d");
                        ctx.reset();

                        ctx.fillStyle = Style.tileForegroundColor

                        var segments = 10;
                        var segmentHeight = height / segments
                        var barHeight = Style.smallMargins
                        var barWidth = width / 4
                        ctx.beginPath();
                        for (var i = 0; i < segments; i++) {
                            ctx.save()
                            ctx.translate(barWidth / 2 + Style.smallMargins, i * segmentHeight + (segmentHeight - barHeight) / 2)
                            ctx.rotate(angleCanvas.angle * Math.PI / 180)
                            ctx.fillRect(-barWidth / 2, -barHeight / 2, width / 4, barHeight)
                            ctx.restore()
                        }
                        ctx.closePath()


                        ctx.strokeStyle = Style.accentColor
                        ctx.lineWidth = 2

                        ctx.save()
                        ctx.beginPath();
                        ctx.translate(barWidth / 2 + Style.smallMargins, (height - barHeight) / 2)
                        ctx.rotate(angleCanvas.pendingAngle * Math.PI / 180)
                        ctx.moveTo(-barWidth / 2, 0)
                        ctx.lineTo(width, 0)
                        ctx.stroke();
                        ctx.closePath();
                        ctx.restore()

                        ctx.strokeStyle = Style.tileForegroundColor

                        ctx.save()
                        ctx.beginPath();
                        ctx.translate(barWidth / 2 + Style.smallMargins, (height - barHeight) / 2)
                        ctx.rotate(angleCanvas.angle * Math.PI / 180)
                        ctx.moveTo(-barWidth / 2, 0)
                        ctx.lineTo(width, 0)
                        ctx.stroke();
                        ctx.closePath();
                        ctx.restore()
                    }

                }

                ActionQueue {
                    id: angleActionQueue
                    thing: root.thing
                    stateName: "angle"
                }

                MouseArea {
                    id: angleDragArea
                    visible: root.angleState
                    anchors.fill: angleCanvas
                    property real draggedAngle: root.angleState ? Math.min(root.angleStateType.maxValue,
                                                         Math.max(root.angleStateType.minValue,
                                                                  mouseY / height * (root.angleStateType.maxValue - root.angleStateType.minValue) + root.angleStateType.minValue))
                                                                : 0
                    onReleased: {
                        print("sending angle", draggedAngle)
                        angleCanvas.pendingAngle = draggedAngle
                        angleActionQueue.sendValue(draggedAngle)
                    }
                }

            }

            OpacityMask {
                anchors.fill: parent
                source: ShaderEffectSource {
                    sourceItem: blind
                    sourceRect: background.contentItem.childrenRect
                    hideSource: true
                }
                maskSource: background
            }

        }

//        Item {
//            id: window

//            Layout.preferredWidth: root.landscape ?
//                                       Math.min(parent.width *.4, parent.height)
//                                     : Math.min(Math.min(parent.width, 500), (parent.height - shutterControlsContainer.minimumHeight)) / (root.isVenetian ? 2 : 1)
////            Layout.preferredWidth: root.landscape ?
////                                       Math.min(parent.width - shutterControlsContainer.minimumWidth, parent.height) - app.margins
////                                     : Math.min(Math.min(parent.width, parent.height - shutterControlsContainer.minimumHeight), 500)
//            Layout.preferredHeight: root.landscape ?
//                                        width
//                                      : width * (root.isVenetian ? 2 : 1)
//            Layout.alignment: root.landscape ? Qt.AlignVCenter : Qt.AlignHCenter
//            clip: true

//            ClosablesControlLarge {
//                anchors { left: parent.left; top: parent.top; bottom: parent.bottom; }
//                width: height
//                thing: root.thing

//                ClosableArrowAnimation {
//                    id: arrowAnimation
//                    anchors.centerIn: parent
//                    anchors.horizontalCenterOffset: isVenetian ? -width: 0

//                    onStateChanged: {
//                        if (state != "") {
//                            animationTimer.start();
//                        }
//                    }

//                    Timer {
//                        id: animationTimer
//                        running: false
//                        interval: 5000
//                        repeat: false
//                        onTriggered: parent.state = ""
//                    }
//                }

//            }
//        }


//        Item {
//            id: angleControls
//            Layout.preferredWidth: root.landscape ? window.width / 2 : window.width
//            Layout.preferredHeight: window.height
//            visible: root.isVenetian

//            Item {
//                anchors.fill: parent

//                Item {
//                    anchors { fill: parent; topMargin: parent.height * .09; bottomMargin: parent.height * 0.09; leftMargin: app.margins * 2; rightMargin: app.margins * 2 }

//                    Repeater {
//                        model: 10
//                        Item {
//                            width: parent.height * .1
//                            height: width
//                            y: parent.height / 10 * index

//                            Rectangle {
//                                anchors.centerIn: parent
//                                width: parent.width
//                                height: width / 4
//                                rotation: root.angle
//                                color: "#808080"
//                            }
//                        }
//                    }

//                    Item {
//                        id: angleMovable
//                        anchors.fill: parent
//                        property int angle: 0
//                        visible: false

//                        Repeater {
//                            model: 10
//                            Item {
//                                width: parent.height * .1
//                                height: width
//                                y: parent.height / 10 * index

//                                Rectangle {
//                                    anchors.centerIn: parent
//                                    width: parent.width
//                                    height: width / 4
//                                    rotation: angleMovable.angle
//                                    color: Style.foregroundColor
//                                    opacity: 0.1
//                                }
//                            }

//                        }
//                    }

//                    Item {
//                        anchors { top: parent.top; bottom: parent.bottom; right: parent.right; rightMargin: app.margins / 2 }
//                        width: parent.width * .5

//                        Rectangle {
//                            id: angleSlider
//                            anchors.fill: parent
//                            color: Qt.rgba(Style.foregroundColor.r, Style.foregroundColor.g, Style.foregroundColor.b, 0.1)
//                            visible: false
//                            ColorIcon {
//                                anchors { horizontalCenter: parent.horizontalCenter; top: parent.top; topMargin: app.margins }
//                                height: Style.iconSize
//                                width: Style.iconSize
//                                name: "qrc:/icons/up.svg"
//                            }
//                            ColorIcon {
//                                anchors { horizontalCenter: parent.horizontalCenter; bottom: parent.bottom; bottomMargin: app.margins }
//                                height: Style.iconSize
//                                width: Style.iconSize
//                                name: "qrc:/icons/down.svg"
//                            }
//                            Rectangle {
//                                width: parent.width
//                                height: 2
//                                color: angleMouseArea.containsMouse ? Style.accentColor : "transparent"
//                                y: angleMouseArea.mouseY
//                                onYChanged: sliderMask.update()
//                            }

//                        }
//                        Rectangle {
//                            id: mask
//                            anchors.fill: parent
//                            radius: Style.cornerRadius
//                            color: "blue"
//                            visible: false
//                        }
//                        OpacityMask {
//                            id: sliderMask
//                            anchors.fill: parent
//                            source: angleSlider
//                            maskSource: mask
//                        }

//                        MouseArea {
//                            id: angleMouseArea
//                            anchors.fill: parent
//                            // angle : totalAngle  = mouseY : height
//                            property int totalAngle: root.angleState ? root.angleStateType.maxValue - root.angleStateType.minValue : 0
//                            property int angle: root.angleState ? totalAngle * mouseY / height + root.angleStateType.minValue : 0
//                            hoverEnabled: true

//                            property int startY: 0

//                            onPressed: {
//                                startY = mouseY
//                                angleMovable.visible = true
//                            }
//                            onMouseYChanged: if (pressed) angleMovable.angle = angle

//                            onReleased: {
//                                print("released at", angle)
//                                var targetAngle = 0
//                                if (Math.abs(mouseY - startY) < 5) {
//                                    print("clicked")
//                                    // clicked without drag
//                                    if (mouseY < width) {
//                                        print("top area")
//                                        // clicked in top area
//                                        if (root.angle > 5) {
//                                            targetAngle = 0;
//                                        } else {
//                                            targetAngle = root.angleStateType.minValue
//                                        }
//                                    } else if (mouseY > height - width){
//                                        print("bottom area")
//                                        //clicked in bottom area
//                                        if (root.angle < -5) {
//                                            targetAngle = 0;
//                                        } else {
//                                            targetAngle = root.angleStateType.maxValue
//                                        }
//                                    } else {
//                                        targetAngle = angle
//                                    }

//                                } else {
//                                    targetAngle = angle
//                                }

//                                angleMovable.angle = targetAngle


//                                var actionType = root.thing.thingClass.actionTypes.findByName("angle");
//                                var params = [];
//                                var percentageParam = {}
//                                percentageParam["paramTypeId"] = actionType.paramTypes.findByName("angle").id;
//                                percentageParam["value"] = targetAngle
//                                params.push(percentageParam);
//                                engine.thingManager.executeAction(root.thing.id, actionType.id, params);

//                            }
//                        }
//                    }
//                }
//            }
//        }



        ShutterControls {
            id: shutterControls
            Layout.fillWidth: true
            size: Style.bigIconSize
            backgroundEnabled: true
            thing: root.thing
        }
    }
}

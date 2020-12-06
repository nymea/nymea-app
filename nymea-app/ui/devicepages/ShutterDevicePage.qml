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

DevicePageBase {
    id: root

    readonly property bool landscape: width > height * 1.5
    readonly property bool isExtended: deviceClass.interfaces.indexOf("extendedclosable") >= 0
    readonly property bool isVenetian: deviceClass.interfaces.indexOf("venetianblind") >= 0

    readonly property StateType movingStateType: isExtended ? deviceClass.stateTypes.findByName("moving") : null
    readonly property StateType angleStateType: isVenetian ? deviceClass.stateTypes.findByName("angle") : null

    readonly property State movingState: isExtended ? device.states.getState(movingStateType.id) : null
    readonly property State percentageState: isExtended ? device.states.getState(deviceClass.stateTypes.findByName("percentage").id) : null
    readonly property State angleState: isVenetian ? device.states.getState(angleStateType.id) : null


    readonly property bool moving: movingState ? movingState.value === true : false
    readonly property int percentage: percentageState ? percentageState.value : 50
    readonly property int angle: angleState ? angleState.value : 0

    onMovingChanged: if (!moving) angleMovable.visible = false

    GridLayout {
        anchors.fill: parent
        columns: root.isVenetian ?
                     root.landscape ? 3 : 2
                   : root.landscape ? 2 : 1

        Item {
            id: window

            Layout.preferredWidth: root.landscape ?
                                       Math.min(parent.width *.4, parent.height)
                                     : Math.min(Math.min(parent.width, 500), (parent.height - shutterControlsContainer.minimumHeight)) / (root.isVenetian ? 2 : 1)
//            Layout.preferredWidth: root.landscape ?
//                                       Math.min(parent.width - shutterControlsContainer.minimumWidth, parent.height) - app.margins
//                                     : Math.min(Math.min(parent.width, parent.height - shutterControlsContainer.minimumHeight), 500)
            Layout.preferredHeight: root.landscape ?
                                        width
                                      : width * (root.isVenetian ? 2 : 1)
            Layout.alignment: root.landscape ? Qt.AlignVCenter : Qt.AlignHCenter
            clip: true

            ClosablesControlLarge {
                anchors { left: parent.left; top: parent.top; bottom: parent.bottom; }
                width: height
                thing: root.device

                ClosableArrowAnimation {
                    id: arrowAnimation
                    anchors.centerIn: parent
                    anchors.horizontalCenterOffset: isVenetian ? -width: 0

                    onStateChanged: {
                        if (state != "") {
                            animationTimer.start();
                        }
                    }

                    Timer {
                        id: animationTimer
                        running: false
                        interval: 5000
                        repeat: false
                        onTriggered: parent.state = ""
                    }
                }

            }
        }


        Item {
            id: angleControls
            Layout.preferredWidth: root.landscape ? window.width / 2 : window.width
            Layout.preferredHeight: window.height
            visible: root.isVenetian

            Item {
                anchors.fill: parent

                Item {
                    anchors { fill: parent; topMargin: parent.height * .09; bottomMargin: parent.height * 0.09; leftMargin: app.margins * 2; rightMargin: app.margins * 2 }

                    Repeater {
                        model: 10
                        Item {
                            width: parent.height * .1
                            height: width
                            y: parent.height / 10 * index

                            Rectangle {
                                anchors.centerIn: parent
                                width: parent.width
                                height: width / 4
                                rotation: root.angle
                                color: "#808080"
                            }
                        }
                    }

                    Item {
                        id: angleMovable
                        anchors.fill: parent
                        property int angle: 0
                        visible: false

                        Repeater {
                            model: 10
                            Item {
                                width: parent.height * .1
                                height: width
                                y: parent.height / 10 * index

                                Rectangle {
                                    anchors.centerIn: parent
                                    width: parent.width
                                    height: width / 4
                                    rotation: angleMovable.angle
                                    color: Style.foregroundColor
                                    opacity: 0.1
                                }
                            }

                        }
                    }

                    Item {
                        anchors { top: parent.top; bottom: parent.bottom; right: parent.right; rightMargin: app.margins / 2 }
                        width: parent.width * .5

                        Rectangle {
                            id: angleSlider
                            anchors.fill: parent
                            color: Qt.rgba(Style.foregroundColor.r, Style.foregroundColor.g, Style.foregroundColor.b, 0.1)
                            visible: false
                            ColorIcon {
                                anchors { horizontalCenter: parent.horizontalCenter; top: parent.top; topMargin: app.margins }
                                height: app.iconSize
                                width: app.iconSize
                                name: "../images/up.svg"
                            }
                            ColorIcon {
                                anchors { horizontalCenter: parent.horizontalCenter; bottom: parent.bottom; bottomMargin: app.margins }
                                height: app.iconSize
                                width: app.iconSize
                                name: "../images/down.svg"
                            }
                            Rectangle {
                                width: parent.width
                                height: 2
                                color: angleMouseArea.containsMouse ? Style.accentColor : "transparent"
                                y: angleMouseArea.mouseY
                                onYChanged: sliderMask.update()
                            }

                        }
                        Rectangle {
                            id: mask
                            anchors.fill: parent
                            radius: Style.tileRadius
                            color: "blue"
                            visible: false
                        }
                        OpacityMask {
                            id: sliderMask
                            anchors.fill: parent
                            source: angleSlider
                            maskSource: mask
                        }

                        MouseArea {
                            id: angleMouseArea
                            anchors.fill: parent
                            // angle : totalAngle  = mouseY : height
                            property int totalAngle: root.angleState ? root.angleStateType.maxValue - root.angleStateType.minValue : 0
                            property int angle: root.angleState ? totalAngle * mouseY / height + root.angleStateType.minValue : 0
                            hoverEnabled: true

                            property int startY: 0

                            onPressed: {
                                startY = mouseY
                                angleMovable.visible = true
                            }
                            onMouseYChanged: if (pressed) angleMovable.angle = angle

                            onReleased: {
                                print("released at", angle)
                                var targetAngle = 0
                                if (Math.abs(mouseY - startY) < 5) {
                                    print("clicked")
                                    // clicked without drag
                                    if (mouseY < width) {
                                        print("top area")
                                        // clicked in top area
                                        if (root.angle > 5) {
                                            targetAngle = 0;
                                        } else {
                                            targetAngle = root.angleStateType.minValue
                                        }
                                    } else if (mouseY > height - width){
                                        print("bottom area")
                                        //clicked in bottom area
                                        if (root.angle < -5) {
                                            targetAngle = 0;
                                        } else {
                                            targetAngle = root.angleStateType.maxValue
                                        }
                                    } else {
                                        targetAngle = angle
                                    }

                                } else {
                                    targetAngle = angle
                                }

                                angleMovable.angle = targetAngle


                                var actionType = root.deviceClass.actionTypes.findByName("angle");
                                var params = [];
                                var percentageParam = {}
                                percentageParam["paramTypeId"] = actionType.paramTypes.findByName("angle").id;
                                percentageParam["value"] = targetAngle
                                params.push(percentageParam);
                                engine.deviceManager.executeAction(root.device.id, actionType.id, params);

                            }
                        }
                    }
                }
            }
        }


        Item {
            id: shutterControlsContainer
            Layout.columnSpan: root.isVenetian && !root.landscape ? 2 : 1
            Layout.fillWidth: true
            Layout.maximumWidth: 500
//            Layout.preferredWidth: root.landscape ? Math.max(parent.width / 2, shutterControls.implicitWidth) : parent.width
            Layout.margins: app.margins * 2
            Layout.alignment: Qt.AlignHCenter
            Layout.fillHeight: true
            property int minimumHeight: app.iconSize * 2.5
            property int minimumWidth: app.iconSize * 2.5 * 3

            ShutterControls {
                id: shutterControls
                device: root.device
                width: parent.width
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                spacing: (width - app.iconSize*2*children.length) / (children.length - 1)

                property int count: children.length

                onActivated: {
                    if (button == "open") {
                        arrowAnimation.state = "opening"
                    } else if (button == "close") {
                        arrowAnimation.state = "closing"
                    } else {
                        arrowAnimation.state = ""
                    }
                }
            }
        }
    }
}

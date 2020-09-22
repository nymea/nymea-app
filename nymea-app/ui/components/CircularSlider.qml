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
import QtQuick.Controls 2.2
import Nymea 1.0
import QtQuick.Layouts 1.2
import QtQuick.Controls.Material 2.2

ColumnLayout {
    id: circularSlider

    property Device device: null
    property StateType stateType: null

    property url backgroundImage: ""
    property url innerBackgroundImage: ""
    property int outerMargin: 1
    property bool handleVisible: true
    property bool showMinLabel: true
    property bool showMaxLabel: true
    property string units: ""
    property string unitLabelColor: "black"
    property string centerValueLabelColor: "black"
    property bool roundValue: false
    property bool circleBorder: false

    property bool showValueLabel: true
    property int steps: 10
    property color color: app.accentColor
    property int maxAngle: 235

    // value : max = angle : maxAngle
    function valueToAngle(value) {
        return (value - from) * maxAngle / (to - from)
    }
    function angleToValue(angle) {
        return (to - from) * angle / maxAngle + from
    }

    readonly property State deviceState: device && stateType ? device.states.getState(stateType.id) : null
    readonly property double from: circularSlider.stateType ? circularSlider.stateType.minValue : 0
    readonly property double to: circularSlider.stateType ? circularSlider.stateType.maxValue : 100
    readonly property double anglePerStep: maxAngle / circularSlider.steps
    readonly property double startAngle: -(circularSlider.steps * circularSlider.anglePerStep) / 2

    readonly property StateType powerStateType: circularSlider.device.deviceClass.stateTypes.findByName("power")
    readonly property State powerState: powerStateType ? circularSlider.device.states.getState(powerStateType.id) : null

    QtObject {
        id: d
        property int pendingActionId: -1
        property real valueCache: 0
        property bool valueCacheDirty: false

        property bool busy: rotateMouseArea.pressed || pendingActionId != -1 || valueCacheDirty

        property color onColor: circularSlider.color
        property color offColor: "transparent"
        property color poweredColor: circularSlider.powerStateType
                                              ? (circularSlider.powerState.value === true ? onColor : offColor)
                                              : onColor


        function enqueueSetValue(value) {
            if (d.pendingActionId == -1) {
                executeAction(value);
                return;
            } else {
                valueCache = value
                valueCacheDirty = true;
            }
        }

        function executeAction(value) {
            var params = []
            var param = {}
            param["paramName"] = circularSlider.stateType.name                        
            param["value"] = circularSlider.roundValue ? Math.round(value / 1000) * 1000 : value
            params.push(param)
            d.pendingActionId = circularSlider.device.executeAction(circularSlider.stateType.name, params)
        }
    }
    Connections {
        target: engine.deviceManager
        onExecuteActionReply: {
            d.pendingActionId = -1
            if (d.valueCacheDirty) {
                d.executeAction(d.valueCache)
                d.valueCacheDirty = false;
            }
        }
    }
    Connections {
        target: circularSlider.device
        onActionExecutionFinished: {
            if (id == d.pendingActionId) {
                d.pendingActionId = -1;
                if (d.valueCacheDirty) {
                    d.executeAction(d.valueCache)
                    d.valueCacheDirty = false;
                }
            }
        }
    }

    Component.onCompleted: rotationButton.rotation = circularSlider.valueToAngle(circularSlider.deviceState.value)
    Connections {
        target: circularSlider.deviceState
        onValueChanged: {
            if (!d.busy) {
                rotationButton.rotation = circularSlider.valueToAngle(circularSlider.deviceState.value)
            }
        }
    }

    Label {
        id: topLabel
        Layout.fillWidth: true
        property var unit: circularSlider.stateType ? circularSlider.stateType.unit : Types.UnitNone
        text: Types.toUiValue(rotateMouseArea.currentValue, unit) + Types.toUiUnit(unit)
        font.pixelSize: app.largeFont * 1.5
        horizontalAlignment: Text.AlignHCenter
        visible: circularSlider.showValueLabel && circularSlider.stateType !== null
    }

    Image {
        id: buttonContainer
        Layout.fillWidth: true
        Layout.fillHeight: true
        fillMode: Image.PreserveAspectFit
        source: circularSlider.backgroundImage

        Item {
            id: innercircularSlider

            height: Math.min(parent.height, parent.width) * circularSlider.outerMargin * .9
            width: height * .9
            anchors.centerIn: parent
            rotation: circularSlider.startAngle

            Image {
                anchors.fill: rotationButton
                opacity: rotateMouseArea.pressed && !rotateMouseArea.grabbed ? .7 : 1
                Layout.fillWidth: true
                Layout.fillHeight: true
                fillMode: Image.PreserveAspectFit
                source: circularSlider.innerBackgroundImage
            }

            Repeater {
                id: indexLEDs
                model: circularSlider.steps

                Item {
                    height: parent.height * .9
                    width: parent.width * .055
                    anchors.centerIn: parent
                    rotation: circularSlider.anglePerStep * index
                    visible: circularSlider.stateType !== null

                    Rectangle {
                        width: parent.width
                        height: width
                        radius: 0
                        color: circularSlider.deviceState && circularSlider.angleToValue(parent.rotation) <= circularSlider.deviceState.value ? d.poweredColor : d.offColor
                        Behavior on color { ColorAnimation { duration: 100 } }
                    }
                }
            }

            Item {
                id: rotationButton
                height: parent.height * .76
                width: height
                anchors.centerIn: parent
                visible: circularSlider.stateType !== null
                Behavior on rotation {
                    NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
                    enabled: !rotateMouseArea.pressed && !d.busy
                }

                Item {
                    id: handle
                    anchors.horizontalCenter: parent.horizontalCenter
                    height: parent.height * .27
                    width: height
                    visible: circularSlider.handleVisible && circularSlider.powerStateType !== null
                    anchors.top: parent.top
                    anchors.topMargin: -parent.height * 0.22

//                    Rectangle { anchors.fill: parent; color: "red"; opacity: .3 }

                    Rectangle {
                        height: parent.height * .4
                        width: height
                        radius: width / 2
                        anchors.top: parent.top
                        anchors.topMargin: height
                        anchors.horizontalCenter: parent.horizontalCenter
                        color: "white"
                        border.color: "black"
                        border.width: 1
                        visible: circularSlider.powerState.value
//                        Behavior on color { ColorAnimation { duration: 200 } }
                    }
                }
            }
        }

        Rectangle {
            id: buttonBorder
            height: innercircularSlider.height
            width: height
            anchors.centerIn: parent
            radius: height / 2
            border.color: app.foregroundColor
            opacity: .3
            border.width: width * .025
            color: "transparent"
            visible: circleBorder
        }

        Label {
            anchors { left: innercircularSlider.left; bottom: innercircularSlider.bottom; bottomMargin: innercircularSlider.height * .1 }
            text: "MIN"
            font.pixelSize: innercircularSlider.height * .06
            visible: circularSlider.stateType !== null && circularSlider.showMinLabel
        }

        Label {
            anchors { right: innercircularSlider.right; bottom: innercircularSlider.bottom; bottomMargin: innercircularSlider.height * .1 }
            text: "MAX"
            font.pixelSize: innercircularSlider.height * .06
            visible: circularSlider.stateType !== null && circularSlider.showMaxLabel
        }

        ColorIcon {
            anchors.centerIn: innercircularSlider
            height: innercircularSlider.height * .2
            width: height
            name: "../images/system-shutdown.svg"
            visible: circularSlider.powerStateType !== null && !circularSlider.powerState.value
            color: d.poweredColor
            Behavior on color { ColorAnimation { duration: 200 } }
        }

        Label {
            id: centerValueLabel
            anchors.centerIn: parent
            text: Math.round(rotateMouseArea.currentValue / 1000)
            color: centerValueLabelColor
            font.pixelSize: innercircularSlider.height * .17
            visible: circularSlider.powerState.value
        }

        Label {
            x: buttonContainer.width / 2 - width / 2
            y: centerValueLabel.y + height * 2
            text: units
            color: unitLabelColor
            font.pixelSize: innercircularSlider.height * .08
            visible: circularSlider.powerState.value
        }

        MouseArea {
            id: rotateMouseArea
            anchors.fill: buttonBorder
            preventStealing: true
            onPressedChanged: PlatformHelper.vibrate(PlatformHelper.HapticsFeedbackImpact)

//            Rectangle { anchors.fill: parent; color: "blue"; opacity: .3}

            property bool grabbed: false
            onPressed: {
                startX = mouseX
                startY = mouseY
                var mappedToHandle = mapToItem(handle, mouseX, mouseY);
                if (mappedToHandle.x >= 0
                        && mappedToHandle.x < handle.width
                        && mappedToHandle.y >= 0
                        && mappedToHandle.y < handle.height
                        ) {
                    grabbed = true;
                    return;
                }
            }
            onCanceled: grabbed = false;

            property bool dragging: false
            onReleased: {
                grabbed = false;
                if (circularSlider.powerStateType && !dragging) {
                    var params = []
                    var param = {}
                    param["paramName"] = "power"
                    param["value"] = !circularSlider.powerState.value
                    params.push(param)
                    circularSlider.device.executeAction("power", params)
                }
                dragging = false;
            }

            readonly property int decimals: circularSlider.stateType && circularSlider.stateType.type.toLowerCase() === "int" ? 0 : 1
            property var currentValue: circularSlider.deviceState ? circularSlider.deviceState.value.toFixed(decimals) : 0
            property date lastVibration: new Date()
            property int startX
            property int startY
            onPositionChanged: {
                if (!circularSlider.powerState.value) {
                    return
                }

                if (Math.abs(mouseX - startX) > 10 || Math.abs(mouseY - startY) > 10) {
                    dragging = true;
                }

                if (!grabbed) {
                    return;
                }
                var angle = calculateAngle(mouseX, mouseY)
                angle = (360 + angle - circularSlider.startAngle) % 360;

                if (angle > 360 - ((360 - circularSlider.maxAngle) / 2)) {
                    angle = 0;
                } else if (angle > circularSlider.maxAngle) {
                    angle = circularSlider.maxAngle
                }

                var newValue = Math.round(circularSlider.angleToValue(angle) * 2) / 2;
                rotationButton.rotation = angle;
                newValue = newValue.toFixed(decimals)

                if (newValue !== currentValue) {
                    currentValue = newValue;
                    if (newValue <= circularSlider.stateType.minValue || newValue >= circularSlider.stateType.maxValue) {
                        PlatformHelper.vibrate(PlatformHelper.HapticsFeedbackImpact)
                    } else {
                        if (lastVibration.getTime() + 35 < new Date()) {
                            PlatformHelper.vibrate(PlatformHelper.HapticsFeedbackSelection)
                        }
                        lastVibration = new Date()
                    }

                    d.enqueueSetValue(newValue);
                }
            }

            function calculateAngle(mouseX, mouseY) {
                // transform coords to center of circularSlider
                mouseX -= innercircularSlider.width / 2
                mouseY -= innercircularSlider.height / 2

                var rad = Math.atan(mouseY / mouseX);
                var angle = rad * 180 / Math.PI

                angle += 90;

                if (mouseX < 0 && mouseY >= 0) angle = 180 + angle;
                if (mouseX < 0 && mouseY < 0) angle = 180 + angle;

                return angle;
            }
        }
    }
}

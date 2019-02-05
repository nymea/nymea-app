import QtQuick 2.5
import QtQuick.Controls 2.2
import Nymea 1.0
import QtQuick.Layouts 1.2
import QtQuick.Controls.Material 2.2

ColumnLayout {
    id: dial

    property Device device: null
    property StateType stateType: null

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
    readonly property double from: dial.stateType.minValue
    readonly property double to: dial.stateType.maxValue
    readonly property double anglePerStep: maxAngle / dial.steps
    readonly property double startAngle: -(dial.steps * dial.anglePerStep) / 2

    readonly property StateType powerStateType: dial.device.deviceClass.stateTypes.findByName("power")
    readonly property State powerState: powerStateType ? dial.device.states.getState(powerStateType.id) : null

    QtObject {
        id: d
        property int pendingActionId: -1
        property real valueCache: 0
        property bool valueCacheDirty: false

        property bool busy: rotateMouseArea.pressed || pendingActionId != -1 || valueCacheDirty

        property color onColor: dial.color
        property color offColor: "#808080"
        property color poweredColor: dial.powerStateType
                                              ? (dial.powerState.value === true ? onColor : offColor)
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
            param["paramTypeId"] = dial.stateType.id
            param["value"] = value
            params.push(param)
            d.pendingActionId = engine.deviceManager.executeAction(dial.device.id, dial.stateType.id, params)
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

    Component.onCompleted: rotationButton.rotation = dial.valueToAngle(dial.deviceState.value)
    Connections {
        target: dial.deviceState
        onValueChanged: {
            if (!d.busy) {
                rotationButton.rotation = dial.valueToAngle(dial.deviceState.value)
            }
        }
    }

    Label {
        id: topLabel
        Layout.fillWidth: true
        text: rotateMouseArea.currentValue + dial.stateType.unitString
        font.pixelSize: app.largeFont * 1.5
        horizontalAlignment: Text.AlignHCenter
        visible: dial.showValueLabel && dial.stateType !== null
    }

    Item {
        id: buttonContainer
        Layout.fillWidth: true
        Layout.fillHeight: true


        Item {
            id: innerDial

            height: Math.min(parent.height, parent.width) * .9
            width: height
            anchors.centerIn: parent
            rotation: dial.startAngle


            Rectangle {
                anchors.fill: rotationButton
                radius: height / 2
                border.color: app.foregroundColor
                border.width: 2
                color: "transparent"
                opacity: rotateMouseArea.pressed && !rotateMouseArea.grabbed ? .7 : 1
            }

            Item {
                id: rotationButton
                height: parent.height * .75
                width: height
                anchors.centerIn: parent
                visible: dial.stateType !== null
                Behavior on rotation {
                    NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
                    enabled: !rotateMouseArea.pressed && !d.busy
                }

                Item {
                    id: handle
                    anchors.horizontalCenter: parent.horizontalCenter
                    height: parent.height * .35
                    width: height

//                    Rectangle { anchors.fill: parent; color: "red"; opacity: .3}

                    Rectangle {
                        height: parent.height * .5
                        width: innerDial.width * 0.02
                        radius: width / 2
                        anchors.top: parent.top
                        anchors.topMargin: height * .25
                        anchors.horizontalCenter: parent.horizontalCenter
                        color: d.poweredColor
                        Behavior on color { ColorAnimation { duration: 200 } }
                    }
                }
            }

            Repeater {
                id: indexLEDs
                model: dial.steps + 1

                Item {
                    height: parent.height
                    width: parent.width * .04
                    anchors.centerIn: parent
                    rotation: dial.anglePerStep * index
                    visible: dial.stateType !== null

                    Rectangle {
                        width: parent.width
                        height: width
                        radius: width / 2
                        color: dial.angleToValue(parent.rotation) <= dial.deviceState.value ? d.poweredColor : d.offColor
                        Behavior on color { ColorAnimation { duration: 200 } }
                    }
                }
            }
        }

        Rectangle {
            id: buttonBorder
            height: innerDial.height * .8
            width: height
            anchors.centerIn: parent
            radius: height / 2
            border.color: app.foregroundColor
            opacity: .3
            border.width: width * .025
            color: "transparent"
        }

        Label {
            anchors { left: innerDial.left; bottom: innerDial.bottom; bottomMargin: innerDial.height * .1 }
            text: "MIN"
            font.pixelSize: innerDial.height * .06
            visible: dial.stateType !== null
        }

        Label {
            anchors { right: innerDial.right; bottom: innerDial.bottom; bottomMargin: innerDial.height * .1 }
            text: "MAX"
            font.pixelSize: innerDial.height * .06
            visible: dial.stateType !== null
        }

        ColorIcon {
            anchors.centerIn: innerDial
            height: innerDial.height * .2
            width: height
            name: "../images/system-shutdown.svg"
            visible: dial.powerStateType !== null
            color: d.poweredColor
            Behavior on color { ColorAnimation { duration: 200 } }
        }

        MouseArea {
            id: rotateMouseArea
            anchors.fill: buttonBorder
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
                if (dial.powerStateType && !dragging) {
                    var params = []
                    var param = {}
                    param["paramTypeId"] = dial.powerStateType.id
                    param["value"] = !dial.powerState.value
                    params.push(param)
                    engine.deviceManager.executeAction(dial.device.id, dial.powerStateType.id, params)
                }
                dragging = false;
            }

            readonly property int decimals: dial.stateType.type.toLowerCase() === "int" ? 0 : 1
            property var currentValue: dial.deviceState.value.toFixed(decimals)
            property date lastVibration: new Date()
            property int startX
            property int startY
            onPositionChanged: {
                if (Math.abs(mouseX - startX) > 10 || Math.abs(mouseY - startY) > 10) {
                    dragging = true;
                }

                if (!grabbed) {
                    return;
                }
                var angle = calculateAngle(mouseX, mouseY)
                angle = (360 + angle - dial.startAngle) % 360;

                if (angle > 360 - ((360 - dial.maxAngle) / 2)) {
                    angle = 0;
                } else if (angle > dial.maxAngle) {
                    angle = dial.maxAngle
                }

                var newValue = Math.round(dial.angleToValue(angle) * 2) / 2;
                rotationButton.rotation = angle;
                newValue = newValue.toFixed(decimals)

                if (newValue != currentValue) {
                    currentValue = newValue;
                    if (newValue <= dial.stateType.minValue || newValue >= dial.stateType.maxValue) {
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
                // transform coords to center of dial
                mouseX -= innerDial.width / 2
                mouseY -= innerDial.height / 2

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

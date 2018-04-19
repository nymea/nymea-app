import QtQuick 2.5
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.1
import QtQuick.Controls.Material 2.1
import Mea 1.0
import "../components"

DevicePageBase {
    id: root

    ColumnLayout {
        anchors.fill: parent

        RowLayout {
            id: powerRow
            Layout.fillWidth: true
            Layout.margins: app.margins
            spacing: app.margins

            property var powerStateType: root.deviceClass.stateTypes.findByName("power")
            property var powerState: root.device.states.getState(powerStateType.id)

            property var brightnessStateType: root.deviceClass.stateTypes.findByName("brightness")
            property var brightnessState: root.device.states.getState(brightnessStateType.id)

            AbstractButton {
                width: app.iconSize * 2
                height: width
                ColorIcon {
                    anchors.fill: parent
                    name: "../images/torch-off.svg"
                    color: powerRow.powerState.value === true ? keyColor : app.guhAccent
                }
                onClicked: {
                    var actionType = root.deviceClass.actionTypes.findByName("power");
                    var params = []
                    var param = {}
                    param["paramTypeId"] = actionType.paramTypes.get(0).id;
                    param["value"] = false;
                    params.push(param)
                    Engine.deviceManager.executeAction(root.device.id, powerRow.powerStateType.id, params);
                }
            }

            ThrottledSlider {
                id: brightnessSlider
                Layout.fillWidth: true
                value: powerRow.brightnessState.value
                onMoved: {
                    var actionType = root.deviceClass.actionTypes.findByName("brightness");
                    var params = []
                    var param = {}
                    param["paramTypeId"] = actionType.paramTypes.get(0).id;
                    param["value"] = value;
                    params.push(param)
                    Engine.deviceManager.executeAction(root.device.id, powerRow.brightnessStateType.id, params);
                }
            }

            AbstractButton {
                width: app.iconSize * 2
                height: width
                ColorIcon {
                    anchors.fill: parent
                    name: "../images/torch-on.svg"
                    color: powerRow.powerState.value === true ? app.guhAccent : keyColor
                }
                onClicked: {
                    var actionType = root.deviceClass.actionTypes.findByName("power");
                    var params = []
                    var param = {}
                    param["paramTypeId"] = actionType.paramTypes.get(0).id;
                    param["value"] = true;
                    params.push(param)
                    Engine.deviceManager.executeAction(root.device.id, powerRow.powerStateType.id, params);
                }
            }
        }









        ColorPickerCt {
            id: pickerCt
            Layout.fillWidth: true
            Layout.margins: app.margins
            property var actionType: root.deviceClass.actionTypes.findByName("colorTemperature")
            property var ctState: actionType ? root.device.states.getState(actionType.id) : null
            ct: ctState ? ctState.value : 0
            visible: root.deviceClass.interfaces.indexOf("colorlight") >= 0

            height: 80

            touchDelegate: Rectangle {
                height: pickerCt.height
                width: 5
                color: "black"
            }

            property var lastSentTime: new Date()
            onCtChanged: {
                var currentTime = new Date();
                if (pressed && currentTime - lastSentTime > 200) {
                    setColorTemp(ct)
                    lastSentTime = currentTime
                }
            }

            function setColorTemp(ct) {
                var actionType = root.deviceClass.actionTypes.findByName("colorTemperature");
                var params = []
                var param = {}
                param["paramTypeId"] = actionType.paramTypes.get(0).id;
                param["value"] = ct;
                params.push(param)
                Engine.deviceManager.executeAction(root.device.id, actionType.id, params);
            }

        }

        ColorPicker {
            id: colorPicker
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.margins: app.margins
            property var actionType: root.deviceClass.actionTypes.findByName("color")
            property var actionState: actionType ? root.device.states.getState(actionType.id).value : null
            visible: root.deviceClass.interfaces.indexOf("colorlight") >= 0

            color: actionState ? actionState : "white"
            touchDelegate: Rectangle {
                height: 15
                width: height
                radius: height / 2
                color: Material.accent

                Rectangle {
                    color: colorPicker.hovered || colorPicker.pressed ? "#11000000" : "transparent"
                    anchors.centerIn: parent
                    height: 30
                    width: height
                    radius: width / 2
                    Behavior on color {
                        ColorAnimation {
                            duration: 200
                        }
                    }
                }
            }

            property var lastSentTime: new Date()
            onColorChanged: {
                var currentTime = new Date();
                if (pressed && currentTime - lastSentTime > 200) {
                    var params = [];
                    var param1 = new Object();
                    param1["paramTypeId"] = actionType.paramTypes.get(0).id;
                    param1["value"] = color;
                    params.push(param1)
                    Engine.deviceManager.executeAction(root.device.id, actionType.id, params)
                    lastSentTime = currentTime
                }
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.preferredHeight: 0
        }
    }
}

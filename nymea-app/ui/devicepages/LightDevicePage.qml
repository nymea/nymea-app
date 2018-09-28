import QtQuick 2.5
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.1
import QtQuick.Controls.Material 2.1
import Nymea 1.0
import "../components"

DevicePageBase {
    id: root

    readonly property var powerStateType: deviceClass.stateTypes.findByName("power")
    readonly property var powerState: device.states.getState(powerStateType.id)
    readonly property var powerActionType: deviceClass.actionTypes.findByName("power");

    readonly property var brightnessStateType: deviceClass.stateTypes.findByName("brightness")
    readonly property var brightnessState: brightnessStateType ? device.states.getState(brightnessStateType.id) : null
    readonly property var brightnessActionType: deviceClass.actionTypes.findByName("brightness");

    readonly property var colorStateType: deviceClass.stateTypes.findByName("color")
    readonly property var colorState: colorStateType ? device.states.getState(colorStateType.id) : null
    readonly property var colorActionType: deviceClass.actionTypes.findByName("color")

    readonly property var ctStateType: deviceClass.stateTypes.findByName("colorTemperature")
    readonly property var ctState: ctStateType ? device.states.getState(ctStateType.id) : null
    readonly property var ctActionType: deviceClass.actionTypes.findByName("colorTemperature")


    GridLayout {
        anchors.fill: parent
        columns: app.landscape ? 2 : 1

        AbstractButton {
            Layout.preferredWidth: app.iconSize * 4
            Layout.preferredHeight: width
            Layout.leftMargin: app.margins
            Layout.rightMargin: app.landscape ? 0 : app.margins
            Layout.topMargin: app.margins
            Layout.bottomMargin: app.landscape ? app.margins : 0
            Layout.alignment: Qt.AlignCenter

            ColorIcon {
                anchors.fill: parent
                name: root.powerState.value === true ? "../images/light-on.svg" : "../images/light-off.svg"
                color: root.powerState.value === true ? app.accentColor : keyColor
            }
            onClicked: {
                var params = []
                var param = {}
                param["paramTypeId"] = root.powerActionType.paramTypes.get(0).id;
                param["value"] = !root.powerState.value;
                params.push(param)
                Engine.deviceManager.executeAction(root.device.id, root.powerStateType.id, params);
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            visible: root.brightnessStateType

            BrightnessSlider {
                Layout.fillWidth: true
                Layout.margins: app.margins
                Layout.preferredHeight: 40
                brightness: root.brightnessState ? root.brightnessState.value : 0
                visible: root.brightnessStateType
                onMoved: {
                    var params = []
                    var param = {}
                    param["paramTypeId"] = root.brightnessActionType.paramTypes.get(0).id;
                    param["value"] = brightness;
                    params.push(param)
                    Engine.deviceManager.executeAction(root.device.id, root.brightnessActionType.id, params);
                }
            }

            ColorPickerCt {
                id: pickerCt
                Layout.fillWidth: true
                Layout.preferredHeight: 40
                Layout.margins: app.margins
                ct: root.ctState ? root.ctState.value : 0
                visible: root.ctStateType
                minCt: root.ctActionType ? root.ctActionType.paramTypes.findByName("colorTemperature").minValue : 0
                maxCt: root.ctActionType ? root.ctActionType.paramTypes.findByName("colorTemperature").maxValue : 0


                touchDelegate: Rectangle {
                    height: pickerCt.height
                    width: 5
                    color: app.foregroundColor
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
                    var params = []
                    var param = {}
                    param["paramTypeId"] = root.ctActionType.paramTypes.get(0).id;
                    param["value"] = ct;
                    params.push(param)
                    Engine.deviceManager.executeAction(root.device.id, root.ctActionType.id, params);
                }
            }
            ColorPicker {
                id: colorPicker
                Layout.fillWidth: true
                Layout.preferredHeight: 80
                Layout.margins: app.margins
                visible: root.colorStateType

                color: root.colorState ? root.colorState.value : "white"
                touchDelegate: Rectangle {
                    height: 15
                    width: height
                    radius: height / 2
                    color: app.foregroundColor

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
                        var param1 = {};
                        param1["paramTypeId"] = root.colorActionType.paramTypes.get(0).id;
                        param1["value"] = color;
                        params.push(param1)
                        Engine.deviceManager.executeAction(root.device.id, root.colorActionType.id, params)
                        lastSentTime = currentTime
                    }
                }
            }
        }
    }
}

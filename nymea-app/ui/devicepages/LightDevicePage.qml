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
        anchors.margins: app.margins
        columns: app.landscape ? 2 : 1
        rowSpacing: app.margins
        columnSpacing: app.margins
        Layout.alignment: Qt.AlignCenter

        Item {
            Layout.preferredWidth: Math.max(app.iconSize * 4, parent.width / 5)
            Layout.preferredHeight: width
            Layout.topMargin: app.margins
            Layout.bottomMargin: app.landscape ? app.margins : 0
            Layout.alignment: Qt.AlignCenter
            Layout.rowSpan: app.landscape ? 4 : 1
            Layout.fillHeight: true

            AbstractButton {
                height: Math.min(parent.height, parent.width)
                width: height
                anchors.centerIn: parent
                Rectangle {
                    anchors.fill: parent
                    color: "white"
                    border.color: root.powerState.value === true ? app.accentColor : bulbIcon.keyColor
                    border.width: 4
                    radius: width / 2
                }

                ColorIcon {
                    id: bulbIcon
                    anchors.fill: parent
                    anchors.margins: app.margins * 1.5
                    name: root.powerState.value === true ? "../images/light-on.svg" : "../images/light-off.svg"
                    color: root.powerState.value === true ? app.accentColor : keyColor
                }
                onClicked: {
                    var params = []
                    var param = {}
                    param["paramTypeId"] = root.powerActionType.paramTypes.get(0).id;
                    param["value"] = !root.powerState.value;
                    params.push(param)
                    engine.deviceManager.executeAction(root.device.id, root.powerStateType.id, params);
                }
            }
        }


        RowLayout {
            Layout.fillHeight: true
            spacing: app.margins
            Layout.alignment: Qt.AlignHCenter
            visible: root.ctStateType !== null

            Repeater {
                model: ListModel {
                    ListElement { name: "activate"; ct: "0"; bri: 100 }
                    ListElement { name: "concentrate"; ct: "23"; bri: 100 }
                    ListElement { name: "reading"; ct: "57"; bri: 100 }
                    ListElement { name: "relax"; ct: "95" ; bri: 55}
                }
                delegate: Pane {
                    Layout.fillWidth: true
                    Layout.preferredHeight: Math.max(20, width)
                    Material.elevation: 1
                    //                        Layout.maximumWidth: app.iconSize * 2
                    padding: 0
                    Image {
                        source: "../images/lighting/" + model.name + ".svg"
                        anchors.fill: parent
                        ItemDelegate {
                            anchors.fill: parent
                            onClicked: {
                                // Translate from % to absolute value in min/max
                                // % : 100 = abs : (max - min)
                                print("min,max", root.ctStateType, root.ctStateType.minValue, root.ctStateType.maxValue)
                                var absoluteCtValue = (model.ct * (root.ctStateType.maxValue - root.ctStateType.minValue) / 100) + root.ctStateType.minValue
                                var params = [];
                                var param1 = {};
                                param1["paramTypeId"] = root.ctActionType.paramTypes.get(0).id;
                                param1["value"] = absoluteCtValue;
                                params.push(param1)
                                engine.deviceManager.executeAction(root.device.id, root.ctActionType.id, params)
                                params = [];
                                param1 = {};
                                param1["paramTypeId"] = root.brightnessActionType.paramTypes.get(0).id;
                                param1["value"] = model.bri;
                                params.push(param1)
                                engine.deviceManager.executeAction(root.device.id, root.brightnessActionType.id, params)
                            }
                        }
                    }
                }
            }
        }

        Rectangle {
            color: "blue"
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumHeight: 20
            Layout.preferredHeight: 20
            visible: root.brightnessStateType

            Pane {
                anchors { left: parent.left; right: parent.right; verticalCenter: parent.verticalCenter }
                height: parent.height
                Material.elevation: 1
                padding: 0

                BrightnessSlider {
                    anchors.fill: parent
                    brightness: root.brightnessState ? root.brightnessState.value : 0
                    onMoved: {
                        var params = []
                        var param = {}
                        param["paramTypeId"] = root.brightnessActionType.paramTypes.get(0).id;
                        param["value"] = brightness;
                        params.push(param)
                        engine.deviceManager.executeAction(root.device.id, root.brightnessActionType.id, params);
                    }
                }
            }
        }


        Rectangle {
            color: "red"
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumHeight: 20
            Layout.preferredHeight: 20
            visible: root.ctStateType

            Pane {
                anchors { left: parent.left; right: parent.right; verticalCenter: parent.verticalCenter }
                height: parent.height
                Material.elevation: 1
                padding: 0

                ColorPickerCt {
                    id: pickerCt
                    anchors.fill: parent
                    ct: root.ctState ? root.ctState.value : 0
                    minCt: root.ctActionType ? root.ctStateType.minValue : 0
                    maxCt: root.ctActionType ? root.ctStateType.maxValue : 0


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
                        engine.deviceManager.executeAction(root.device.id, root.ctActionType.id, params);
                    }
                }
            }
        }

        Rectangle {
            color: "green"
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumHeight: 80
            Layout.preferredHeight: 80
            visible: root.colorStateType

            Pane {
                anchors { left: parent.left; right: parent.right; verticalCenter: parent.verticalCenter }
                height: parent.height
                Material.elevation: 1
                padding: 0

                ColorPicker {
                    id: colorPicker
                    anchors.fill: parent

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
                            engine.deviceManager.executeAction(root.device.id, root.colorActionType.id, params)
                            lastSentTime = currentTime
                        }
                    }
                }
            }
        }

    }
}

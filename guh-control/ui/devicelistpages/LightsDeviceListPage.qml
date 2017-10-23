import QtQuick 2.5
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.1
import Guh 1.0
import "../components"

Page {
    property alias filterInterface: devicesProxy.filterInterface
    header: GuhHeader {
        text: "Lights"
        onBackPressed: pageStack.pop()
    }
    ColumnLayout {
        anchors.fill: parent
        RowLayout {
            Layout.fillWidth: true
            Layout.margins: 10
            Label {
                text: "All"
                Layout.fillWidth: true
            }
            Button {
                text: "off"
                onClicked: {
                    for (var i = 0; i < devicesProxy.count; i++) {
                        var device = devicesProxy.get(i);
                        var deviceClass = Engine.deviceManager.deviceClasses.getDeviceClass(device.deviceClassId);
                        var actionType = deviceClass.actionTypes.findByName("power");

                        var params = [];
                        var param1 = {};
                        param1["paramTypeId"] = actionType.paramTypes.get(0).id;
                        param1["value"] = checked;
                        params.push(param1)
                        Engine.deviceManager.executeAction(device.id, actionType.id, params)
                    }
                }
            }
        }

        ListView {
            Layout.fillHeight: true
            Layout.fillWidth: true
            model: DevicesProxy {
                id: devicesProxy
                devices: Engine.deviceManager.devices
            }

            delegate: ItemDelegate {
                width: parent.width
                height: childrenRect.height
                property var device: devicesProxy.get(index);
                property var deviceClass: Engine.deviceManager.deviceClasses.getDeviceClass(device.deviceClassId);

                ColumnLayout {
                    anchors { left: parent.left; right: parent.right; top: parent.top }
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.margins: 10
                        Label {
                            Layout.fillWidth: true
                            text: model.name
                            verticalAlignment: Text.AlignVCenter
                        }
                        Slider {
                            visible: model.interfaces.indexOf("dimmablelight") >= 0
                            property var stateType: deviceClass.stateTypes.findByName("brightness");
                            property var actionType: deviceClass.actionTypes.findByName("brightness");
                            property var actionState: device.states.getState(stateType.id)
                            from: 0; to: 100
                            value: actionState.value
                            onValueChanged: {
                                if (pressed) {
                                    var params = [];
                                    var param1 = {};
                                    param1["paramTypeId"] = actionType.paramTypes.get(0).id;
                                    param1["value"] = value;
                                    params.push(param1)
                                    Engine.deviceManager.executeAction(device.id, actionType.id, params)
                                }
                            }
                        }
                        Switch {
                            property var stateType: deviceClass.stateTypes.findByName("power");
                            property var actionType: deviceClass.actionTypes.findByName("power");
                            property var actionState: device.states.getState(stateType.id)
                            checked: actionState.value === true
                            onClicked: {
                                var params = [];
                                var param1 = {};
                                param1["paramTypeId"] = actionType.paramTypes.get(0).id;
                                param1["value"] = checked;
                                params.push(param1)
                                Engine.deviceManager.executeAction(device.id, actionType.id, params)
                            }

                        }
                    }
                }


                onClicked: {
                    pageStack.push(Qt.resolvedUrl("../devicepages/GenericDevicePage.qml"), {device: devicesProxy.get(index)})
                }
            }

        }
    }
}

import QtQuick 2.5
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.2
import QtQuick.Layouts 1.1
import Mea 1.0
import "../components"
import "../customviews"

DevicePageBase {
    id: root

    readonly property bool landscape: width > height
    readonly property var openState: device.states.getState(deviceClass.stateTypes.findByName("state").id)
    readonly property var intermediatePositionState: device.states.getState(deviceClass.stateTypes.findByName("intermediatePosition").id)
    readonly property var lightStateType: deviceClass.stateTypes.findByName("power")
    readonly property var lightState: lightStateType ? device.states.getState(lightStateType.id) : null

    GridLayout {
        anchors.fill: parent
        columns: root.landscape ? 2 : 1

        ColorIcon {
            id: shutterImage
            Layout.preferredWidth: root.landscape ? height : parent.width
            Layout.preferredHeight: root.landscape ? parent.height : width
            property int currentImage: 0
            name: "../images/shutter-" + currentImage + ".svg"
            Component.onCompleted: update()

            function update() {
                switch (root.openState.value) {
                case "open":
                    if (root.intermediatePositionState.value === true) {
                        shutterImage.currentImage = 5;
                    } else {
                        shutterImage.currentImage = 0;
                    }
                    break;
                case "closed":
                    if (root.intermediatePositionState.value === true) {
                        shutterImage.currentImage = 5;
                    } else {
                        shutterImage.currentImage = 10;
                    }
                }
                print("shutter is now:", shutterImage.currentImage, root.intermediatePositionState.value)
            }

            Connections {
                target: root.openState
                onValueChanged: shutterImage.update();
            }
            Connections {
                target: root.intermediatePositionState
                onValueChanged: shutterImage.update();
            }

            Timer {
                running: root.openState.value === "closing" || root.openState.value === "opening"
                interval: 500
                repeat: true
                onTriggered: {
                    var value = shutterImage.currentImage;
                    if (root.openState.value === "opening") {
                        value--;
                    } else if (root.openState.value === "closing") {
                        value++;
                    }
                    if (value > 10) value = 0;
                    if (value < 0) value = 10;
                    shutterImage.currentImage = value;
                }
            }
        }

        Item {
            Layout.preferredWidth: root.landscape ? parent.width / 2 : parent.width
            Layout.fillHeight: true
            Layout.minimumHeight: app.iconSize * 2.5

            ShutterControls {
                device: root.device
                anchors.centerIn: parent

                Rectangle {
                    Layout.preferredWidth: app.iconSize * 2
                    Layout.preferredHeight: width
                    color: root.lightState && root.lightState.value === true ? Material.accent : Material.foreground
                    radius: height / 2
                    visible: root.lightStateType !== null

                    ColorIcon {
                        anchors.fill: parent
                        anchors.margins: app.margins
                        name: "../images/torch-" + (root.lightState && root.lightState.value === true ? "on" : "off") + ".svg"
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            print("blabla", root.lightState, root.lightState.value, root.lightStateType.name, root.lightState.stateTypeId, root.lightStateType.id)
                            var params = [];
                            var param = {};
                            param["paramTypeId"] = root.lightStateType.id;
                            param["value"] = !root.lightState.value;
                            params.push(param)
                            Engine.deviceManager.executeAction(root.device.id, root.lightStateType.id, params)
                        }
                    }
                }
            }
        }
    }
}

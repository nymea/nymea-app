import QtQuick 2.5
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.2
import QtQuick.Layouts 1.1
import Nymea 1.0
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
            Layout.preferredWidth: root.landscape ? Math.min(parent.width - shutterControlsContainer.width, parent.height) - app.margins : parent.width
            Layout.preferredHeight: width
            property string currentImage: root.openState.value === "closed" ? "100" :
                                    root.openState.value === "open" && root.intermediatePositionState.value === false ? "000" : "050"
            name: "../images/shutter/shutter-" + currentImage + ".svg"

            Item {
                id: arrows
                anchors.centerIn: parent
                width: app.iconSize * 2
                height: parent.height * .6
                clip: true
                visible: root.openState.value === "opening" || root.openState.value === "closing"
                property bool up: root.openState.value === "opening"

                // NumberAnimation doesn't reload to/from while it's running. If we switch from closing to opening or vice versa
                // we need to somehow stop and start the animation
                property bool animationHack: true
                onAnimationHackChanged: {
                    if (!animationHack) hackTimer.start();
                }
                Timer { id: hackTimer; interval: 1; onTriggered: arrows.animationHack = true }
                Connections { target: root.openState; onValueChanged: arrows.animationHack = false }

                NumberAnimation {
                    target: arrowColumn
                    property: "y"
                    duration: 500
                    easing.type: Easing.Linear
                    from: arrows.up ? app.iconSize : -app.iconSize
                    to: arrows.up ? -app.iconSize : app.iconSize
                    loops: Animation.Infinite
                    running: arrows.animationHack && (root.openState.value === "opening" || root.openState.value === "closing")
                }

                Column {
                    id: arrowColumn
                    width: parent.width

                    Repeater {
                        model: arrows.height / app.iconSize + 1
                        ColorIcon {
                            name: arrows.up ? "../images/up.svg" : "../images/down.svg"
                            width: parent.width
                            height: width
                            color: app.guhAccent
                        }
                    }
                }
            }
        }

        Item {
            id: shutterControlsContainer
            Layout.preferredWidth: root.landscape ? Math.max(parent.width / 2, shutterControls.implicitWidth) : parent.width
            Layout.minimumWidth: shutterControls.implicitWidth
            Layout.fillHeight: true
            Layout.minimumHeight: app.iconSize * 2.5

            ShutterControls {
                id: shutterControls
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

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
    readonly property bool isExtended: deviceClass.interfaces.indexOf("extendedclosable") >= 0
    readonly property var percentageState: isExtended ? device.states.getState(deviceClass.stateTypes.findByName("percentage").id) : 0
    readonly property var movingState: isExtended ? device.states.getState(deviceClass.stateTypes.findByName("moving").id) : 0

    GridLayout {
        anchors.fill: parent
        columns: root.landscape ? 2 : 1

        ColorIcon {
            id: shutterImage
            Layout.preferredWidth: root.landscape ? Math.min(parent.width - shutterControlsContainer.width, parent.height) - app.margins : parent.width
            Layout.preferredHeight: width
            name: "../images/shutter/shutter-" + app.pad(isExtended ? Math.round(root.percentageState.value / 10) * 10 : 50, 3) + ".svg"

            ClosableArrowAnimation {
                id: arrowAnimation
                anchors.centerIn: parent

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

        Item {
            id: shutterControlsContainer
            Layout.preferredWidth: root.landscape ? Math.max(parent.width / 2, shutterControls.implicitWidth) : parent.width
            Layout.minimumWidth: shutterControls.implicitWidth
            Layout.fillHeight: true
            Layout.minimumHeight: app.iconSize * 2.5

            Column {
                anchors.centerIn: parent
                width: parent.width - app.margins * 2
                spacing: app.margins

                Slider {
                    id: percentageSlider
                    width: parent.width
                    from: 0
                    to: 100
                    stepSize: 1
                    visible: isExtended

                    Binding {
                        target: percentageSlider
                        property: "value"
                        value: root.percentageState.value
                        when: root.movingState.value === false
                    }

                    onPressedChanged: {
                        if (pressed) {
                            return;
                        }

                        var actionType = root.deviceClass.actionTypes.findByName("percentage");
                        var params = [];
                        var percentageParam = {}
                        percentageParam["paramTypeId"] = actionType.paramTypes.findByName("percentage").id;
                        percentageParam["value"] = value
                        params.push(percentageParam);
                        engine.deviceManager.executeAction(root.device.id, actionType.id, params);
                    }
                }

                ShutterControls {
                    id: shutterControls
                    device: root.device
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: (parent.width - app.iconSize*2*children.length) / (children.length - 1)
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
}

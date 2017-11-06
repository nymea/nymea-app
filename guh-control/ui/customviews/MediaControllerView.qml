import QtQuick 2.5
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.1
import Guh 1.0
import "../components"

CustomViewBase {
    id: root
    height: column.implicitHeight + app.margins * 2

    function executeAction(actionName) {
        var actionTypeId = deviceClass.actionTypes.findByName(actionName).id;
        print("executing", device, device.id, actionTypeId, actionName, deviceClass.actionTypes)
        Engine.deviceManager.executeAction(device.id, actionTypeId)
    }

    property var playbackState: device.states.getState(deviceClass.stateTypes.findByName("playbackStatus").id)

    ColumnLayout {
        id: column
        anchors { left: parent.left; right: parent.right }

        RowLayout {
            Layout.fillWidth: true

            Item { Layout.fillWidth: true; height: 1 }

            property int iconSize: Math.min(root.width / 6, app.iconSize * 2)

            AbstractButton {
                Layout.fillWidth: true
                height: Math.min(app.iconSize * 2)
                ColorIcon {
                    height: parent.height
                    width: height
                    name: "../images/media-skip-backward.svg"
                }
                onClicked: {
                    executeAction("skipBack")
                }
            }
            AbstractButton {
                Layout.fillWidth: true
                height: Math.min(app.iconSize * 2)
                ColorIcon {
                    height: parent.height
                    width: height
                    name: "../images/media-seek-backward.svg"
                }
                onClicked: {
                    executeAction("rewind")
                }
            }
            AbstractButton {
                Layout.fillWidth: true
                height: Math.min(app.iconSize * 2)
                ColorIcon {
                    height: parent.height
                    width: height
                    name: "../images/media-playback-stop.svg"
                }
                onClicked: {
                    executeAction("stop")
                }
            }
            AbstractButton {
                Layout.fillWidth: true
                height: Math.min(app.iconSize * 2)
                ColorIcon {
                    height: parent.height
                    width: height
                    name: "../images/media-playback-start.svg"
                }
                visible: playbackState.value == "PAUSED" || playbackState.value == "STOPPED"
                onClicked: {
                    executeAction("play")
                }
            }
            AbstractButton {
                Layout.fillWidth: true
                height: Math.min(app.iconSize * 2)
                ColorIcon {
                    height: parent.height
                    width: height
                    name: "../images/media-playback-pause.svg"
                }
                visible: playbackState.value == "PLAYING"
                onClicked: {
                    executeAction("pause")
                }
            }

            AbstractButton {
                Layout.fillWidth: true
                height: Math.min(app.iconSize * 2)
                ColorIcon {
                    height: parent.height
                    width: height
                    name: "../images/media-seek-forward.svg"
                }
                onClicked: {
                    executeAction("fastForward")
                }
            }
            AbstractButton {
                Layout.fillWidth: true
                height: Math.min(app.iconSize * 2)
                ColorIcon {
                    height: parent.height
                    width: height
                    name: "../images/media-skip-forward.svg"
                }
                onClicked: {
                    executeAction("skipNext")
                }
            }
            Item { Layout.fillWidth: true; height: 1 }

        }
    }
}

import QtQuick 2.5
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.1
import Mea 1.0
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
    property var playbackStateValue: playbackState.value
    onPlaybackStateValueChanged: populateControls()
    Component.onCompleted: populateControls()

    function populateControls() {
        print("generating controls")
        controlsModel.clear();
        controlsModel.append({image: "../images/media-skip-backward.svg", action: "skipBack"})
        controlsModel.append({image: "../images/media-seek-backward.svg", action: "rewind"})
        controlsModel.append({image: "../images/media-playback-stop.svg", action: "stop"})
        if (playbackState.value === "PAUSED" || playbackState.value === "STOPPED") {
            controlsModel.append({image: "../images/media-playback-start.svg", action: "play"})
        }
        if (playbackState.value === "PLAYING") {
            controlsModel.append({image: "../images/media-playback-pause.svg", action: "pause"})
        }

        controlsModel.append({image: "../images/media-seek-forward.svg", action: "fastForward"})
        controlsModel.append({image: "../images/media-skip-forward.svg", action: "skipNext"})
    }

    ColumnLayout {
        id: column
        anchors { left: parent.left; right: parent.right }

        Row {
            id: controlsRow
            Layout.fillWidth: true

            property int iconSize: Math.max(app.iconSize * 2, column.width / (controlsModel.count + 0))

//            Item {
//                width: Math.max(app.iconSize * 2, column.width / (controlsModel.count + 2))
//                height: 1
//            }


            Repeater {
                model: ListModel {
                    id: controlsModel
                }
                delegate: AbstractButton {

                    height: app.iconSize * 2
                    width: controlsRow.iconSize
                    ColorIcon {
                        height: parent.height
                        width: height
                        name: model.image
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                    onClicked: {
                        executeAction(model.action)
                    }
                }
            }

//            Item { Layout.fillWidth: true; height: 1 }

        }
    }
}

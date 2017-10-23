import QtQuick 2.5
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.1
import Guh 1.0

CustomViewBase {
    id: root
    height: column.implicitHeight + app.margins * 2

    function executeAction(actionName) {
        var actionTypeId = deviceClass.actionTypes.findByName(actionName).id;
        print("executing", device, device.id, actionTypeId, actionName, deviceClass.actionTypes)
        Engine.jsonRpcClient.executeAction(device.id, actionTypeId)
    }

    property var playbackState: device.states.getState(deviceClass.stateTypes.findByName("playbackStatus").id)

    ColumnLayout {
        id: column
        anchors { left: parent.left; right: parent.right }

        RowLayout {
            Layout.fillWidth: true
            Button {
                text: "|<"
                onClicked: {
                    executeAction("skipBack")
                }
            }
            Button {
                text: "<<"
                onClicked: {
                    executeAction("rewind")
                }
            }
            Button {
                text: "X"+ playbackState.value
                onClicked: {
                    executeAction("stop")
                }
            }
            Button {
                text: ">"
                visible: playbackState.value == "PAUSED"
                onClicked: {
                    executeAction("play")
                }
            }
            Button {
                text: "||"
                visible: playbackState.value == "PLAYING"
                onClicked: {
                    executeAction("pause")
                }
            }

            Button {
                text: ">>"
                onClicked: {
                    executeAction("fastForward")
                }
            }
            Button {
                text: ">|"
                onClicked: {
                    executeAction("skipNext")
                }
            }
        }
    }
}

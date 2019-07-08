import QtQuick 2.5
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.1
import Nymea 1.0

RowLayout {
    id: root
    implicitHeight: iconSize + app.margins

    property Device device: null
    property int iconSize: app.iconSize * 1.5

    readonly property StateType playbackStateType: device ? device.deviceClass.stateTypes.findByName("playbackStatus") : null
    readonly property State playbackState: playbackStateType ? device.states.getState(playbackStateType.id) : null

    function executeAction(actionName, params) {
        var actionTypeId = device.deviceClass.actionTypes.findByName(actionName).id;
        engine.deviceManager.executeAction(device.id, actionTypeId, params)
    }

    Item { Layout.fillWidth: true }
    ProgressButton {
        Layout.preferredHeight: root.iconSize * .6
        Layout.preferredWidth: height
        imageSource: "../images/media-skip-backward.svg"
        longpressImageSource: "../images/media-seek-backward.svg"
        enabled: root.playbackState.value !== "Stopped"
        repeat: true
        onClicked: {
            root.executeAction("skipBack")
        }
        onLongpressed: {
            root.executeAction("fastRewind")
        }
    }
    Item { Layout.fillWidth: true }
    ProgressButton {
        Layout.preferredHeight: root,iconSize
        Layout.preferredWidth: height
        imageSource: root.playbackState && root.playbackState.value === "Playing" ? "../images/media-playback-pause.svg" : "../images/media-playback-start.svg"
        longpressImageSource: "../images/media-playback-stop.svg"
        longpressEnabled: root.playbackState.value !== "Stopped"

        onClicked: {
            if (root.playbackState.value === "Playing") {
                root.executeAction("pause")
            } else {
                root.executeAction("play")
            }
        }

        onLongpressed: {
            root.executeAction("stop")
        }
    }
    Item { Layout.fillWidth: true }
    ProgressButton {
        Layout.preferredHeight: root.iconSize * .6
        Layout.preferredWidth: height
        imageSource: "../images/media-skip-forward.svg"
        longpressImageSource: "../images/media-seek-forward.svg"
        enabled: root.playbackState.value !== "Stopped"
        repeat: true
        onClicked: {
            root.executeAction("skipNext")
        }
        onLongpressed: {
            root.executeAction("fastForward")
        }
    }
    Item { Layout.fillWidth: true }
}

import QtQuick 2.5
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.1
import Nymea 1.0
import "../components"

CustomViewBase {
    id: root
    height: row.implicitHeight + app.margins * 2

    RowLayout {
        id: row
        anchors { left: parent.left; top: parent.top; right: parent.right; margins: app.margins }

        AbstractButton {
            width: app.iconSize * 2
            height: width

            property var muteState: root.device.states.getState(deviceClass.stateTypes.findByName("mute").id)
            property bool isMuted: muteState.value === true

            ColorIcon {
                anchors.fill: parent
                name: "../images/audio-speakers-muted-symbolic.svg"
                color: parent.isMuted ? app.accentColor : keyColor
            }

            onClicked: {
                var paramList = []
                var muteParam = {}
                muteParam["paramTypeId"] = deviceClass.stateTypes.findByName("mute").id
                muteParam["value"] = !isMuted
                paramList.push(muteParam)
                Engine.deviceManager.executeAction(root.device.id, deviceClass.actionTypes.findByName("mute").id, paramList)
            }
        }

        ThrottledSlider {
            Layout.fillWidth: true
            value: root.device.stateValue(deviceClass.stateTypes.findByName("volume").id)
            from: 0
            to: 100
            onMoved: {
                var paramList = []
                var muteParam = {}
                muteParam["paramTypeId"] = deviceClass.stateTypes.findByName("volume").id
                muteParam["value"] = value
                paramList.push(muteParam)
                Engine.deviceManager.executeAction(root.device.id, deviceClass.actionTypes.findByName("volume").id, paramList)
            }
        }
    }
}

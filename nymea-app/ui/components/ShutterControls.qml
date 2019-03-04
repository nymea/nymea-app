import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2
import QtQuick.Layouts 1.3
import Nymea 1.0

RowLayout {
    id: root
    spacing: (parent.width - app.iconSize*2*children.length) / children.length
//    implicitWidth: app.iconSize * 2 * children.length + spacing * (children.length - 1)
    implicitWidth: childrenRect.width

    property var device: null
    readonly property var deviceClass: device ? engine.deviceManager.deviceClasses.getDeviceClass(device.deviceClassId) : null
    readonly property var openState: device ? device.states.getState(deviceClass.stateTypes.findByName("state").id) : null

    property bool invert: false

    ItemDelegate {
        Layout.preferredWidth: app.iconSize * 2
        Layout.preferredHeight: width

        ColorIcon {
            anchors.fill: parent
            anchors.margins: app.margins
            name: root.invert ? "../images/down.svg" : "../images/up.svg"
            color: root.openState && root.openState.value === "opening" ? Material.accent : keyColor
        }
        onClicked: engine.deviceManager.executeAction(root.device.id, root.deviceClass.actionTypes.findByName("open").id)
    }


   ItemDelegate {
        Layout.preferredWidth: app.iconSize * 2
        Layout.preferredHeight: width
//        color: Material.foreground
//        radius: height / 2

        ColorIcon {
            anchors.fill: parent
            anchors.margins: app.margins
            name: "../images/media-playback-stop.svg"
        }
        onClicked: engine.deviceManager.executeAction(root.device.id, root.deviceClass.actionTypes.findByName("stop").id)
    }

    ItemDelegate {
        Layout.preferredWidth: app.iconSize * 2
        Layout.preferredHeight: width

        ColorIcon {
            anchors.fill: parent
            anchors.margins: app.margins
            name: root.invert ? "../images/up.svg" : "../images/down.svg"
            color: root.openState && root.openState.value === "closing" ? Material.accent : keyColor
        }
        onClicked: engine.deviceManager.executeAction(root.device.id, root.deviceClass.actionTypes.findByName("close").id)
    }
}

import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2
import QtQuick.Layouts 1.3
import Mea 1.0

RowLayout {
    id: root
    spacing: (parent.width - app.iconSize*2*children.length) / 4
//    implicitWidth: app.iconSize * 2 * children.length + spacing * (children.length - 1)
    implicitWidth: childrenRect.width

    property var device: null
    readonly property var deviceClass: device ? Engine.deviceManager.deviceClasses.getDeviceClass(device.deviceClassId) : null
    readonly property var openState: device ? device.states.getState(deviceClass.stateTypes.findByName("state").id) : null

    Rectangle {
        Layout.preferredWidth: app.iconSize * 2
        Layout.preferredHeight: width
        color: root.openState && root.openState.value === "opening" ? Material.accent : Material.foreground
        radius: height / 2

        ColorIcon {
            anchors.fill: parent
            anchors.margins: app.margins
            name: "../images/up.svg"
        }
        MouseArea {
            anchors.fill: parent
            onClicked: Engine.deviceManager.executeAction(root.device.id, root.deviceClass.actionTypes.findByName("open").id)
        }
    }

    Rectangle {
        Layout.preferredWidth: app.iconSize * 2
        Layout.preferredHeight: width
        color: Material.foreground
        radius: height / 2

        ColorIcon {
            anchors.fill: parent
            anchors.margins: app.margins
            name: "../images/remove.svg"
        }
        MouseArea {
            anchors.fill: parent
            onClicked: Engine.deviceManager.executeAction(root.device.id, root.deviceClass.actionTypes.findByName("stop").id)
        }
    }

    Rectangle {
        Layout.preferredWidth: app.iconSize * 2
        Layout.preferredHeight: width
        color: root.openState && root.openState.value === "closing" ? Material.accent : Material.foreground
        radius: height / 2

        ColorIcon {
            anchors.fill: parent
            anchors.margins: app.margins
            name: "../images/down.svg"
        }
        MouseArea {
            anchors.fill: parent
            onClicked: Engine.deviceManager.executeAction(root.device.id, root.deviceClass.actionTypes.findByName("close").id)
        }
    }
}

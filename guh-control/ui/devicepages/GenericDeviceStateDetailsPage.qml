import QtQuick 2.5
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.1
import Guh 1.0
import "../components"

Page {
    id: root

    property var device
    readonly property var deviceClass: Engine.deviceManager.deviceClasses.getDeviceClass(device.deviceClassId)

    header: GuhHeader {
        text: "Details for " + root.device.name
        onBackPressed: pageStack.pop()
    }
    ColumnLayout {
        anchors { left: parent.left; top: parent.top; right: parent.right; margins: app.margins }
        spacing: app.margins

        Repeater {
            model: deviceClass.stateTypes
            delegate: RowLayout {
                width: parent.width
                height: app.largeFont

                Label {
                    id: stateLabel
                    Layout.preferredWidth: parent.width / 2
                    text: name
                }

                Label {
                    id: valueLable
                    Layout.fillWidth: true
                    text: device.states.getState(id).value + " " + deviceClass.stateTypes.getStateType(id).unitString
                }
            }
        }
    }
}

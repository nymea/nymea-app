import QtQuick 2.5
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.1
import "../components"
import Guh 1.0

CustomViewBase {
    id: root
    height: grid.implicitHeight + app.margins * 2

    ColumnLayout {
        id: grid
        anchors { left: parent.left; top: parent.top; right: parent.right; margins: app.margins }
        Label {
            Layout.fillWidth: true
            text: "Send a notification now:"
        }
        TextArea {
            id: textArea
            Layout.fillWidth: true
        }
        Button {
            Layout.fillWidth: true
            text: "Send"
            onClicked: {

                var params = []
                var param1 = {}
                print("bla:", root.deviceClass.actionTypes.findByName("notify").paramTypes)
                var paramTypeId = root.deviceClass.actionTypes.findByName("notify").paramTypes.findByName("title").id
                param1.paramTypeId = paramTypeId
                param1.value = textArea.text
                params.push(param1)
                Engine.deviceManager.executeAction(root.device.id, root.deviceClass.actionTypes.findByName("notify").id, params)
            }
        }
    }
}

import QtQuick 2.5
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.1
import "../components"
import Mea 1.0

CustomViewBase {
    id: root
    height: grid.implicitHeight + app.margins * 2

    ColumnLayout {
        id: grid
        anchors { left: parent.left; top: parent.top; right: parent.right; margins: app.margins }
        Label {
            Layout.fillWidth: true
            text: qsTr("Send a notification now:")
        }
        TextArea {
            id: titleTextArea
            placeholderText: qsTr("Title")
            Layout.fillWidth: true
        }
        TextArea {
            id: bodyTextArea
            placeholderText: qsTr("Text")
            Layout.fillWidth: true
        }
        Button {
            Layout.fillWidth: true
            text: qsTr("Send")
            onClicked: {

                var params = []
                var param1 = {}
                print("bla:", root.deviceClass.actionTypes.findByName("notify").paramTypes)
                var paramTypeId = root.deviceClass.actionTypes.findByName("notify").paramTypes.findByName("title").id
                param1.paramTypeId = paramTypeId
                param1.value = titleTextArea.text
                params.push(param1)
                var param2 = {}
                paramTypeId = root.deviceClass.actionTypes.findByName("notify").paramTypes.findByName("body").id
                param2.paramTypeId = paramTypeId
                param2.value = bodyTextArea.text
                params.push(param2)
                Engine.deviceManager.executeAction(root.device.id, root.deviceClass.actionTypes.findByName("notify").id, params)
            }
        }
    }
}

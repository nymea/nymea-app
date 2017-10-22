import QtQuick 2.5
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.1

ActionDelegateBase {
    id: root
    height: rowLayout.implicitHeight

    RowLayout {
        id: rowLayout
        anchors { left: parent.left; right: parent.right; margins: app.margins }
        spacing: app.margins

        Label {
            Layout.fillWidth: true
            verticalAlignment: Text.AlignVCenter
            text: root.actionType ? root.actionType.name : ""
        }
        Switch {
            position: root.actionState ? root.actionState : 0
            onClicked: {
                var params = [];
                var param1 = new Object();
                param1["paramTypeId"] = root.actionType.paramTypes.get(0).id;
                param1["value"] = checked;
                params.push(param1)
                root.executeAction(params)
            }
        }
    }
}

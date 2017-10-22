import QtQuick 2.5
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.1

ActionDelegateBase {
    id: root
    height: layout.height + app.margins * 2

    property var paramType: actionType.paramTypes.get(0)
    RowLayout {
        id: layout
        anchors { left: parent.left; top: parent.top; right: parent.right; margins: app.margins }
        Label {
            text: root.paramType.name
            Layout.fillWidth: true
        }
        ComboBox {
            model: root.paramType.allowedValues
            currentIndex: root.paramType.allowedValues.indexOf(root.actionState)
            onActivated: {
                if (root.actionState == root.paramType.allowedValues[index]) {
                    return;
                }

                var params = [];
                var param1 = {};
                param1["paramTypeId"] = root.paramType.id;
                param1["value"] = root.paramType.allowedValues[index];
                params.push(param1);
                root.executeAction(params)
            }
        }
    }
}

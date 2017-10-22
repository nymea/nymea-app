import QtQuick 2.5
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.1

ActionDelegateBase {
    id: root
    height: columnLayout.height + app.margins

    ColumnLayout {
        id: columnLayout
        anchors { left: parent.left; right: parent.right; top: parent.top; margins: app.margins }

        Label {
            Layout.fillWidth: true
            text: root.actionType.paramTypes.get(0).name
        }

        Slider {
            Layout.fillWidth: true
            from: root.actionType ? root.actionType.paramTypes.get(0).minValue : 0
            to: root.actionType ? root.actionType.paramTypes.get(0).maxValue : 100000000
            value: root.actionState
            onValueChanged: {
                if (pressed) {
                    var params = [];
                    var param1 = {};
                    param1["paramTypeId"] = root.actionType.paramTypes.get(0).id;
                    param1["value"] = value;
                    params.push(param1)
                    root.executeAction(params)
                }
            }
        }
    }
}

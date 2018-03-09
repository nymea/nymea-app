import QtQuick 2.5
import QtQuick.Controls.Material 2.1
import "../components"

ActionDelegateBase {
    id: root
    height: 200

    onActionStateChanged: {
        if (actionState && !colorPicker.pressed) {
            colorPicker.color = actionState
        }
    }

    ColorPicker {
        id: colorPicker
        anchors.fill: parent
        anchors.margins: app.margins
        color: root.actionState ? root.actionState : "white"
        touchDelegate: Rectangle {
            height: 15
            width: height
            radius: height / 2
            color: Material.accent


            Rectangle {
                color: colorPicker.hovered || colorPicker.pressed ? "#11000000" : "transparent"
                anchors.centerIn: parent
                height: 30
                width: height
                radius: width / 2
                Behavior on color {
                    ColorAnimation {
                        duration: 200
                    }
                }
            }
        }

        property var lastSentTime: new Date()
        onColorChanged: {
            var currentTime = new Date();
            if (pressed && currentTime - lastSentTime > 200) {
                var params = [];
                var param1 = new Object();
                param1["paramTypeId"] = root.actionType.paramTypes.get(0).id;
                param1["value"] = color;
                params.push(param1)
                root.executeAction(params)
                lastSentTime = currentTime
            }
        }
    }
}

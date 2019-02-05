import QtQuick 2.5
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2
import QtQuick.Layouts 1.1
import Nymea 1.0
import "../../components"

Item {
    id: colorComponentItem
    implicitWidth: app.iconSize * 2
    implicitHeight: app.iconSize
    property bool writable: false
    property var value
    signal changed(var value)

    Pane {
        anchors.fill: parent
        topPadding: 0
        bottomPadding: 0
        leftPadding: 0
        rightPadding: 0
        Material.elevation: 1
        contentItem: Rectangle {
            color: colorComponentItem.value

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    if (!colorComponentItem.writable) {
                        return;
                    }

                    var pos = colorComponentItem.mapToItem(root, 0, colorComponentItem.height)
                    print("opening", colorComponentItem.value)
                    var colorPicker = colorPickerComponent.createObject(root, {preferredY: pos.y, colorValue: colorComponentItem.value })
                    colorPicker.open()
                }
            }
        }
    }

    Component {
        id: colorPickerComponent
        Dialog {
            id: colorPickerDialog
            modal: true
            x: (parent.width - width) / 2
            y: Math.min(preferredY, parent.height - height)
            width: parent.width - app.margins * 2
            height: 200
            padding: app.margins
            property var colorValue
            property int preferredY: 0
            contentItem: ColorPicker {
                color: colorPickerDialog.colorValue
                property var lastSentTime: new Date()
                onColorChanged: {
                    var currentTime = new Date();
                    if (pressed && currentTime - lastSentTime > 200) {
                        colorComponentItem.changed(color);
                    }
                }
            }
        }
    }
}

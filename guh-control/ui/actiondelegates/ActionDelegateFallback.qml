import QtQuick 2.5
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.1

ActionDelegateBase {
    id: root
    height: columnLayout.height + app.margins * 2

    ColumnLayout {
        id: columnLayout
        anchors { left: parent.left; right: parent.right; top: parent.top; margins: app.margins }

        Label {
            Layout.fillWidth: true
            text: actionType.name
        }
        Label {
            Layout.fillWidth: true
            text: "Note: This action type has not been implemented yet"
            font.pixelSize: app.smallFont
        }
    }
}

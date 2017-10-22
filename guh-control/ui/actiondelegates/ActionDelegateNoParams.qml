import QtQuick 2.5
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.1

ActionDelegateBase {
    id: root
    height: layout.height + app.margins * 2

    RowLayout {
        id: layout
        anchors { left: parent.left; right: parent.right; top: parent.top; margins: app.margins }
        Label {
            text: root.actionType.name
            Layout.fillWidth: true
        }
        Button {
            text: "Do it!"
            onClicked: root.executeAction([])
        }
    }
}

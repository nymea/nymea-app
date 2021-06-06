import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import Nymea 1.0

Rectangle {
    id: root
    color: Style.tileBackgroundColor
    radius: Style.smallCornerRadius
    implicitHeight: layout.implicitHeight

    property int currentIndex: 0
    property alias model: repeater.model
    readonly property var currentValue: model.hasOwnProperty("get") ? model.get(currentIndex) : model[currentIndex]


    Rectangle {
        x: repeater.count > 0 ? repeater.itemAt(root.currentIndex).x + 1 : 0
        anchors.verticalCenter: parent.verticalCenter
        Behavior on x { NumberAnimation { duration: 150; easing.type: Easing.InOutQuad } }
        height: layout.height - 2
        width: Math.floor(root.width / repeater.count) - 2
        color: Style.tileOverlayColor
        radius: Style.smallCornerRadius
    }

    RowLayout {
        id: layout
        anchors { left: parent.left; right: parent.right; verticalCenter: parent.verticalCenter }
        spacing: 0

        Repeater {
            id: repeater

            delegate: Item {
                Layout.fillWidth: true
                height: label.implicitHeight + Style.smallMargins
                Label {
                    id: label
                    anchors.centerIn: parent
                    text: modelData
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        print("current index:", index)
                        root.currentIndex = index
                    }
                }
            }
        }
    }
}

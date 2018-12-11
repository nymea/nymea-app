import QtQuick 2.9

Item {
    id: root
    implicitHeight: app.iconSize * .8
    implicitWidth: height

    property bool on: false

    Rectangle {
        height: Math.min(parent.height, parent.height)
        width: height
        radius: width / 2
        color: root.on ? "lightgreen" : "lightgray"
        border.width: 1
        border.color: app.foregroundColor
    }
}

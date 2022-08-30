import QtQuick 2.0
import Nymea 1.0

Item {
    id: root
    property color color: Style.iconColor
    implicitWidth: Style.iconSize
    implicitHeight: Style.iconSize

    property int dotSize: width / 6

    property bool running: true

    Grid {
        id: grid
        columns: 3
        anchors.fill: parent
        spacing: (width - columns * root.dotSize) / (columns - 1)

        Repeater {
            id: dotRepeater
            model: Math.pow(grid.columns, 2)
            delegate: Rectangle {
                id: dot
                width: root.dotSize
                height: width
                color: root.color
                property int duration: 400
                property int row: Math.floor(index / grid.columns)
                property int pause: row * 200

                SequentialAnimation {
                    running: root.running && root.visible
                    loops: Animation.Infinite
                    PauseAnimation { duration: dot.pause }
                    NumberAnimation {
                        target: dot
                        property: "opacity"
                        from: 0.2; to: 1;
                        duration: dot.duration
                    }
                    NumberAnimation {
                        target: dot
                        property: "opacity"
                        from: 1; to: 0.2;
                        duration: dot.duration
                    }
                }
            }
        }
    }
}

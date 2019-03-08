import QtQuick 2.9

Item {
    id: root
    implicitHeight: app.iconSize * .8
    implicitWidth: height

    // TODO: Convert to enum once we have Qt 5.10
    // on, off, green, orange, red
    property string state: "off"

    Rectangle {
        height: Math.min(parent.height, parent.height)
        width: height
        radius: width / 2
        color: {
            switch (root.state) {
            case "on":
            case "green":
                return "#91dd77";
            case "off":
                return "lightgray";
            case "orange":
                return "#dddd77";
            case "red":
                return "#dd7777"
            }
        }
        border.width: 1
        border.color: app.foregroundColor
    }
}

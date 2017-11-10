import QtQuick 2.5
import QtQuick.Controls 2.1

ToolButton {
    property alias imageSource: image.name
    property alias color: image.color

    contentItem: Item {
        height: 20
        width: 20
        ColorIcon {
            id: image
            anchors.fill: parent
            anchors.margins: app.margins / 2
        }
    }
}

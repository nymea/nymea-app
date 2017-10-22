import QtQuick 2.5
import QtQuick.Controls 2.1

ToolButton {
    property alias imageSource: image.source

    contentItem: Item {
        height: 20
        width: 20
        Image {
            id: image
            anchors.fill: parent
            anchors.margins: app.margins / 2
            sourceSize.height: height
            sourceSize.width: width
        }
    }
}

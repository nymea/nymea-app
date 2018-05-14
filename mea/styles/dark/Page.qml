import QtQuick 2.0
import QtQuick.Templates 2.2
import QtQuick.Controls.Material 2.2

Page {

    background: Rectangle {
        color: Material.background
        Image {
            id: bg
            source: "qrc:/guh-logo.svg"
            anchors.fill: parent
            fillMode: Image.PreserveAspectFit
            opacity: .2
        }
    }
}

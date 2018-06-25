import QtQuick 2.8
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.3

MenuItem {
    id: root
    property alias iconSource: icon.name

    contentItem: RowLayout {
        spacing: app.margins
        ColorIcon {
            id: icon
            height: parent.height
            width: height
        }
        Label {
            id: label
            text: root.text
            Layout.fillWidth: true
            font.pixelSize: app.mediumFont
            elide: Text.ElideRight
        }
    }
}

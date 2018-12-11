import QtQuick 2.8
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.3

MenuItem {
    id: root
    property alias iconSource: icon.name
    implicitWidth: 200

    contentItem: RowLayout {
        spacing: app.margins
        ColorIcon {
            id: icon
            Layout.preferredHeight: app.iconSize
            Layout.preferredWidth: height
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

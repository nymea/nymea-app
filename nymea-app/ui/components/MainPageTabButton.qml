import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2
import QtQuick.Layouts 1.3

TabButton {
    id: root
    property string iconSource

    contentItem: ColumnLayout {
        ColorIcon {
            Layout.preferredWidth: app.iconSize
            Layout.preferredHeight: app.iconSize
            Layout.alignment: Qt.AlignHCenter
            name: root.iconSource
            color: root.checked ? app.guhAccent : keyColor
        }
        Label {
            Layout.fillWidth: true
            text: root.text
            horizontalAlignment: Text.AlignHCenter
            font.pixelSize: app.smallFont
            color: root.checked ? app.guhAccent : Material.foreground
        }
    }
}

